WITH weekly_cohort AS (
  -- Assign each subscription to a cohort based on the week of their subscription start date
  SELECT
    user_pseudo_id,
    category,
    country,
    subscription_start,
    subscription_end,
    DATE_TRUNC(subscription_start, WEEK(MONDAY)) AS cohort_week -- Week start on Monday
  FROM
    `tc-da-1.turing_data_analytics.subscriptions`
),
retention_table AS (
  -- Calculate Active subscribers across the following 6 weeks
  SELECT
    cohort_week,
    COUNT(user_pseudo_id) AS week_0,
    COUNT(CASE WHEN DATE_ADD(cohort_week, INTERVAL 1 WEEK) <= subscription_end OR subscription_end IS NULL THEN user_pseudo_id END) AS week_1,
    COUNT(CASE WHEN DATE_ADD(cohort_week, INTERVAL 2 WEEK) <= subscription_end OR subscription_end IS NULL THEN user_pseudo_id END) AS week_2,
    COUNT(CASE WHEN DATE_ADD(cohort_week, INTERVAL 3 WEEK) <= subscription_end OR subscription_end IS NULL THEN user_pseudo_id END) AS week_3,
    COUNT(CASE WHEN DATE_ADD(cohort_week, INTERVAL 4 WEEK) <= subscription_end OR subscription_end IS NULL THEN user_pseudo_id END) AS week_4,
    COUNT(CASE WHEN DATE_ADD(cohort_week, INTERVAL 5 WEEK) <= subscription_end OR subscription_end IS NULL THEN user_pseudo_id END) AS week_5,
    COUNT(CASE WHEN DATE_ADD(cohort_week, INTERVAL 6 WEEK) <= subscription_end OR subscription_end IS NULL THEN user_pseudo_id END) AS week_6
  FROM
    weekly_cohort
  GROUP BY
    cohort_week
  ORDER BY
    cohort_week
),
churn_table AS (
  -- Calculate churn as the difference between active users each week
  SELECT
    cohort_week,
    0 AS churn_week_0, -- No churn in week 0 as it's the start
    week_0 - week_1 AS churn_week_1,
    week_1 - week_2 AS churn_week_2,
    week_2 - week_3 AS churn_week_3,
    week_3 - week_4 AS churn_week_4,
    week_4 - week_5 AS churn_week_5,
    week_5 - week_6 AS churn_week_6
  FROM
    retention_table
),
retention_Rate AS (
  -- Calculate retention rates
  SELECT
    cohort_week,
    100 AS initial_subscribers,  
    ROUND((week_1 * 100.0 / week_0),2) AS retention_Week_1,
    ROUND((week_2 * 100.0 / week_0),2) AS retention_Week_2,
    ROUND((week_3 * 100.0 / week_0),2) AS retention_week_3,
    ROUND((week_4 * 100.0 / week_0),2) AS retention_week_4,
    ROUND((week_5 * 100.0 / week_0),2) AS retention_week_5,
    ROUND((week_6 * 100.0 / week_0),2) AS retention_week_6
  FROM
    retention_table
),
--  -- Calculate churn rate
Churn_rate AS (
  SELECT 
  cohort_week,
  0 AS churn_rate_week_0,  -- No churn in week 0
    (week_0 - week_1) * 100.0 / week_0 AS churn_rate_week_1,
    (week_1 - week_2) * 100.0 / week_0 AS churn_rate_week_2,
    (week_2 - week_3) * 100.0 / week_0 AS churn_rate_week_3,
    (week_3 - week_4) * 100.0 / week_0 AS churn_rate_week_4,
    (week_4 - week_5) * 100.0 / week_0 AS churn_rate_week_5,
    (week_5 - week_6) * 100.0 / week_0 AS churn_rate_week_6
    FROM 
    retention_table
)
SELECT *
FROM Churn_rate;
