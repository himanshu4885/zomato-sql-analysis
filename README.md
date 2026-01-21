# 🍽️ Zomato Data Analysis using SQL

## 📌 Project Overview
This project demonstrates a **Zomato-like food delivery data analysis system** built using **MySQL**.
It focuses on **database design, data integrity, and advanced SQL analytics** using a large-scale dataset.

The project simulates how food delivery platforms analyze:
- Customer behavior
- Restaurant performance
- Order trends
- Delivery and rider efficiency

---

## 🧱 Database Schema

### 📂 Tables Used
- customers  
- restaurants  
- orders  
- riders  
- deliveries  

### 🔗 Relationships
- One customer → many orders  
- One restaurant → many orders  
- One order → one delivery  
- One rider → many deliveries  

All relationships are enforced using **foreign key constraints**.

---

## 🛠️ Tech Stack
- **Database:** MySQL  
- **Query Language:** SQL  
- **Tool:** MySQL Workbench  

Concepts:
- Relational Database Design
- Joins & Subqueries
- Window Functions (RANK, NTILE)
- Aggregations
- Foreign Keys

---

## 🧪 Database Creation & Table Schema

```sql
CREATE DATABASE IF NOT EXISTS zomato_db;
USE zomato_db;

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(30),
  reg_date DATE
);

CREATE TABLE restaurants (
  restaurant_id INT PRIMARY KEY,
  restaurant_name VARCHAR(60),
  city VARCHAR(30),
  opening_hours VARCHAR(50)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  restaurant_id INT,
  order_item VARCHAR(60),
  order_date DATE,
  order_time TIME,
  order_status VARCHAR(55),
  total_amount FLOAT,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE riders (
  rider_id INT PRIMARY KEY,
  rider_name VARCHAR(60),
  sign_up DATE
);

CREATE TABLE deliveries (
  delivery_id INT PRIMARY KEY,
  order_id INT,
  delivery_status VARCHAR(40),
  delivery_time TIME,
  rider_id INT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
);
```

---

## 🔍 Exploratory Data Analysis (EDA)

```sql
SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM orders;
SELECT * FROM riders;
SELECT * FROM deliveries;
```

### ✅ NULL Value Checks
NULL checks were performed on all tables to ensure data quality and consistency.

---

## 📊 Key SQL Analysis Queries

### 🔹 High-value customers (Top 10% by spending)
```sql
SELECT customer_id, customer_name, total_spent
FROM (
  SELECT c.customer_id, c.customer_name,
         SUM(o.total_amount) AS total_spent,
         NTILE(10) OVER (ORDER BY SUM(o.total_amount) DESC) AS spending_bucket
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  GROUP BY c.customer_id, c.customer_name
) t
WHERE spending_bucket = 1;
```

### 🔹 Orders placed but not delivered
```sql
SELECT r.restaurant_name, r.city, COUNT(*) AS not_delivered_orders
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE d.delivery_status <> 'Delivered'
GROUP BY r.restaurant_id, r.city;
```

### 🔹 Restaurant revenue ranking (city-wise)
```sql
SELECT restaurant_name, city, total_revenue,
       RANK() OVER (PARTITION BY city ORDER BY total_revenue DESC) AS city_rank
FROM (
  SELECT r.restaurant_id, r.restaurant_name, r.city,
         SUM(o.total_amount) AS total_revenue
  FROM restaurants r
  JOIN orders o ON r.restaurant_id = o.restaurant_id
  GROUP BY r.restaurant_id
) t;
```

> 📌 Additional analysis queries (customer churn, CLV, rider performance, peak days, etc.)
> are included in the `queries.sql` file for better readability.

---

## 📂 Repository Structure

```
├── README.md
├── schema.sql
├── queries.sql
├── data/
│   ├── customers.csv
│   ├── restaurants.csv
│   ├── riders.csv
│   ├── orders.csv
│   └── deliveries.csv
```

---

## 🎯 Learning Outcomes
- Designed a normalized relational database
- Worked with large datasets in MySQL
- Performed business analytics using SQL
- Applied window functions for ranking and trends
- Ensured referential integrity with foreign keys

---

## 🚀 Future Enhancements
- Add indexes for performance
- Create SQL views
- Integrate with visualization tools

---

⭐ If you find this project useful, feel free to star the repository!
