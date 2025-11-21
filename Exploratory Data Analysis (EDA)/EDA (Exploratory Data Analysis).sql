/*
============================================================
RETAIL SALES ANALYTICS — EXPLORATORY DATA ANALYSIS (EDA)
============================================================

PROJECT OVERVIEW
------------------------------------------------------------
This SQL script performs exploratory data analysis (EDA) on the 
Retail Data Warehouse. It focuses on exploring database structure, 
understanding dimensions, analyzing date ranges, calculating 
key performance metrics, and uncovering basic patterns before 
advanced analytics.

------------------------------------------------------------
OBJECTIVES
------------------------------------------------------------
1. Explore database objects and metadata.  
2. Examine product, customer, and store dimensions.  
3. Investigate date ranges and sales history.  
4. Compute key business measures (revenue, cost, quantity, etc.).  
5. Perform magnitude analysis across product categories, suppliers, 
   seasons, customers, and stores.  
6. Apply ranking analysis to identify top performers and behaviors.

------------------------------------------------------------
DATA SOURCE
------------------------------------------------------------
- ggold.fact_sales  
- ggold.dim_product  
- ggold.dim_customer  
- ggold.dim_store  

------------------------------------------------------------
NOTES
------------------------------------------------------------
This script is purely for EDA purposes. All queries are 
descriptive and do not alter data. It provides foundational 
insights needed before building advanced analytical models 
or dashboards.

============================================================
*/

-- ==========================================================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- ==========================================================

-- 1) Database Exploration
------------------------------------------------------------

-- Explore All Objects in the Database
SELECT * 
FROM INFORMATION_SCHEMA.TABLES;

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_product';


-- 2) Dimension Exploration
------------------------------------------------------------

-- categories
SELECT DISTINCT category 
FROM ggold.dim_product;

-- colors
SELECT DISTINCT color 
FROM ggold.dim_product;

-- size
SELECT DISTINCT size 
FROM ggold.dim_product;

-- seasons
SELECT DISTINCT season 
FROM ggold.dim_product;

-- suppliers
SELECT DISTINCT supplier 
FROM ggold.dim_product;


-- 3) Date Exploration
------------------------------------------------------------

-- Finding the first order date and the last order date
-- How many years of sale are available
SELECT 
    MIN(date) AS first_order_date,
    MAX(date) AS last_order_date,
    TIMESTAMPDIFF(month, MIN(date), MAX(date)) AS number_of_months_in_biz
FROM ggold.fact_sales;


-- 4) Measures Exploration
------------------------------------------------------------

-- Find the Total Revenue
SELECT FORMAT(SUM(sales_amount), 2) AS Total_Revenue
FROM ggold.fact_sales;

-- Find the Total Number of Sales
SELECT COUNT(transaction_id) AS Total_Number_of_Sales
FROM ggold.fact_sales;

-- Find the Total Quantities Sold
SELECT FORMAT(SUM(quantity), 0) AS Total_Quantities_Sold
FROM ggold.fact_sales;

-- Find the Average Selling price 
SELECT ROUND(AVG(list_price), 2)
FROM ggold.fact_sales;

-- Find the Total cost price 
SELECT FORMAT(SUM(cost_price), 2) AS Total_Cost_Price
FROM ggold.fact_sales;

-- Find the Total Number of Products
SELECT COUNT(product_id) AS Total_Number_of_Products
FROM ggold.dim_product;

-- Find the Total Number of Customers
SELECT COUNT(customer_id) AS Total_Number_of_Customers
FROM ggold.dim_customer;

-- Find the Total Number of Customers that placed an order
SELECT COUNT(DISTINCT customer_id) AS Total_Number_of_Products
FROM ggold.fact_sales;

-- Generate a report that shows all the key metrics
SELECT 'Total Revenue' AS Measure, FORMAT(SUM(sales_amount),2) AS Measure_Value FROM ggold.fact_sales
UNION ALL
SELECT 'Total Cost Price', FORMAT(SUM(cost_price),2) FROM ggold.fact_sales
UNION ALL 
SELECT 'Average Selling Price', ROUND(AVG(list_price),2) FROM ggold.fact_sales
UNION ALL
SELECT 'Total Quantities Sold', FORMAT(SUM(quantity),0) FROM ggold.fact_sales
UNION ALL
SELECT 'Total Number of Sales', COUNT(transaction_id) FROM ggold.fact_sales
UNION ALL
SELECT 'Total Number of Products', COUNT(product_id) FROM ggold.dim_product
UNION ALL
SELECT 'Total Number of Customers', COUNT(customer_id) FROM ggold.dim_customer
UNION ALL
SELECT 'Total Number of Customers that placed an order', COUNT(DISTINCT customer_id) FROM ggold.fact_sales;


-- 5) Magnitude Analysis
------------------------------------------------------------

SELECT 
    category,
    COUNT(product_id) AS Total_Number_of_Products
FROM ggold.dim_product
GROUP BY category
ORDER BY Total_Number_of_Products DESC;

