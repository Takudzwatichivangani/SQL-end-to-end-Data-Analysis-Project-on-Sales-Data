/*
============================================================
SILVER LAYER — DATA QUALITY & TESTING CHECKS
============================================================

DESCRIPTION
------------------------------------------------------------
This SQL script performs testing and verification on the 
cleaned Silver Layer tables (customer, product, and sales). 
It is intended to:

1. Inspect all table contents.
2. Validate distinct values in key columns.
3. Check for NULL or blank values.
4. Identify duplicate records (for sales).
5. Ensure standardization and consistency after cleaning.

These checks confirm that the Silver Layer is ready for 
loading into the Gold Layer for analytics and reporting.
============================================================
*/

-- 1) customer table
-- Checking distinct values in gender column
SELECT DISTINCT gender
FROM ssilver.customer;

-- Checking for NULL and Blank Values
SELECT *
FROM ssilver.customer
WHERE customer_id =''
OR age = ''
OR city = ''
OR email = '';

-- 2) product table
SELECT * FROM ssilver.product;

-- Checking distinct values in category, color, size, season and supplier columns 
SELECT DISTINCT category
FROM ssilver.product;

SELECT DISTINCT color
FROM ssilver.product;

-- Checking for NULL and Blank Values
SELECT *
FROM ssilver.product
WHERE product_id = ''
OR category = ''
OR color = ''
OR size = ''
OR season = ''
OR supplier = ''
OR cost_price = ''
OR list_price = '';

-- 4) sales table
SELECT * FROM ssilver.sales;

-- Checking for Duplicate values
SELECT transaction_id, COUNT(*) AS duplicates
FROM ssilver.sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- Standardization & Consistency
-- Checking distinct values in returned column
SELECT DISTINCT returned
FROM ssilver.sales;

-- Checking for NULL and Blank Values
SELECT * 
FROM ssilver.sales
WHERE transaction_id = ''
OR product_id = ''
OR store_id = ''
OR customer_id = ''
OR quantity = ''
OR discount = '';
