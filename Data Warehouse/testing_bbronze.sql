/*
============================================================
BRONZE LAYER — DATA QUALITY & EXPLORATORY CHECKS
============================================================

DESCRIPTION
------------------------------------------------------------
This SQL script performs preliminary data exploration and 
quality checks on the raw Bronze Layer tables (customer, 
product, store, and sales). It is intended to:

1. Inspect all table contents.
2. Identify duplicate records.
3. Detect unwanted spaces and inconsistent formatting.
4. Check for NULL or blank values.
5. Review distinct values for standardization and consistency.

This step ensures that any anomalies are identified before 
loading and cleaning the data into the Silver Layer.
============================================================
*/

-- 1) customer table
SELECT * FROM bbronze.customer;

-- Checking for Duplicate values
SELECT customer_id, COUNT(*) AS duplicates
FROM bbronze.customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Checking for unwanted spaces
SELECT gender 
FROM bbronze.customer
WHERE gender <> TRIM(gender);

SELECT city
FROM bbronze.customer
WHERE city <> TRIM(city);

SELECT email
FROM bbronze.customer
WHERE email <> TRIM(email);

-- Standardization & Consistency
-- Checking distinct values in gender and city columns 
SELECT DISTINCT gender
FROM bbronze.customer;

SELECT DISTINCT city 
FROM bbronze.customer;

-- Checking for NULL and Blank Values
SELECT *
FROM bbronze.customer
WHERE customer_id =''
OR age = ''
OR city = ''
OR email = '';

-- 2) product table
SELECT * FROM bbronze.product;

-- Checking for Duplicate values
SELECT product_id, COUNT(*) AS duplicates

-- Checking for Duplicate values
FROM bbronze.product
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Checking for unwanted spaces
SELECT category
FROM bbronze.product
WHERE category <> TRIM(category);

SELECT color
FROM bbronze.product
WHERE color <> TRIM(color);

SELECT size
FROM bbronze.product
WHERE size <> TRIM(size);

SELECT supplier
FROM bbronze.product
WHERE supplier <> TRIM(supplier);

-- Standardization & Consistency
-- Checking distinct values in category, color, size, season and supplier columns 
SELECT DISTINCT category
FROM bbronze.product;

SELECT DISTINCT color
FROM bbronze.product;

SELECT DISTINCT size
FROM bbronze.product;

SELECT DISTINCT season
FROM bbronze.product;

SELECT DISTINCT supplier
FROM bbronze.product;

-- Checking for NULL and Blank Values
SELECT *
FROM bbronze.product
WHERE product_id = ''
OR category = ''
OR color = ''
OR size = ''
OR season = ''
OR supplier = ''
OR cost_price = ''
OR list_price = '';

-- 3) store table 
SELECT * FROM bbronze.store;

-- 4) sales table
SELECT * FROM bbronze.sales;

-- Checking for Duplicate values
SELECT transaction_id, COUNT(*) AS duplicates
FROM bbronze.sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- Standardization & Consistency
-- Checking distinct values in returned column
SELECT DISTINCT returned
FROM bbronze.sales;

-- Checking for NULL and Blank Values
SELECT * 
FROM bbronze.sales
WHERE transaction_id = ''
OR date = ''
OR product_id = ''
OR store_id = ''
OR customer_id = ''
OR quantity = ''
OR discount = '';
