CREATE DATABASE funnel_analysis;
USE funnel_analysis;

-- Table creation
CREATE TABLE funnel_events(
	user_id VARCHAR(10),
    step VARCHAR(30),
    event_timestamp DATETIME
);
 
SELECT * FROM funnel_events;

-- Conversion rate

WITH stage_counts AS (
SELECT
	step,
	COUNT(DISTINCT user_id) AS unique_users,
	CASE step
		WHEN 'visited_site' THEN 1
		WHEN 'signup_started' THEN 2
		WHEN 'details_filled' THEN 3
		WHEN 'email_verified' THEN 4
		WHEN 'purchase_completed' THEN 5
	END AS step_order
FROM funnel_events
GROUP BY step
)
SELECT
    step,
    unique_users,
    ROUND(unique_users * 100.0 /
        LAG(unique_users) OVER (ORDER BY step_order),
        2
    ) AS conversion_rate,
    LAG(unique_users) OVER(ORDER BY step_order ASC) - unique_users AS drop_off
FROM stage_counts
ORDER BY step_order;

-- Biggest_dropoff

WITH stage_counts AS (
SELECT
	step,
	COUNT(DISTINCT user_id) AS unique_users,
	CASE step
		WHEN 'visited_site' THEN 1
		WHEN 'signup_started' THEN 2
		WHEN 'details_filled' THEN 3
		WHEN 'email_verified' THEN 4
		WHEN 'purchase_completed' THEN 5
	END AS step_order
FROM funnel_events
GROUP BY step
),
funnel AS (
SELECT
	*,
	LAG(unique_users) OVER (ORDER BY step_order) - unique_users AS users_lost
FROM stage_counts
)
SELECT
	step,
    users_lost AS biggest_dropoff_stage
FROM funnel
WHERE users_lost = (
    SELECT MAX(users_lost)
    FROM funnel
);
    