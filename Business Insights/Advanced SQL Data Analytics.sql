/*
============================================================
FASHION SALES ANALYTICS PROJECT — ADVANCED SQL ANALYSIS
============================================================

PROJECT OVERVIEW
------------------------------------------------------------
This SQL script performs advanced analytical exploration of the 
Fashion Sales Data Warehouse (Gold Layer). The analysis focuses 
on identifying trends, evaluating store and product performance, 
computing comparative metrics, and generating segmentation insights 
that support strategic retail decision-making.

------------------------------------------------------------
OBJECTIVES
------------------------------------------------------------
1. Analyze month-over-month revenue growth and identify 
   high-growth vs. declining products.
2. Compute cumulative revenue at store and company level.
3. Evaluate profit margins by store and category relative 
   to overall company performance.
4. Assess supplier contribution to revenue and monthly shifts.
5. Segment customers based on spending behavior and evaluate 
   revenue/profit contributions.
6. Compare store performance on revenue per transaction and 
   return rates across seasons.

------------------------------------------------------------
DATA SOURCE
------------------------------------------------------------
- ggold.fact_sales  
- ggold.dim_product  
- ggold.dim_store  

------------------------------------------------------------
NOTES
------------------------------------------------------------
The script uses advanced SQL techniques including window functions, 
CTEs, conditional logic, part-to-whole analysis, and segmentation 
models. These analyses support comprehensive understanding of 
fashion sales behavior across time, products, customers, and stores.

============================================================
*/

USE ggold;

------------------------------------------------------------
--  Change-Over-Time Analysis
--
-- 1 Which products show the highest month-over-month growth 
--   in revenue, and which products are declining over time?
------------------------------------------------------------

WITH total_revenue AS (
    SELECT 
        DATE_FORMAT(date, '%Y-%m') AS monthly,
        product_id,
        SUM(sales_amount) AS total_revenue
    FROM ggold.fact_sales
    GROUP BY product_id, monthly
),
mom_change AS (
    SELECT 
        monthly,
        product_id,
        total_revenue,
        LAG(total_revenue) OVER (
            PARTITION BY product_id ORDER BY monthly
        ) AS previous_month_revenue,
        (
            (total_revenue - LAG(total_revenue) OVER (
                PARTITION BY product_id ORDER BY monthly
            )) / 
            LAG(total_revenue) OVER (
                PARTITION BY product_id ORDER BY monthly
            )
        ) * 100 AS mom_growth_percentage
    FROM total_revenue
)
SELECT
    monthly,
    product_id,
    total_revenue,
    previous_month_revenue,
    mom_growth_percentage
FROM mom_change
WHERE mom_growth_percentage IS NOT NULL
ORDER BY mom_growth_percentage DESC;


------------------------------------------------------------
--  Cumulative Analysis
--
-- 2 What is the cumulative revenue for each store over the year, 
--   and how does each store contribute to total revenue cumulatively?
------------------------------------------------------------

WITH total_revenue AS (
    SELECT 
        DATE_FORMAT(date, '%Y') AS yearr,
        store_id,
        SUM(sales_amount) AS total_revenue
    FROM ggold.fact_sales
    GROUP BY yearr, store_id
),
store_cumulative AS (
    SELECT 
        yearr,
        store_id,
        total_revenue,
        SUM(total_revenue) OVER (
            PARTITION BY store_id ORDER BY yearr
        ) AS store_cumulative
    FROM total_revenue
),
cumulative_company AS (
    SELECT 
        yearr,
        SUM(total_revenue) AS company_revenue,
        SUM(SUM(total_revenue)) OVER (
            ORDER BY yearr
        ) AS cumulative_company
    FROM store_cumulative
    GROUP BY yearr
)
SELECT
    s.yearr,
    st.store_name,
    s.store_cumulative,
    c.cumulative_company,
    (s.store_cumulative / c.cumulative_company) * 100 
        AS store_cumulative_contribution
FROM store_cumulative s
LEFT JOIN ggold.dim_store st ON s.store_id = st.store_id
JOIN cumulative_company c USING (yearr)
ORDER BY yearr, store_name;


------------------------------------------------------------
--  Performance Analysis
--
-- 3 Which stores or product categories consistently achieve the 
--   highest profit margins, and which are underperforming compared 
--   to the company average?
------------------------------------------------------------

WITH overall_margin AS (
    SELECT 
        (SUM(profit) / SUM(sales_amount)) * 100 AS overall_margin
    FROM ggold.fact_sales
),
category_level_margin AS (
    SELECT 
        p.category,
        (SUM(s.profit) / SUM(s.sales_amount)) * 100 AS category_level_margin
    FROM ggold.fact_sales s
    LEFT JOIN ggold.dim_product p ON s.product_id = p.product_id
    WHERE p.category IS NOT NULL
    GROUP BY p.category
)
SELECT 
    c.category,
    c.category_level_margin,
    o.overall_margin,
    CASE 
        WHEN c.category_level_margin > o.overall_margin 
            THEN 'Above Company Margin'
        ELSE 'Below Company Margin'
    END AS perfomance_status
FROM category_level_margin c
CROSS JOIN overall_margin o
ORDER BY c.category_level_margin DESC;


------------------------------------------------------------
-- Part-to-Whole Analysis
--
-- 4 What percentage of total revenue is contributed by each supplier, 
--   and how does this change monthly?
------------------------------------------------------------

