-- EDA
select * from customers;
select * from restaurants;
select * from orders;
select * from riders;
select * from deliveries;

-- handling null values

SELECT *
FROM customers
WHERE customer_id IS NULL
   OR customer_name IS NULL
   OR reg_date IS NULL;

SELECT *
FROM restaurants
WHERE restaurant_id IS NULL
   OR restaurant_name IS NULL
   OR city IS NULL
   OR opening_hours IS NULL;

SELECT *
FROM riders
WHERE rider_id IS NULL
   OR rider_name IS NULL
   OR sign_up IS NULL;

SELECT *
FROM orders
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR restaurant_id IS NULL
   OR order_item IS NULL
   OR order_date IS NULL
   OR order_time IS NULL
   OR order_status IS NULL
   OR total_amount IS NULL;

SELECT *
FROM deliveries
WHERE delivery_id IS NULL
   OR order_id IS NULL
   OR delivery_status IS NULL
   OR delivery_time IS NULL
   OR rider_id IS NULL;

-- --------------------
-- Analysis and reports
-- --------------------

-- Q1
-- Top 5 most frequently ordered dishes by TOP 5 customerS (last 1 year)

SELECT o.order_item, COUNT(*) AS order_count
FROM orders o
WHERE o.customer_id = (
    SELECT customer_id
    FROM orders
    WHERE order_date >= CURDATE() - INTERVAL 1 YEAR
    GROUP BY customer_id
    ORDER BY COUNT(*) DESC
    LIMIT 5
)
AND o.order_date >= CURDATE() - INTERVAL 1 YEAR
GROUP BY o.order_item
ORDER BY order_count DESC
LIMIT 5;

-- Q2
-- High-value customers (top 10% by spending)

SELECT customer_id, customer_name, total_spent
FROM (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(o.total_amount) AS total_spent,
        NTILE(10) OVER (ORDER BY SUM(o.total_amount) DESC) AS spending_bucket
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
) t
WHERE spending_bucket = 1;



-- Q3
-- Orders placed but not delivered

SELECT r.restaurant_name, r.city,
       COUNT(*) AS not_delivered_orders
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE d.delivery_status <> 'Delivered'
GROUP BY r.restaurant_id, r.city;


-- Q4
-- Restaurant revenue ranking (last 1 year, city-wise)

SELECT restaurant_name, city, total_revenue,
       RANK() OVER (PARTITION BY city ORDER BY total_revenue DESC) AS city_rank
FROM (
    SELECT r.restaurant_id, r.restaurant_name, r.city,
           SUM(o.total_amount) AS total_revenue
    FROM restaurants r
    JOIN orders o ON r.restaurant_id = o.restaurant_id
    WHERE o.order_date >= CURDATE() - INTERVAL 1 YEAR
    GROUP BY r.restaurant_id
) t;



-- Q5
-- Most popular dish in each city

SELECT city, order_item, order_count
FROM (
    SELECT r.city, o.order_item,
           COUNT(*) AS order_count,
           RANK() OVER (PARTITION BY r.city ORDER BY COUNT(*) DESC) AS rk
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    GROUP BY r.city, o.order_item
) t
WHERE rk = 1;


-- Q6
-- Customer churn (ordered before but not in last 6 months)


SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING MAX(o.order_date) < CURDATE() - INTERVAL 6 MONTH;


-- Q7
-- Cancellation rate per restaurant (year-wise)


SELECT r.restaurant_name,
       YEAR(o.order_date) AS year,
       SUM(o.order_status = 'Cancelled') / COUNT(*) AS cancellation_rate
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, YEAR(o.order_date);


-- Q8
-- Rider average delivery time

SELECT r.rider_id, r.rider_name,
       SEC_TO_TIME(AVG(TIME_TO_SEC(d.delivery_time))) AS avg_delivery_time
FROM riders r
JOIN deliveries d ON r.rider_id = d.rider_id
WHERE d.delivery_status = 'Delivered'
GROUP BY r.rider_id;


-- Q9
-- Customer segmentation (Gold / Silver)

SELECT c.customer_id, c.customer_name,
       SUM(o.total_amount) AS total_spent,
       CASE
           WHEN SUM(o.total_amount) >
                (SELECT AVG(total_amount) FROM orders)
           THEN 'Gold'
           ELSE 'Silver'
       END AS segment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;


-- Q 10
-- Rider monthly earnings (8% commission)

SELECT r.rider_name,
       DATE_FORMAT(o.order_date,'%Y-%m') AS month,
       SUM(o.total_amount * 0.08) AS earnings
FROM riders r
JOIN deliveries d ON r.rider_id = d.rider_id
JOIN orders o ON d.order_id = o.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY r.rider_id, month;


-- Q 11
-- Rider ratings analysis (derived from delivery time)

SELECT rider_id,
       SUM(delivery_time < '00:15:00') AS five_star,
       SUM(delivery_time BETWEEN '00:15:00' AND '00:20:00') AS four_star,
       SUM(delivery_time > '00:20:00') AS three_star
FROM deliveries
GROUP BY rider_id;


-- Q 12
-- Peak order day per restaurant

SELECT restaurant_id, day_name, order_count
FROM (
    SELECT restaurant_id,
           DAYNAME(order_date) AS day_name,
           COUNT(*) AS order_count,
           RANK() OVER (
               PARTITION BY restaurant_id ORDER BY COUNT(*) DESC
           ) AS rk
    FROM orders
    GROUP BY restaurant_id, day_name
) t
WHERE rk = 1;


-- Q 13
-- Customer Lifetime Value (CLV)


SELECT c.customer_id, c.customer_name,
       SUM(o.total_amount) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;
