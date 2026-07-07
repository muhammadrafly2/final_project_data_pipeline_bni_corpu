-- 04. Channel Analysis
-- Most used channels and migration trends to digital
-- ------------------------------------------------------------------------------
-- Most used Channels
SELECT
    c.channel_category,
    c.channel_name,
    c.is_digital,
    COUNT(f.transaction_id) AS total_volume,
    SUM(f.amount) AS total_value
FROM fact_transaction f
JOIN dim_channels c ON f.channel_id = c.channel_id
WHERE f.status = 'SUCCESS'
GROUP BY
    c.channel_category, c.channel_name, c.is_digital
ORDER BY
    total_volume DESC;

-- Monthly Digital vs Non-Digital Trend
SELECT
    d.year,
    d.month,
    c.is_digital,
    COUNT(f.transaction_id) AS total_transactions,
    SUM(f.amount) AS total_value
FROM fact_transaction f
JOIN dim_channels c ON f.channel_id = c.channel_id
JOIN dim_date d ON f.date_id = d.date_id
WHERE f.status = 'SUCCESS'
GROUP BY
    d.year, d.month, c.is_digital
ORDER BY
    d.year, d.month, c.is_digital;