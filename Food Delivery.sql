-- ============================
-- FOOD DELIVERY ANALYTICS DB
-- Works in SQLite / PostgreSQL
-- ============================

-- Drop old objects (safe for reruns)
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS couriers;

-- Core tables
CREATE TABLE customers (
  customer_id   INTEGER PRIMARY KEY,
  full_name     TEXT    NOT NULL,
  city          TEXT    NOT NULL,
  created_at    DATE    NOT NULL
);

CREATE TABLE restaurants (
  restaurant_id INTEGER PRIMARY KEY,
  name          TEXT    NOT NULL,
  city          TEXT    NOT NULL,
  cuisine       TEXT    NOT NULL,
  opened_at     DATE    NOT NULL
);

CREATE TABLE menu_items (
  item_id       INTEGER PRIMARY KEY,
  restaurant_id INTEGER NOT NULL REFERENCES restaurants(restaurant_id),
  item_name     TEXT    NOT NULL,
  category      TEXT    NOT NULL,        -- e.g., Main, Side, Drink, Dessert
  price         NUMERIC NOT NULL CHECK (price >= 0)
);

CREATE TABLE orders (
  order_id      INTEGER PRIMARY KEY,
  customer_id   INTEGER NOT NULL REFERENCES customers(customer_id),
  restaurant_id INTEGER NOT NULL REFERENCES restaurants(restaurant_id),
  order_ts      TIMESTAMP NOT NULL,
  status        TEXT NOT NULL            -- Placed, Preparing, Delivered, Cancelled
);

CREATE TABLE order_items (
  order_id INTEGER NOT NULL REFERENCES orders(order_id),
  item_id  INTEGER NOT NULL REFERENCES menu_items(item_id),
  qty      INTEGER NOT NULL CHECK (qty > 0),
  PRIMARY KEY (order_id, item_id)
);

CREATE TABLE couriers (
  courier_id INTEGER PRIMARY KEY,
  full_name  TEXT NOT NULL,
  vehicle    TEXT NOT NULL               -- Bike, Scooter, Car
);

CREATE TABLE deliveries (
  order_id   INTEGER PRIMARY KEY REFERENCES orders(order_id),
  courier_id INTEGER NOT NULL REFERENCES couriers(courier_id),
  pickup_ts  TIMESTAMP NOT NULL,
  drop_ts    TIMESTAMP,                  -- NULL if not yet delivered/cancelled
  distance_km NUMERIC NOT NULL CHECK (distance_km >= 0)
);

CREATE TABLE ratings (
  rating_id   INTEGER PRIMARY KEY,
  order_id    INTEGER NOT NULL REFERENCES orders(order_id),
  customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
  rating      INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT
);

-- Seed data
INSERT INTO customers VALUES
 (1,'Aarav Sharma','Bengaluru','2024-01-12'),
 (2,'Isha Verma','Hyderabad','2024-02-03'),
 (3,'Rohan Gupta','Chennai','2024-03-20'),
 (4,'Meera Nair','Bengaluru','2024-04-01'),
 (5,'Vikram Rao','Chennai','2024-04-18');

INSERT INTO restaurants VALUES
 (101,'Tandoori Tales','Bengaluru','North Indian','2023-10-01'),
 (102,'Dosa Hub','Chennai','South Indian','2022-08-15'),
 (103,'Wrap&Roll','Hyderabad','Fast Food','2024-01-05');

INSERT INTO menu_items VALUES
 (1001,101,'Butter Chicken','Main',320),
 (1002,101,'Garlic Naan','Side',40),
 (1003,101,'Gulab Jamun','Dessert',90),
 (1004,102,'Masala Dosa','Main',120),
 (1005,102,'Idli (2 pcs)','Main',60),
 (1006,102,'Filter Coffee','Drink',45),
 (1007,103,'Veg Wrap','Main',150),
 (1008,103,'Chicken Roll','Main',190),
 (1009,103,'Lemon Soda','Drink',50),
 (1010,103,'Brownie','Dessert',110);

INSERT INTO couriers VALUES
 (201,'Karan Singh','Bike'),
 (202,'Divya Rao','Scooter'),
 (203,'Sanjay Patel','Bike');

-- Orders (spread across months)
INSERT INTO orders VALUES
 (5001,1,101,'2025-05-01 12:10','Delivered'),
 (5002,2,103,'2025-05-01 13:25','Delivered'),
 (5003,3,102,'2025-05-02 09:05','Delivered'),
 (5004,4,101,'2025-05-02 20:00','Delivered'),
 (5005,5,102,'2025-05-03 08:40','Cancelled'),
 (5006,1,103,'2025-05-04 19:10','Delivered'),
 (5007,2,102,'2025-06-01 08:50','Delivered'),
 (5008,3,101,'2025-06-02 13:00','Delivered'),
 (5009,4,103,'2025-06-05 21:15','Delivered'),
 (5010,5,102,'2025-06-06 07:55','Delivered'),
 (5011,1,101,'2025-07-10 12:35','Delivered'),
 (5012,2,103,'2025-07-12 18:45','Preparing');

