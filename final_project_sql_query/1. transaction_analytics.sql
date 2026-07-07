-- 01. Transaction Analytics
-- Total volume and transaction value per day, week, and month.
-- ------------------------------------------------------------------------------
SELECT
    d.year,
    d.month,
    d.week_of_year,
    d.full_date,
    COUNT(f.transaction_id) AS total_volume,
    SUM(f.amount) AS total_value
FROM fact_transaction f
JOIN dim_date d ON f.date_id = d.date_id
WHERE f.status = 'SUCCESS'
GROUP BY
    d.year, d.month, d.week_of_year, d.full_date
ORDER BY
    d.full_date;