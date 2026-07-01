TRUNCATE TABLE dim_channels;
INSERT INTO dim_channels (channel_id, channel_code, channel_name, channel_category, is_digital, description)
SELECT
    channel_id::INTEGER,
    channel_code,
    channel_name,
    channel_category,
    CASE WHEN LOWER(is_digital) = 'true' THEN TRUE ELSE FALSE END,
    description
FROM stg_channels;

TRUNCATE TABLE dim_branches;
INSERT INTO dim_branches (branch_id, branch_code, branch_name, city, province, region, branch_type, open_date, is_active)
SELECT
    branch_id::INTEGER,
    branch_code,
    branch_name,
    city,
    province,
    region,
    branch_type,
    NULLIF(open_date, '')::DATE,
    CASE WHEN LOWER(is_active) = 'true' THEN TRUE ELSE FALSE END
FROM stg_branches;

TRUNCATE TABLE dim_accounts;
INSERT INTO dim_accounts (account_id, account_no, account_type, product_name, currency, open_date, close_date, status, interest_rate, customer_id, branch_id)
SELECT
    account_id::INTEGER,
    account_no,
    account_type,
    product_name,
    currency,
    NULLIF(open_date, '')::DATE,
    NULLIF(close_date, '')::DATE,
    status,
    NULLIF(interest_rate, '')::NUMERIC,
    customer_id::INTEGER,
    branch_id::INTEGER
FROM stg_accounts;
