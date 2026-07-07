-- 03. Branch Performance
-- Highest performing branches based on transactions and value per region
-- ------------------------------------------------------------------------------
SELECT
    b.region,
    b.branch_name,
    COUNT(f.transaction_id) AS total_transactions,
    SUM(f.amount) AS total_transaction_value
FROM fact_transaction f
JOIN dim_branches b ON f.branch_id = b.branch_id
WHERE f.status = 'SUCCESS'
GROUP BY
    b.region, b.branch_name
ORDER BY
    b.region, total_transaction_value DESC;