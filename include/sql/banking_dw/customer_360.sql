-- 02. Customer 360
-- Most active customers based on frequency and value, & distribution per segment
-- ------------------------------------------------------------------------------
-- Top 10 Most Active Customers
SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    COUNT(f.transaction_id) AS transaction_frequency,
    SUM(f.amount) AS total_transaction_value
FROM fact_transaction f
JOIN dim_customers c ON f.customer_id = c.customer_id
WHERE f.status = 'SUCCESS'
GROUP BY
    c.customer_id, c.full_name, c.segment
ORDER BY
    total_transaction_value DESC, transaction_frequency DESC
LIMIT 10;

-- Distribution by Customer Segment
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(f.transaction_id) AS total_transactions,
    SUM(f.amount) AS total_transaction_value
FROM dim_customers c
LEFT JOIN fact_transaction f ON c.customer_id = f.customer_id AND f.status = 'SUCCESS'
GROUP BY
    c.segment
ORDER BY 
    total_transaction_value DESC;