SELECT 
    p.category, 
    FORMAT(SUM(s.sales_amount), 2) AS Total_Revenue
FROM ggold.dim_product p
LEFT JOIN ggold.fact_sales s ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY Total_Revenue DESC;

SELECT  
    category, 
    ROUND(AVG(cost_price), 2) AS Average_Buying_Price
FROM ggold.dim_product
GROUP BY category;

SELECT 
    p.season, 
    FORMAT(SUM(s.sales_amount),2) AS total_revenue
FROM ggold.dim_product p
LEFT JOIN ggold.fact_sales s ON p.product_id = s.product_id
GROUP BY p.season
ORDER BY total_revenue DESC;

SELECT 
    p.season, 
    FORMAT(SUM(s.profit),2) AS total_profit
FROM ggold.dim_product p
LEFT JOIN ggold.fact_sales s ON p.product_id = s.product_id
GROUP BY p.season
ORDER BY total_profit DESC;

SELECT 
    p.supplier,
    FORMAT(SUM(s.sales_amount),2) AS total_revenue
FROM ggold.dim_product p 
LEFT JOIN ggold.fact_sales s ON p.product_id = s.product_id
GROUP BY p.supplier
ORDER BY total_revenue DESC;

SELECT 
    gender, 
    COUNT(customer_id) AS customer_distribution 
FROM ggold.dim_customer
GROUP BY gender
ORDER BY customer_distribution;

SELECT 
    st.store_name, 
    FORMAT(SUM(s.sales_amount),2) AS total_revenue
FROM ggold.dim_store st
LEFT JOIN ggold.fact_sales s ON st.store_id = s.store_id
GROUP BY st.store_name
ORDER BY total_revenue DESC;

SELECT 
    returned, 
    COUNT(transaction_id) AS total_number_of_sales
FROM ggold.fact_sales
GROUP BY returned
ORDER BY total_number_of_sales;


-- 6) Ranking
------------------------------------------------------------

-- 1. Which products generate the highest revenue per unit sold?
SELECT 
    product_id,
    ROUND(total_revenue_per_unit, 2) AS total_revenue_per_unit,
    RANK() OVER(ORDER BY total_revenue_per_unit DESC) AS revenue_per_unit_rank
FROM (
    SELECT 
        product_id,
        SUM((sales_amount / quantity)) AS total_revenue_per_unit
    FROM ggold.fact_sales
    GROUP BY product_id
) AS t
GROUP BY product_id
ORDER BY total_revenue_per_unit DESC;


-- 2. Which stores have the highest customer repeat rate?
WITH customer_orders AS (
    SELECT 
        fs.store_id,
        fs.customer_id,
        COUNT(*) AS total_orders
    FROM ggold.fact_sales fs
    GROUP BY fs.store_id, fs.customer_id
),
repeat_rate AS (
    SELECT
        store_id,
        COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 1.0
            / COUNT(*) * 100 AS repeat_rate_percentage
    FROM customer_orders
    GROUP BY store_id
)
SELECT 
    ds.store_name,
    rr.repeat_rate_percentage AS customer_repeat_rate,
    RANK() OVER (ORDER BY rr.repeat_rate_percentage DESC) AS repeat_rate_rank
FROM repeat_rate rr
JOIN ggold.dim_store ds
    ON rr.store_id = ds.store_id
ORDER BY repeat_rate_percentage DESC;


-- 3. Which product categories yield the highest profit margin?
WITH highest_profit_margin AS (
    SELECT 
        p.category AS category,
        (SUM(s.profit) / SUM(s.sales_amount)) * 100 AS profit_margin
    FROM ggold.dim_product p
    LEFT JOIN ggold.fact_sales s ON p.product_id = s.product_id
    GROUP BY p.category
)
SELECT 
    category,
    FORMAT(profit_margin, 2) AS profit_margin,
    RANK() OVER(ORDER BY profit_margin DESC) AS profit_margin_rank
FROM highest_profit_margin
GROUP BY category
ORDER BY FORMAT(profit_margin,2) DESC;


-- 4. Which customers contribute the most to net revenue after discounts?
SELECT 
    customer_id,
    SUM(sales_amount) AS net_revenue,
    RANK() OVER(ORDER BY SUM(sales_amount) DESC) AS net_revenue_rank
FROM ggold.fact_sales
GROUP BY customer_id
ORDER BY net_revenue DESC
LIMIT 10;


-- 5. Which products have the highest return rate?
WITH total_returned AS (
    SELECT 
        product_id,
        COUNT(CASE WHEN returned = 'Returned' THEN 1 END) * 1.0 AS returned_count,
        COUNT(*) * 1.0 AS total_sold 
    FROM ggold.fact_sales
    GROUP BY product_id
)
SELECT
    product_id,
    (returned_count / total_sold) * 100 AS return_rate,
    RANK() OVER(ORDER BY (returned_count / total_sold) * 100 DESC) AS return_rate_rank
FROM total_returned
ORDER BY return_rate DESC;
