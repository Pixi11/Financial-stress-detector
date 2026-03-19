-- A virtual table that combines all 4 tables via JOIN
CREATE VIEW v_analysis AS
SELECT
    t.user_id, t.time_id,
    CASE
        WHEN u.age < 30 THEN '20s'
        WHEN u.age < 40 THEN '30s'
        WHEN u.age < 50 THEN '40s'
        ELSE '50+'
    END AS age_group,
    CASE u.education
        WHEN 'graduate'    THEN 'Graduate'
        WHEN 'university'  THEN 'University'
        WHEN 'high_school' THEN 'High School'
        WHEN 'others'      THEN 'Others'
        ELSE u.education
    END AS education,
    u.marriage, u.gender, u.credit_limit,
    t.bill_amount, t.payment_amount, t.payment_ratio,
    t.repayment_status, t.defaulted_next_month,
    m.inflation_rate, m.unemployment_rate,
    m.interest_rate, m.consumer_confidence
FROM fact_transactions t
JOIN dim_users u          ON t.user_id = u.user_id
JOIN dim_time d           ON t.time_id = d.time_id
JOIN fact_macro_indicators m ON t.time_id = m.time_id;


-- A virtual table for stress labels
CREATE VIEW v_stress_users AS
SELECT
    t.user_id, t.time_id,
    CASE
        WHEN u.age < 30 THEN '20s'
        WHEN u.age < 40 THEN '30s'
        WHEN u.age < 50 THEN '40s'
        ELSE '50+'
    END AS age_group,
    CASE u.education
        WHEN 'graduate'    THEN 'Graduate'
        WHEN 'university'  THEN 'University'
        WHEN 'high_school' THEN 'High School'
        WHEN 'others'      THEN 'Others'
        ELSE u.education
    END AS education,
    u.marriage, u.gender,
    t.repayment_status, t.payment_ratio,
    t.bill_amount, t.payment_amount,
    t.defaulted_next_month,
    m.inflation_rate, m.unemployment_rate,
    m.interest_rate, m.consumer_confidence,
    CASE
        WHEN t.repayment_status >= 2
         AND t.payment_ratio    <  0.1
         AND t.bill_amount      > 50000  THEN 'High Stress'
        WHEN t.repayment_status >= 1
         AND t.payment_ratio    <  0.3   THEN 'Medium Stress'
        ELSE 'Normal'
    END AS stress_label
FROM fact_transactions t
JOIN dim_users u             ON t.user_id = u.user_id
JOIN fact_macro_indicators m ON t.time_id = m.time_id;


--  Overall stress distribution
SELECT
    stress_label,
    COUNT(*) AS total_rows,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM v_stress_users
GROUP BY stress_label
ORDER BY total_rows DESC;

--Top 10 riskiest age + education groups
SELECT
    age_group,
    education,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN stress_label = 'HIGH STRESS'
             THEN 1 ELSE 0 END) AS high_stress_count,
    ROUND(AVG(payment_ratio):: NUMERIC * 100, 1) AS avg_payment_pct,
    ROUND(AVG(defaulted_next_month::FLOAT)::NUMERIC * 100, 1) AS default_rate_pct
FROM v_stress_users
GROUP BY age_group, education
ORDER BY high_stress_count DESC
LIMIT 10;

--Monthly stress trend
SELECT
    time_id,
    stress_label,
    COUNT(*) AS n_rows,
    ROUND(COUNT(*) * 100.0 /
          SUM(COUNT(*)) OVER (PARTITION BY time_id), 1)  AS pct_of_month
FROM v_stress_users
GROUP BY time_id, stress_label
ORDER BY time_id, stress_label;