WITH monthly_supplier AS (
    SELECT
        DATE_FORMAT(s.date, '%Y-%m') AS month,
        p.supplier,
        SUM(s.sales_amount) AS supplier_revenue
    FROM ggold.fact_sales s
    JOIN ggold.dim_product p ON s.product_id = p.product_id
    GROUP BY month, p.supplier
),
monthly_total AS (
    SELECT
        DATE_FORMAT(date, '%Y-%m') AS month,
        SUM(sales_amount) AS total_revenue
    FROM ggold.fact_sales
    GROUP BY month
),
supplier_percentage AS (
    SELECT
        m.month,
        m.supplier,
        m.supplier_revenue,
        t.total_revenue,
        (m.supplier_revenue / t.total_revenue) * 100 AS percentage_contribution
    FROM monthly_supplier m
    JOIN monthly_total t USING (month)
),
percentage_change AS (
    SELECT
        supplier,
        month,
        percentage_contribution,
        LAG(percentage_contribution) OVER (
            PARTITION BY supplier ORDER BY month
        ) AS prev_percentage,
        percentage_contribution 
            - LAG(percentage_contribution) OVER (
                PARTITION BY supplier ORDER BY month
            ) AS month_to_month_change
    FROM supplier_percentage
)
SELECT *
FROM percentage_change
WHERE prev_percentage IS NOT NULL
ORDER BY supplier, month;


------------------------------------------------------------
-- Which stores achieve the highest revenue per transaction 
-- and the lowest return rates simultaneously, and how does their 
-- performance compare across seasons?”
------------------------------------------------------------

WITH summary AS (
    SELECT 
        s.store_id,
        p.season,
        SUM(s.sales_amount) / COUNT(*) AS revenue_per_transaction,
        SUM(CASE WHEN s.returned = 'Returned' THEN 1 ELSE 0 END) * 1.0 
            AS total_returns,
        COUNT(*) * 1.0 AS total_sold
    FROM ggold.fact_sales s
    LEFT JOIN ggold.dim_product p ON s.product_id = p.product_id
    GROUP BY s.store_id, p.season
),
ranking AS (
    SELECT
        store_id,
        season,
        revenue_per_transaction,
        (total_returns / total_sold) * 100 AS return_rate,
        RANK() OVER (
            PARTITION BY season ORDER BY revenue_per_transaction DESC
        ) AS high_rev_rank,
        RANK() OVER (
            PARTITION BY season ORDER BY (total_returns / total_sold) ASC
        ) AS low_return_rank
    FROM summary
)
SELECT 
    ds.store_name,
    r.season,
    r.revenue_per_transaction,
    r.return_rate,
    r.high_rev_rank,
    r.low_return_rank
FROM ranking r
LEFT JOIN ggold.dim_store ds ON r.store_id = ds.store_id
WHERE r.revenue_per_transaction IS NOT NULL
ORDER BY r.season, r.high_rev_rank;


------------------------------------------------------------
-- Data Segmentation
--
-- 5 Can customers be segmented based on purchasing behavior 
--   (e.g., high-value, frequent, seasonal), and which segment 
--   contributes most to revenue and profit?
--
-- “Which customers fall into high-value, medium-value, and low-value 
--   groups based on yearly spending, and which segment contributes 
--   the most profit”
------------------------------------------------------------

WITH summary AS (
    SELECT  
        DATE_FORMAT(date, '%Y') AS year,
        customer_id,
        SUM(sales_amount) AS total_spending,
        SUM(profit) AS total_profit
    FROM ggold.fact_sales
    GROUP BY customer_id, year
),
customer_segment AS (
    SELECT 
        year,
        customer_id,
        total_spending,
        total_profit,
        CASE 
            WHEN total_spending < 300 THEN 'Low Value'
            WHEN total_spending BETWEEN 300 AND 1000 THEN 'Medium Value'
            ELSE 'High Value'
        END AS customer_segment
    FROM summary
),
total_profit_contributed AS (
    SELECT 
        customer_segment,
        SUM(total_profit) AS total_profit_contributed
    FROM customer_segment
    GROUP BY customer_segment
)
SELECT 
    s.year,
    s.customer_id,
    s.total_spending,
    s.total_profit,
    t.total_profit_contributed,
    s.customer_segment
FROM customer_segment s 
LEFT JOIN total_profit_contributed t ON s.customer_segment = t.customer_segment
ORDER BY s.year, s.customer_segment, s.total_spending DESC;


------------------------------------------------------------
-- “Which stores consistently achieve the highest profit margins 
--   on each product category, and which categories underperform 
--   relative to the store’s overall margin?”
------------------------------------------------------------

WITH overall_profit_margin AS (
    SELECT 
        store_id,
        SUM(profit) / SUM(sales_amount) * 100 AS overall_profit_margin
    FROM ggold.fact_sales
    GROUP BY store_id
),
profit_margin AS (
    SELECT 
        s.store_id,
        p.category,
        SUM(s.profit) / SUM(s.sales_amount) * 100 AS profit_margin
    FROM ggold.fact_sales s
    LEFT JOIN ggold.dim_product p ON s.product_id = p.product_id
    GROUP BY store_id, category
)
SELECT 
    st.store_name,
    s.category,
    s.profit_margin,
    o.overall_profit_margin,
    (o.overall_profit_margin - s.profit_margin) AS profit_margin_diff,
    CASE 
        WHEN (s.profit_margin - o.overall_profit_margin ) > 0 THEN 'Increase'
        WHEN (s.profit_margin - o.overall_profit_margin) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS performance_change,
    RANK() OVER (
        PARTITION BY st.store_name 
        ORDER BY s.profit_margin DESC
    ) AS category_rank
FROM profit_margin s
LEFT JOIN overall_profit_margin o ON s.store_id = o.store_id
LEFT JOIN ggold.dim_store st ON s.store_id = st.store_id
WHERE st.store_name IS NOT NULL
ORDER BY st.store_name, s.profit_margin DESC;
