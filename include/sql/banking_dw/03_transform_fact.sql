TRUNCATE TABLE fact_transaction;
INSERT INTO fact_transaction (
    transaction_id, transaction_code, account_id, customer_id, branch_id, channel_id, date_id,
    transaction_at, transaction_type, amount, balance_before, balance_after, status, reference_no,
    is_fraud, fraud_type, fraud_score, flagged_at
)
SELECT
    t.transaction_id::INTEGER,
    t.transaction_code,
    t.account_id::INTEGER,
    t.customer_id::INTEGER,
    t.branch_id::INTEGER,
    t.channel_id::INTEGER,
    TO_CHAR(t.transaction_date::DATE, 'YYYYMMDD')::INTEGER AS date_id,
    t.transaction_at::TIMESTAMP,
    t.transaction_type,
    t.amount::NUMERIC(18,2),
    t.balance_before::NUMERIC(18,2),
    t.balance_after::NUMERIC(18,2),
    t.status,
    t.reference_no,
    COALESCE(CASE WHEN LOWER(f.is_fraud) = 'true' THEN TRUE ELSE FALSE END, FALSE) AS is_fraud,
    f.fraud_type,
    NULLIF(f.fraud_score, '')::NUMERIC(18,4) AS fraud_score,
    NULLIF(f.flagged_at, '')::TIMESTAMP AS flagged_at
FROM stg_transaction t
LEFT JOIN stg_fraud_labels f
ON t.transaction_id = f.transaction_id;