-- Order items
INSERT INTO order_items VALUES
 (5001,1001,1),(5001,1002,4),(5001,1003,1);
INSERT INTO order_items VALUES
 (5002,1008,2),(5002,1009,2);
INSERT INTO order_items VALUES
 (5003,1004,1),(5003,1006,1);
INSERT INTO order_items VALUES
 (5004,1001,2),(5004,1002,6);
INSERT INTO order_items VALUES
 (5005,1004,1),(5005,1006,2);
INSERT INTO order_items VALUES
 (5006,1007,1),(5006,1010,1);
INSERT INTO order_items VALUES
 (5007,1004,2),(5007,1006,2);
INSERT INTO order_items VALUES
 (5008,1001,1),(5008,1003,2);
INSERT INTO order_items VALUES
 (5009,1008,1),(5009,1009,1),(5009,1010,1);
INSERT INTO order_items VALUES
 (5010,1005,2),(5010,1006,2);
INSERT INTO order_items VALUES
 (5011,1001,1),(5011,1002,2),(5011,1003,1);
INSERT INTO order_items VALUES
 (5012,1007,2),(5012,1009,2);

-- Deliveries (omit cancelled order 5005; 5012 not dropped yet)
INSERT INTO deliveries VALUES
 (5001,201,'2025-05-01 12:20','2025-05-01 12:50',5.2),
 (5002,202,'2025-05-01 13:35','2025-05-01 13:55',3.0),
 (5003,203,'2025-05-02 09:15','2025-05-02 09:40',4.1),
 (5004,202,'2025-05-02 20:10','2025-05-02 20:45',6.0),
 (5006,201,'2025-05-04 19:20','2025-05-04 19:50',5.6),
 (5007,203,'2025-06-01 08:58','2025-06-01 09:20',4.0),
 (5008,201,'2025-06-02 13:10','2025-06-02 13:40',5.8),
 (5009,202,'2025-06-05 21:25','2025-06-05 21:40',2.5),
 (5010,203,'2025-06-06 08:05','2025-06-06 08:25',3.8),
 (5011,201,'2025-07-10 12:45','2025-07-10 13:05',3.2),
 (5012,203,'2025-07-12 18:55',NULL,4.4);

-- Ratings (only for delivered orders)
INSERT INTO ratings VALUES
 (9001,5001,1,5,'Hot and tasty'),
 (9002,5002,2,4,'Good, quick'),
 (9003,5003,3,5,'Crispy dosa!'),
 (9004,5004,4,3,'Too spicy'),
 (9005,5006,1,4,'Nice brownie'),
 (9006,5007,2,5,'Perfect breakfast'),
 (9007,5008,3,4,'Loved dessert'),
 (9008,5009,4,5,'All-in-one combo'),
 (9009,5010,5,4,'Simple & nice'),
 (9010,5011,1,5,'My favorite spot');

-- Helpful views (optional)
CREATE VIEW v_order_value AS
SELECT
  oi.order_id,
  SUM(oi.qty * mi.price) AS order_value
FROM order_items oi
JOIN menu_items mi ON mi.item_id = oi.item_id
GROUP BY oi.order_id;

-- ============================
-- QUERIES / EXERCISES
-- ============================

-- 1) Total GMV (revenue) from delivered orders
SELECT SUM(v.order_value) AS total_gmv
FROM orders o
JOIN v_order_value v ON v.order_id = o.order_id
WHERE o.status = 'Delivered';

-- 2) Top 5 best-selling items
SELECT mi.item_name, SUM(oi.qty) AS units_sold
FROM order_items oi
JOIN menu_items mi ON mi.item_id = oi.item_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY mi.item_name
ORDER BY units_sold DESC
LIMIT 5;

-- 3) Average order value by restaurant
SELECT r.name, ROUND(AVG(v.order_value),2) AS avg_order_value
FROM orders o
JOIN v_order_value v ON v.order_id = o.order_id
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
WHERE o.status = 'Delivered'
GROUP BY r.name
ORDER BY avg_order_value DESC;

-- 4) Customer lifetime value (simple: sum of delivered order totals)
SELECT c.full_name, ROUND(SUM(v.order_value),2) AS clv
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN v_order_value v ON v.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY c.full_name
ORDER BY clv DESC;

-- 5) On-time delivery duration (minutes) per courier (drop - pickup)
SELECT cr.full_name AS courier, ROUND(AVG((strftime('%s',d.drop_ts)-strftime('%s',d.pickup_ts))/60.0),1) AS avg_minutes
FROM deliveries d
JOIN couriers cr ON cr.courier_id = d.courier_id
JOIN orders o ON o.order_id = d.order_id
WHERE o.status = 'Delivered'
GROUP BY cr.full_name
ORDER BY avg_minutes;

