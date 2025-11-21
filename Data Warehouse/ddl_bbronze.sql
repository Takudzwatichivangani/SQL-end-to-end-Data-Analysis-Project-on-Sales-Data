/*
============================================================
BRONZE LAYER — RAW DATA TABLE CREATION
============================================================

PROJECT OVERVIEW
------------------------------------------------------------
This SQL script sets up the Bronze Layer (raw ingestion layer) 
for the Retail Analytics Data Warehouse. It creates raw tables 
for customer, product, store, and sales data exactly as received 
from source systems, without transformations.

------------------------------------------------------------
OBJECTIVES
------------------------------------------------------------
1. Drop existing Bronze tables safely and recreate them.  
2. Define table structures that match the raw source formats.  
3. Prepare the data layer for ingestion into Silver and Gold layers.

------------------------------------------------------------
DATA SOURCE
------------------------------------------------------------
- Customer raw file  
- Product raw file  
- Store raw file  
- Sales transaction file  

------------------------------------------------------------
NOTES
------------------------------------------------------------
The Bronze Layer stores **raw, uncleaned, and unstandardized** data.  
All transformations, standardization, and modeling occur in the 
Silver and Gold layers, ensuring full traceability and lineage.

============================================================
*/

USE bbronze;

DROP TABLE IF EXISTS bbronze.customer;
DROP TABLE IF EXISTS bbronze.product;
DROP TABLE IF EXISTS bbronze.store;
DROP TABLE IF EXISTS bbronze.sales;

CREATE TABLE bbronze.customer (
    customer_id VARCHAR(15),
    age INT,
    gender VARCHAR(8),
    city VARCHAR(10),
    email VARCHAR(25)
);

CREATE TABLE bbronze.product (
    product_id VARCHAR(15),
    category VARCHAR(20),
    color VARCHAR(10),
    size VARCHAR(5),
    season VARCHAR(10),
    supplier VARCHAR(10),
    cost_price DECIMAL(10,2),
    list_price DECIMAL(10,2)
);

CREATE TABLE bbronze.store (
    store_id VARCHAR(15),
    store_name VARCHAR(30),
    region VARCHAR(15),
    store_size_m2 INT
);

CREATE TABLE bbronze.sales (
    transaction_id VARCHAR(15),
    date VARCHAR(14),
    product_id VARCHAR(15),
    store_id VARCHAR(15),
    customer_id VARCHAR(15),
    quantity INT,
    discount VARCHAR(10),
    returned INT
);
