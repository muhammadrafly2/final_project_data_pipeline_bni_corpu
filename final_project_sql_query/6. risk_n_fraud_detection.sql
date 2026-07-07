-- 06. Risk & Fraud Detection
-- Anomalous transactions and identified frauds
-- ------------------------------------------------------------------------------
SELECT
    f.transaction_id,
    f.transaction_code,
    c.full_name,
    ch.channel_name,
    f.amount,
    f.status,
    f.is_fraud,
    f.fraud_type,
    f.fraud_score,
    f.flagged_at
FROM fact_transaction f
JOIN dim_customers c ON f.customer_id = c.customer_id
JOIN dim_channels ch ON f.channel_id = ch.channel_id
-- Filter for explicitly labeled frauds OR potentially anomalous behavior
-- (e.g. FAILED status but extremely high amount)
WHERE f.is_fraud = TRUE
   OR (f.status = 'FAILED' AND f.amount > 50000000) 
ORDER BY
    f.fraud_score DESC NULLS LAST, f.amount DESC;