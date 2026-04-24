CREATE DATABASE fintech_fraud;
USE fintech_fraud;

CREATE TABLE transactions (
step INT,
type VARCHAR (20),
amount DECIMAL(15,2),
nameOrig VARCHAR (50),
oldbalanceOrg DECIMAL(15,2),
newbalanceOrig DECIMAL(15,2),
nameDest VARCHAR(50),
oldbalanceDest DECIMAL(15,2),
newbalanceDest DECIMAL(15,2),
isFraud INT,
isFlaggedFraud INT
);

SELECT * FROM fintech_fraud.transactions LIMIT 20;

SELECT COUNT(*) FROM fintech_fraud.transactions;

-- rename columns 
ALTER TABLE fintech_fraud.transactions
RENAME COLUMN nameOrig TO sender_name;

ALTER TABLE fintech_fraud.transactions
RENAME COLUMN oldbalanceOrg TO sender_old_balance;

ALTER TABLE fintech_fraud.transactions
RENAME COLUMN newbalanceOrig TO sender_new_balance;

ALTER TABLE fintech_fraud.transactions
RENAME COLUMN nameDest TO receivers_name;

ALTER TABLE fintech_fraud.transactions
RENAME COLUMN oldbalanceDest TO receivers_old_balance;

ALTER TABLE fintech_fraud.transactions
RENAME COLUMN newbalanceDest TO receivers_new_balance;

ALTER TABLE fintech_fraud.transactions
RENAME COLUMN isFraud TO is_fraud;

ALTER TABLE fintech_fraud.transactions
RENAME COLUMN isFlaggedFraud TO is_flagged_fraud;

CREATE TABLE transactions_clean AS 
SELECT DISTINCT * FROM transactions;

CREATE INDEX idx_type ON transactions_clean(type);
CREATE INDEX idx_is_fraud ON transactions_clean(is_fraud);
CREATE INDEX idx_sender_name ON transactions_clean(sender_name);
CREATE INDEX idx_receivers_name ON transactions_clean(receivers_name);
CREATE INDEX idx_step ON transactions_clean(step);

SELECT * FROM transactions_clean LIMIT 20;

SELECT type, count(*) AS total_txn, SUM(is_fraud) AS total_fraud_txn
FROM transactions_clean
WHERE is_fraud = 1
GROUP BY type;

-- analytical table (FEATURE ENGINEERING)
CREATE TABLE transactions_final AS 
SELECT *, 
-- time feature
step % 24 AS hour,
-- high value txn
CASE WHEN amount > 200000 THEN 1 ELSE 0 END AS high_value_txn,
-- high risk type
CASE WHEN type IN ('TRANSFER', 'CASH_OUT') THEN 1 ELSE 0 END AS high_risk_type,
-- emptied account
CASE WHEN sender_old_balance > 0 AND sender_new_balance = 0 AND amount >= sender_old_balance 
THEN 1 ELSE 0 END AS emptied_account

FROM  transactions_clean;

ALTER TABLE transactions_final
ADD COLUMN risk_score INT;

-- creating risk score column
SET SQL_SAFE_UPDATES = 0;
UPDATE transactions_final
SET risk_score = (high_value_txn * 2) + (high_risk_type * 3) + (emptied_account * 5);

-- creating risk level column
ALTER TABLE transactions_final
ADD COLUMN risk_level VARCHAR(20);

UPDATE transactions_final
SET risk_level = CASE
				 WHEN risk_score <= 2 THEN 'Low Risk' 
				 WHEN risk_score <= 6 THEN 'Medium Risk' 
                 ELSE 'High Risk' END;


SET SQL_SAFE_UPDATES = 0;
-- creating fraud rule engine
ALTER TABLE transactions_final
ADD COLUMN fraud_flag_rule INT;

UPDATE transactions_final
SET fraud_flag_rule = CASE
					  WHEN emptied_account = 1 THEN 1
                      WHEN high_value_txn = 1 AND high_risk_type = 1 THEN 1
                      ELSE 0 END;
                      


-- Fraud Summary
SELECT COUNT(*) AS total_txn, SUM(is_fraud) AS total_fraud, 
ROUND(SUM(is_fraud) / COUNT(*) * 100, 3) AS fraud_rate
FROM transactions_final;

-- Fraud by Type
SELECT type, COUNT(*) AS total_txn, SUM(is_fraud), ROUND(SUM(is_fraud) / COUNT(*) * 100, 2) AS fraud_rate_by_type
FROM transactions_final
GROUP BY type
ORDER BY fraud_rate_by_type DESC;

-- Risk Distribution
SELECT risk_level, COUNT(*) AS total_txn, SUM(is_fraud) AS total_fraud_txn
FROM transactions_final
GROUP BY risk_level
ORDER BY total_fraud_txn DESC;

-- Hourly Fraud Pattern 
SELECT hour, COUNT(*) AS total_txn, SUM(is_fraud) AS total_fraud_txn,
ROUND(SUM(is_fraud) / COUNT(*) * 100,2) AS fraud_rate
FROM transactions_final
GROUP BY hour
ORDER BY fraud_rate DESC;

-- Top Fraud Senders
SELECT sender_name, COUNT(*) AS total_txn, SUM(is_fraud) AS total_fraud_txn,
ROUND(SUM(is_fraud) / COUNT(*) * 100,2) AS fraud_rate
FROM transactions_final
GROUP BY sender_name
ORDER BY fraud_rate DESC
LIMIT 10;

-- Fraud vs Risk Score
SELECT risk_score, COUNT(*) AS total_txn, SUM(is_fraud) AS total_fraud_txn
FROM transactions_final
GROUP BY risk_score
ORDER BY total_fraud_txn DESC;

-- Rule Engine Accuracy
SELECT fraud_flag_rule, COUNT(*) AS total_txn, SUM(is_fraud) AS actual_frauds
FROM transactions_final
GROUP BY fraud_flag_rule
ORDER BY actual_frauds DESC;

USE fintech_fraud;
SELECT * FROM transactions_final LIMIT 20;