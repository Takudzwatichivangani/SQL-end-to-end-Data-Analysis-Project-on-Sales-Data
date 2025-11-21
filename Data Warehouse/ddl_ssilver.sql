/*
============================================================
SILVER LAYER — CLEANED & STANDARDIZED DATA TABLES
============================================================

PROJECT OVERVIEW
------------------------------------------------------------
This SQL script creates the Silver Layer tables for the Retail 
Analytics Data Warehouse. These tables store cleaned, validated, 
and standardized data derived from the raw Bronze Layer, ensuring 
high-quality inputs for the Gold Layer (analytical models).

------------------------------------------------------------
OBJECTIVES
------------------------------------------------------------
1. Drop and recreate Silver Layer tables safely.  
2. Apply standardized data types and improved formatting.  
3. Prepare relational structures for transformations and joins.  
4. Ensure consistency between entities such as customer, product, 
   store, and sales.

------------------------------------------------------------
DATA SOURCE
------------------------------------------------------------
- bbronze.customer  
- bbronze.product  
- bbronze.store  
- bbronze.sales  

------------------------------------------------------------
NOTES
------------------------------------------------------------
Data in the Silver Layer is **clean**, **type-corrected**, and 
**validated**, making it suitable for modeling and analytics.  
The heavy transformations, derived metrics, and fact/dimension 
modeling will occur in the Gold Layer.

============================================================
*/

DROP TABLE IF EXISTS ssilver.customer;
DROP TABLE IF EXISTS ssilver.product;
DROP TABLE IF EXISTS ssilver.store;
DROP TABLE IF EXISTS ssilver.sales;

-- Creating tables
CREATE TABLE ssilver.customer (
    customer_id VARCHAR(15),
    age INT,
    gender VARCHAR(8),
    city VARCHAR(10),
    email VARCHAR(25)
);

CREATE TABLE ssilver.product (
    product_id VARCHAR(15),
    category VARCHAR(20),
    color VARCHAR(10),
    size VARCHAR(5),
    season VARCHAR(10),
    supplier VARCHAR(10),
    cost_price DECIMAL(10,2),
    list_price DECIMAL(10,2)
);

CREATE TABLE ssilver.store (
    store_id VARCHAR(15),
    store_name VARCHAR(30),
    region VARCHAR(15),
    store_size_m2 INT
);

CREATE TABLE ssilver.sales (
    transaction_id VARCHAR(15),
    date DATE,
    product_id VARCHAR(15),
    store_id VARCHAR(15),
    customer_id VARCHAR(15),
    quantity INT,
    discount DECIMAL(2,1),
    returned VARCHAR(10)
);
