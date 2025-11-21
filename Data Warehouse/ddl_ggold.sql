/*
============================================================
GOLD LAYER — DIMENSION & FACT VIEWS CREATION
============================================================

DESCRIPTION
------------------------------------------------------------
This SQL script defines the Gold Layer views for analytics, 
creating dimension and fact views from the cleaned Silver 
Layer tables. It is intended to:

1. Expose customer, product, and store dimensions for analytics.
2. Create a fact_sales view with calculated profit and sales_amount.
3. Serve as the Gold Layer for reporting and advanced analysis.
============================================================
*/

-- Preview Silver Layer tables
SELECT * FROM ssilver.sales;
SELECT * FROM ssilver.product;
SELECT * FROM ssilver.customer;
SELECT * FROM ssilver.store;

-- Dimension Views
CREATE OR REPLACE VIEW ggold.dim_customer AS
SELECT
    customer_id,
    age,
    gender,
    city,
    email
FROM ssilver.customer;

CREATE OR REPLACE VIEW ggold.dim_product AS
SELECT 
    product_id,
    category,
    color,
    size,
    season,
    supplier,
    cost_price,
    list_price
FROM ssilver.product;

CREATE OR REPLACE VIEW ggold.dim_store AS
SELECT * FROM ssilver.store;

-- Fact Sales View
-- CREATE OR REPLACE VIEW ggold.fact_sales AS
SELECT 
    s.transaction_id,
    s.date,
    s.product_id,
    s.store_id,
    s.customer_id,
    s.quantity,
    s.discount,
    p.list_price,
    p.cost_price,
    (p.list_price - p.cost_price) * s.quantity AS profit,
    (p.list_price * s.quantity) - (s.discount * s.quantity) AS sales_amount,
    s.returned
FROM ssilver.sales s 
LEFT JOIN ssilver.product p
ON s.product_id = p.product_id;
