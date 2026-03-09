-- Create Table
CREATE TABLE raw.ecom_events (
    event_time TEXT,
    event_type TEXT,
    product_id TEXT,
    category_id TEXT,
    category_code TEXT,
    brand TEXT,
    price TEXT,
    user_id TEXT,
    user_session TEXT
);

SELECT COUNT(*) FROM raw.ecom_events;

-- Dateset Overview
SELECT
	COUNT(*) AS total_events,
	COUNT(DISTINCT user_id) AS total_users,
	COUNT(DISTINCT user_session) AS total_sessions,
	COUNT(DISTINCT product_id) AS total_products
FROM raw.ecom_events;

-- Event Type Distribution
SELECT
	event_type,
	COUNT(*) AS events
FROM raw.ecom_events
GROUP BY event_type
ORDER BY events DESC;

-- Funnel Metrics
SELECT
	COUNT(CASE WHEN event_type = 'view' THEN 1 END) AS views,
	COUNT(CASE WHEN event_type = 'cart' THEN 1 END) AS carts,
	COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS purchases
FROM raw.ecom_events;

-- Funnel Coversion Rate
WITH funnel AS (
SELECT
	COUNT(CASE WHEN event_type = 'view' THEN 1 END) AS views,
	COUNT(CASE WHEN event_type = 'cart' THEN 1 END) AS carts,
	COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS purchases
FROM raw.ecom_events
)
SELECT
	views,
	carts,
	purchases,
	ROUND(carts::numeric / views,4) AS view_to_cart_rate,
	ROUND(purchases::numeric / carts,4) AS cart_to_purchase_rate,
	ROUND(purchases::numeric / views,4) AS view_to_purchase_rate
FROM funnel;

-- Revenue Overview
SELECT
    COUNT(*) AS total_orders,
    ROUND(SUM(price::numeric),2) AS total_revenue,
    ROUND(AVG(price::numeric),2) AS avg_order_value
FROM raw.ecom_events
WHERE event_type='purchase';

-- Revenue by Category
SELECT
	category_code,
	COUNT(*) AS purchases,
	ROUND(SUM(price::numeric),2) AS revenue,
	ROUND(AVG(price::numeric),2) AS avg_price
FROM raw.ecom_events
WHERE event_type='purchase'
AND category_code IS NOT NULL
GROUP BY category_code
ORDER BY revenue DESC
LIMIT 10;

-- Top Brands
SELECT
    brand,
    COUNT(*) AS purchases,
    ROUND(SUM(price::numeric),2) AS revenue
FROM raw.ecom_events
WHERE event_type='purchase'
AND brand IS NOT NULL
GROUP BY brand
ORDER BY revenue DESC
LIMIT 10;