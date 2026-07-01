-- Staging Tables
DROP TABLE IF EXISTS stg_transaction CASCADE;
CREATE TABLE stg_transaction (
    transaction_id TEXT, transaction_code TEXT, account_id TEXT, customer_id TEXT, branch_id TEXT,
    channel_id TEXT, transaction_date TEXT, transaction_at TEXT, transaction_type TEXT, amount TEXT,
    balance_before TEXT, balance_after TEXT, status TEXT, reference_no TEXT
);

DROP TABLE IF EXISTS stg_fraud_labels CASCADE;
CREATE TABLE stg_fraud_labels (
    transaction_id TEXT, transaction_code TEXT, is_fraud TEXT, fraud_type TEXT, fraud_score TEXT, flagged_at TEXT
);

DROP TABLE IF EXISTS stg_branches CASCADE;
CREATE TABLE stg_branches (
    branch_id TEXT, branch_code TEXT, branch_name TEXT, city TEXT, province TEXT, region TEXT,
    branch_type TEXT, open_date TEXT, is_active TEXT
);

DROP TABLE IF EXISTS stg_channels CASCADE;
CREATE TABLE stg_channels (
    channel_id TEXT, channel_code TEXT, channel_name TEXT, channel_category TEXT, is_digital TEXT, description TEXT
);

DROP TABLE IF EXISTS stg_accounts CASCADE;
CREATE TABLE stg_accounts (
    account_id TEXT, account_no TEXT, account_type TEXT, product_name TEXT, currency TEXT,
    open_date TEXT, close_date TEXT, status TEXT, interest_rate TEXT, customer_id TEXT, branch_id TEXT
);

-- Dimension Tables
DROP TABLE IF EXISTS dim_channels CASCADE;
CREATE TABLE dim_channels (
    channel_id INTEGER PRIMARY KEY, channel_code VARCHAR(50), channel_name VARCHAR(100),
    channel_category VARCHAR(50), is_digital BOOLEAN, description TEXT, etl_loaded_at TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS dim_branches CASCADE;
CREATE TABLE dim_branches (
    branch_id INTEGER PRIMARY KEY, branch_code VARCHAR(50), branch_name VARCHAR(100), city VARCHAR(100),
    province VARCHAR(100), region VARCHAR(100), branch_type VARCHAR(50), open_date DATE,
    is_active BOOLEAN, etl_loaded_at TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS dim_accounts CASCADE;
CREATE TABLE dim_accounts (
    account_id INTEGER PRIMARY KEY, account_no VARCHAR(50), account_type VARCHAR(50), product_name VARCHAR(100),
    currency VARCHAR(10), open_date DATE, close_date DATE, status VARCHAR(50), interest_rate NUMERIC(18,2),
    customer_id INTEGER, branch_id INTEGER, etl_loaded_at TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS dim_date CASCADE;
CREATE TABLE dim_date (
    date_id INTEGER PRIMARY KEY, full_date DATE, year INTEGER, quarter INTEGER, month INTEGER,
    month_name VARCHAR(20), week_of_year INTEGER, day_of_month INTEGER, day_of_week INTEGER,
    day_name VARCHAR(20), is_weekend BOOLEAN, is_holiday BOOLEAN
);

-- Fact Table
DROP TABLE IF EXISTS fact_transaction CASCADE;
CREATE TABLE fact_transaction (
    transaction_id INTEGER PRIMARY KEY, transaction_code VARCHAR(50), account_id INTEGER, customer_id INTEGER,
    branch_id INTEGER, channel_id INTEGER, date_id INTEGER, transaction_at TIMESTAMP, transaction_type VARCHAR(50),
    amount NUMERIC(18,2), balance_before NUMERIC(18,2), balance_after NUMERIC(18,2), status VARCHAR(50),
    reference_no VARCHAR(100), is_fraud BOOLEAN, fraud_type VARCHAR(50), fraud_score NUMERIC(18,4),
    flagged_at TIMESTAMP, etl_loaded_at TIMESTAMP DEFAULT NOW()
);
