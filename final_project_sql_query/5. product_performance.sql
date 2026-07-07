-- 05. Product Performance
-- Account products generating highest volume and average balance
-- ------------------------------------------------------------------------------
SELECT
    a.account_type,
    a.product_name,
    COUNT(f.transaction_id) AS total_transactions,
    SUM(f.amount) AS total_transaction_value,
    AVG(f.balance_after) AS avg_balance
FROM fact_transaction f
JOIN dim_accounts a ON f.account_id = a.account_id
WHERE f.status = 'SUCCESS'
GROUP BY
    a.account_type, a.product_name
ORDER BY
    total_transaction_value DESC;