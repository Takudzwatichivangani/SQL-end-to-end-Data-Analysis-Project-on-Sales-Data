/*
============================================================
SILVER LAYER — ETL LOADING PROCEDURE
============================================================

PROCEDURE: ssilver.load_ssilver()
------------------------------------------------------------
This procedure loads cleaned and standardized data from the 
Bronze Layer (bbronze) into the Silver Layer (ssilver).

The process includes:
1. Cleaning missing values
2. Standardizing formats
3. Handling invalid placeholders (e.g., '???')
4. Deduplicating sales transactions using ROW_NUMBER()
5. Converting data types (DATE, DECIMAL)
6. Applying business rules for "returned" vs "sale"

============================================================
*/

DELIMITER $$
DROP PROCEDURE IF EXISTS ssilver.load_ssilver$$

CREATE PROCEDURE ssilver.load_ssilver()
BEGIN

    -- 1) customer table
    TRUNCATE TABLE ssilver.customer;

    INSERT INTO ssilver.customer (
        customer_id,
        age,
        gender,
        city,
        email
    )
    SELECT 
        customer_id,
        age,
        CASE 
            WHEN gender = '???' THEN 'N/A'
            ELSE gender
        END AS gender,
        city,
        CASE 
            WHEN email = '' THEN 'N/A'
            ELSE email
        END AS email
    FROM bbronze.customer;


    -- 2) product table
    TRUNCATE TABLE ssilver.product;

    INSERT INTO ssilver.product (
        product_id,
        category,
        color,
        size,
        season,
        supplier,
        cost_price,
        list_price
    )
    SELECT 
        product_id,
        CASE 
            WHEN category = '???' THEN 'Unknown'
            ELSE category
        END AS category,
        CASE 
            WHEN color = '' THEN 'N/A'
            ELSE color
        END AS color,
        size,
        season,
        supplier,
        cost_price,
        list_price
    FROM bbronze.product;


    -- 3) store table
    TRUNCATE TABLE ssilver.store;

    INSERT INTO ssilver.store (
        store_id,
        store_name,
        region,
        store_size_m2
    )
    SELECT 
        store_id,
        store_name,
        region,
        store_size_m2
    FROM bbronze.store;


    -- 4) sales table
    TRUNCATE TABLE ssilver.sales;

    INSERT INTO ssilver.sales (
        transaction_id,
        date,
        product_id,
        store_id,
        customer_id,
        quantity,
        discount,
        returned
    )
    SELECT 
        transaction_id,
        CAST(date AS DATE) AS date,
        product_id,
        store_id,
        CASE 
            WHEN customer_id = '' THEN 'n/a'
            ELSE customer_id
        END AS customer_id,
        CASE 
            WHEN returned = 1 THEN 0
            ELSE quantity
        END AS quantity,
        CASE 
            WHEN discount = '' THEN 0.0
            ELSE CAST(discount AS DECIMAL(2,1))
        END AS discount,
        CASE 
            WHEN returned = 1 THEN 'Returned'
            ELSE 'Sale'
        END AS returned
    FROM (
        SELECT 
            *,
            ROW_NUMBER() OVER (
                PARTITION BY transaction_id 
                ORDER BY date
            ) AS rs
        FROM bbronze.sales
    ) AS ranked_transactions
    WHERE rs = 1;

END$$
DELIMITER ;
