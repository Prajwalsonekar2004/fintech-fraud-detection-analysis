# FinTech Fraud Risk Analysis

## Project Overview

This project analyzes digital payment transactions to identify fraud patterns, revenue risks, and high-risk behaviors in a fintech system.

The analysis is based on a large-scale transaction dataset (~6.3 million records) and simulates real-world payment systems used by fintech companies.

---

## Business Objective

The goal of this project is to:

* Monitor transaction performance
* Identify fraud patterns
* Detect high-risk transactions
* Provide actionable insights for risk and operations teams

---

## Dataset

* Source: PaySim Financial Transactions Dataset (Kaggle)
* Records: 6.3 million transactions
* Data includes transaction type, amount, sender, receiver, balances, and fraud labels

---

## Tools & Technologies

* Python (Pandas, NumPy)
* PostgreSQL
* Power BI

---

## Data Processing (Python)

Performed data cleaning and transformation:

* Removed duplicates
* Handled data inconsistencies
* Created time-based features (hour)
* Engineered fraud-related features:

  * `emptied_account` (account draining behavior)
  * `high_value_txn` (large transactions)
  * `high_risk_type` (TRANSFER, CASH_OUT)
  * `risk_score` (combined risk indicator)

---

## Exploratory Data Analysis

Key analysis performed:

* Transaction distribution by type
* Fraud rate by transaction type
* Fraud analysis by transaction amount
* Fraud patterns across time (hourly)
* Sender and receiver behavior analysis

---

## Database Design (PostgreSQL)

* Created structured transaction table
* Loaded cleaned dataset into PostgreSQL
* Performed analytical SQL queries for business insights

---

## SQL Analysis

Developed queries to answer key business questions:

* Total transaction volume and value
* Fraud rate calculation
* Fraud distribution by transaction type
* High-risk transactions detection
* Top suspicious accounts (senders and receivers)

---

## Dashboard (Power BI)

Built an interactive dashboard with:

### Key KPIs

* Total Transactions
* Fraud Transactions
* Fraud Rate

### Key Insights

* Fraud concentrated in TRANSFER and CASH_OUT
* Account draining transactions show very high fraud probability
* High-value transactions have higher fraud risk
* Fraud activity varies by time and transaction behavior

---

## Key Findings

* Fraud is highly concentrated in specific transaction types
* Transactions that empty sender accounts have significantly higher fraud probability
* Large transactions are more likely to be fraudulent
* Fraud follows identifiable behavioral patterns

---

## Conclusion

This project demonstrates how transaction data can be used to detect fraud patterns and support decision-making in fintech systems.

It showcases end-to-end data analysis including data cleaning, feature engineering, SQL analytics, and dashboard visualization.

---

## Project Structure

* data/ → dataset
* notebooks/ → Python analysis
* sql/ → SQL queries
* dashboard/ → Power BI file

---

## Future Improvements

* Real-time fraud detection pipeline
* Machine learning model for fraud prediction
* Integration with cloud platforms (GCP/AWS)