-- 6) Restaurant ratings (avg)
SELECT r.name, ROUND(AVG(rt.rating),2) AS avg_rating, COUNT(*) AS ratings_count
FROM ratings rt
JOIN orders o ON o.order_id = rt.order_id
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY r.name
ORDER BY avg_rating DESC, ratings_count DESC;

-- 7) Month-over-month GMV
SELECT strftime('%Y-%m', o.order_ts) AS ym, ROUND(SUM(v.order_value),2) AS gmv
FROM orders o
JOIN v_order_value v ON v.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY ym
ORDER BY ym;

-- 8) Conversion: placed vs delivered count
SELECT status, COUNT(*) AS orders
FROM orders
GROUP BY status;

-- 9) City split of delivered orders
SELECT c.city, COUNT(*) AS delivered_orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'Delivered'
GROUP BY c.city
ORDER BY delivered_orders DESC;

-- 10) Basket size distribution (items per order)
SELECT o.order_id, SUM(oi.qty) AS total_items
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status IN ('Delivered','Preparing')
GROUP BY o.order_id
ORDER BY total_items DESC;

-- 11) Most profitable item per restaurant
WITH item_sales AS (
  SELECT mi.restaurant_id, mi.item_id, mi.item_name,
         SUM(oi.qty) AS units, SUM(oi.qty*mi.price) AS revenue
  FROM order_items oi
  JOIN menu_items mi ON mi.item_id = oi.item_id
  JOIN orders o ON o.order_id = oi.order_id
  WHERE o.status = 'Delivered'
  GROUP BY mi.restaurant_id, mi.item_id, mi.item_name
)
SELECT r.name AS restaurant, item_name, units, revenue
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY restaurant_id ORDER BY revenue DESC) AS rn
  FROM item_sales
) x
JOIN restaurants r ON r.restaurant_id = x.restaurant_id
WHERE rn = 1
ORDER BY revenue DESC;

-- 12) Repeat customers (>=2 delivered orders)
SELECT c.full_name, COUNT(*) AS delivered_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status='Delivered'
GROUP BY c.full_name
HAVING COUNT(*) >= 2
ORDER BY delivered_orders DESC;

-- 13) Average delivery distance by city of restaurant
SELECT r.city, ROUND(AVG(d.distance_km),2) AS avg_km
FROM deliveries d
JOIN orders o ON o.order_id = d.order_id
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
WHERE o.status='Delivered'
GROUP BY r.city;

-- 14) Time-of-day breakdown (hourly delivered order counts)
SELECT CAST(strftime('%H', o.order_ts) AS INTEGER) AS hour_of_day,
       COUNT(*) AS delivered_count
FROM orders o
WHERE o.status='Delivered'
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 15) Customers with no ratings given
SELECT DISTINCT c.full_name
FROM customers c
LEFT JOIN ratings rt ON rt.customer_id = c.customer_id
WHERE rt.rating_id IS NULL;

-- 16) Average rating per cuisine
SELECT r.cuisine, ROUND(AVG(rt.rating),2) AS avg_rating
FROM ratings rt
JOIN orders o ON o.order_id = rt.order_id
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY r.cuisine
ORDER BY avg_rating DESC;

-- 17) Orders that are prepared but not yet delivered (live queue)
SELECT o.order_id, c.full_name AS customer, r.name AS restaurant, o.order_ts
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
WHERE o.status='Preparing'
ORDER BY o.order_ts;

-- 18) Top cities by GMV (based on customer city)
SELECT c.city, ROUND(SUM(v.order_value),2) AS gmv
FROM orders o
JOIN v_order_value v ON v.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status='Delivered'
GROUP BY c.city
ORDER BY gmv DESC;

-- 19) Menu gaps: restaurants without desserts
SELECT r.name
FROM restaurants r
LEFT JOIN menu_items mi
  ON mi.restaurant_id = r.restaurant_id AND mi.category='Dessert'
GROUP BY r.name
HAVING COUNT(mi.item_id)=0;

-- 20) “Recommended” item per restaurant (highest units sold)
WITH tally AS (
  SELECT mi.restaurant_id, mi.item_name, SUM(oi.qty) AS units
  FROM order_items oi
  JOIN menu_items mi ON mi.item_id = oi.item_id
  JOIN orders o ON o.order_id = oi.order_id
  WHERE o.status='Delivered'
  GROUP BY mi.restaurant_id, mi.item_name
)
SELECT r.name AS restaurant, t.item_name AS recommended_item, t.units
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY restaurant_id ORDER BY units DESC) rn
  FROM tally
) t
JOIN restaurants r ON r.restaurant_id = t.restaurant_id
WHERE rn = 1
ORDER BY r.name;
