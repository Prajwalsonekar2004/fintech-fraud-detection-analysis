SELECT * FROM fintech_dataset LIMIT 20;

-- Total Transaction Metrics
-- 1. How many transactions are processed and what is the total value?
SELECT COUNT(*) AS total_transactions, ROUND(SUM(amount::NUMERIC),2) AS total_transaction_value
FROM fintech_dataset;

-- Fraud Rate
-- 2.What percentage of transactions are fraudulent?
SELECT COUNT(*) AS total_transactions, ROUND(AVG(isfraud) * 100, 2) AS percent_of_fraud_tx
FROM fintech_dataset;

-- Fraud by Transaction Type
-- 3.Which payment type has the highest fraud risk?
SELECT type, COUNT(*) AS total_transactions, SUM(isfraud) AS fraud_cases, 
ROUND(SUM(isfraud)::DECIMAL / COUNT(*) * 100, 2) AS fraud_rate_percent
FROM fintech_dataset
GROUP BY type
ORDER BY fraud_rate_percent DESC;

-- Transaction Volume by Type
-- 4.Which payment channel processes the most money?
SELECT type, COUNT(*) AS total_transactions, ROUND(SUM(amount::NUMERIC),2) AS total_amount
FROM fintech_dataset
GROUP BY type
ORDER BY total_amount DESC;

-- Fraud by Hour of Day
-- 5.At what time does fraud occur most frequently?
SELECT hour, COUNT(*) AS total_transactions, SUM(isfraud) AS total_frauds,
ROUND(SUM(isfraud::NUMERIC) / COUNT(*) * 100, 2) AS fraud_rate_percent
FROM fintech_dataset
GROUP BY hour
ORDER BY fraud_rate_percent DESC;

-- High Value Transaction Risk
-- 6.Are large transactions more risky?
SELECT CASE WHEN amount < 10000 THEN 'Low' WHEN amount BETWEEN 10000 AND 200000 THEN 'Medium' 
ELSE 'High' END AS amount_category, COUNT(*) AS total_transactions, ROUND(SUM(amount::NUMERIC),2) AS total_amount,
SUM(isfraud) AS total_frauds, ROUND(SUM(isfraud)::DECIMAL / COUNT(*) * 100, 2) AS fraud_rate_percent
FROM fintech_dataset
GROUP BY amount_category
ORDER BY fraud_rate_percent DESC;

-- Account Draining Fraud Pattern
-- This is one of our strongest insights.
-- 7.How often does account draining lead to fraud?
SELECT emptied_account, COUNT(*) AS total_transactions, SUM(isfraud) AS total_frauds,
ROUND(SUM(isfraud::DECIMAL) / COUNT(*) * 100, 2) AS fraud_rate_percent
FROM fintech_dataset
GROUP BY emptied_account
ORDER BY fraud_rate_percent DESC;

-- Top Suspicious Transactions
-- 8.What are the largest suspicious transactions?
SELECT nameorig AS sender_account, namedest AS receiver_account, type, amount, risk_score, isfraud,
oldbalanceorg, newbalanceorig
FROM fintech_dataset
WHERE risk_score >= 4
ORDER BY amount DESC
LIMIT 10;

SELECT namedest, COUNT(*) AS total_tx, SUM(amount::NUMERIC) AS total_amount_tx
FROM fintech_dataset
GROUP BY namedest
ORDER BY total_amount_tx DESC
LIMIT 10;

-- Top Accounts by Transaction Volume
-- 9.Which users move the most money?
SELECT nameorig AS sender_account, COUNT(*) AS total_tx, SUM(amount::NUMERIC) AS total_tx_amount
FROM fintech_dataset
GROUP BY sender_account
ORDER BY total_tx_amount DESC
LIMIT 10;

-- Fraud Transactions by Receiver
-- 10.Which accounts receive the most fraudulent transfers?
SELECT namedest AS receiver_account, COUNT(*) AS total_fraud_tx, SUM(amount::NUMERIC) AS tx_amount
FROM fintech_dataset
WHERE isfraud = 1
GROUP BY receiver_account
ORDER BY tx_amount DESC
LIMIT 10;

-- Risk Score Distribution
-- 11.Does the risk scoring model correctly identify fraud?
SELECT risk_score, COUNT(*) AS total_tx, SUM(isfraud) AS total_frauds,
ROUND(SUM(isfraud::DECIMAL) / COUNT(*) * 100, 2) AS fraud_rate_percent
FROM fintech_dataset
GROUP BY risk_score
ORDER BY fraud_rate_percent DESC
LIMIT 10;

-- Fraud Share by Transaction Type
-- 12.What percentage of fraud comes from each transaction type?
SELECT type, COUNT(*) AS total_tx, SUM(isfraud) AS total_frauds,
ROUND(SUM(isfraud::DECIMAL) / (SELECT SUM(isfraud) FROM fintech_dataset) * 100, 2) AS fraud_share_percent
FROM fintech_dataset
GROUP BY type
ORDER BY fraud_share_percent DESC;

-- 14. Total fraud amount
SELECT ROUND(SUM(amount::NUMERIC),2) AS "Total fraud amount"
FROM fintech_dataset
WHERE isfraud = 1;

-- 15.High Risk Transactions
SELECT COUNT(*) AS total_tx
FROM fintech_dataset
WHERE risk_score >= 4;

SELECT * FROM fintech_dataset LIMIT 20;
-- 16.high value tx
SELECT COUNT(*) AS "high value tx"
FROM fintech_dataset
WHERE high_value_tx = 1;