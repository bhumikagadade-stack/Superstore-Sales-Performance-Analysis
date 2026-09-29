```sql
-- ============================================================
-- SUPERSTORE SALES PERFORMANCE ANALYSIS
-- SQL Analysis
-- Database: SQLite
-- Table: superstore
-- ============================================================


-- ============================================================
-- 1. OVERALL BUSINESS KPIs
-- ============================================================

SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity
FROM superstore;


-- ============================================================
-- 2. SALES & PROFIT BY REGION
-- ============================================================

SELECT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity
FROM superstore
GROUP BY Region
ORDER BY Total_Sales DESC;


-- ============================================================
-- 3. SALES & PROFIT BY CATEGORY
-- ============================================================

SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity
FROM superstore
GROUP BY Category
ORDER BY Total_Sales DESC;


-- ============================================================
-- 4. CATEGORY PROFIT MARGIN
-- ============================================================

SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit) * 100.0 / NULLIF(SUM(Sales), 0), 2) AS Profit_Margin_Percent
FROM superstore
GROUP BY Category
ORDER BY Profit_Margin_Percent DESC;


-- ============================================================
-- 5. LOSS-MAKING SUB-CATEGORIES
-- ============================================================

SELECT
    "Sub-Category",
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore
GROUP BY "Sub-Category"
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;


-- ============================================================
-- 6. SUB-CATEGORY PERFORMANCE
-- ============================================================

SELECT
    "Sub-Category",
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity,
    ROUND(SUM(Profit) * 100.0 / NULLIF(SUM(Sales), 0), 2) AS Profit_Margin_Percent
FROM superstore
GROUP BY "Sub-Category"
ORDER BY Total_Profit DESC;


-- ============================================================
-- 7. TOP PRODUCTS BY PROFIT
-- ============================================================

SELECT
    "Product ID",
    "Product Name",
    Category,
    "Sub-Category",
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore
GROUP BY
    "Product ID",
    "Product Name",
    Category,
    "Sub-Category"
ORDER BY Total_Profit DESC
LIMIT 10;


-- ============================================================
-- 8. LOSS-MAKING PRODUCTS
-- ============================================================

SELECT
    "Product ID",
    "Product Name",
    Category,
    "Sub-Category",
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore
GROUP BY
    "Product ID",
    "Product Name",
    Category,
    "Sub-Category"
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC
LIMIT 10;


-- ============================================================
-- 9. TOP 3 PRODUCTS BY PROFIT WITHIN EACH CATEGORY
-- ============================================================

WITH product_profit AS (
    SELECT
        Category,
        "Product ID",
        "Product Name",
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit
    FROM superstore
    GROUP BY
        Category,
        "Product ID",
        "Product Name"
),

ranked_products AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY Total_Profit DESC
        ) AS Profit_Rank
    FROM product_profit
)

SELECT *
FROM ranked_products
WHERE Profit_Rank <= 3
ORDER BY Category, Profit_Rank;


-- ============================================================
-- 10. TOP 3 LOSS-MAKING PRODUCTS BY CATEGORY
-- ============================================================

WITH product_profit AS (
    SELECT
        Category,
        "Product ID",
        "Product Name",
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit
    FROM superstore
    GROUP BY
        Category,
        "Product ID",
        "Product Name"
),

ranked_products AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY Total_Profit ASC
        ) AS Loss_Rank
    FROM product_profit
)

SELECT *
FROM ranked_products
WHERE Loss_Rank <= 3
ORDER BY Category, Loss_Rank;


-- ============================================================
-- 11. YEARLY SALES & PROFIT
-- ============================================================

SELECT
    strftime('%Y', "Order Date") AS Year,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore
GROUP BY Year
ORDER BY Year;


-- ============================================================
-- 12. MONTHLY SALES & PROFIT
-- ============================================================

SELECT
    strftime('%Y-%m', "Order Date") AS Year_Month,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore
GROUP BY Year_Month
ORDER BY Year_Month;


-- ============================================================
-- 13. YEAR-OVER-YEAR SALES GROWTH
-- ============================================================

WITH yearly_sales AS (
    SELECT
        strftime('%Y', "Order Date") AS Year,
        SUM(Sales) AS Total_Sales
    FROM superstore
    GROUP BY Year
),

sales_with_previous AS (
    SELECT
        Year,
        Total_Sales,
        LAG(Total_Sales) OVER (
            ORDER BY Year
        ) AS Previous_Year_Sales
    FROM yearly_sales
)

SELECT
    Year,
    Total_Sales,
    Previous_Year_Sales,
    ROUND(
        (Total_Sales - Previous_Year_Sales)
        * 100.0 / NULLIF(Previous_Year_Sales, 0),
        2
    ) AS YoY_Sales_Growth_Percent
FROM sales_with_previous
ORDER BY Year;


-- ============================================================
-- 14. YEAR-OVER-YEAR PROFIT GROWTH
-- ============================================================

WITH yearly_profit AS (
    SELECT
        strftime('%Y', "Order Date") AS Year,
        SUM(Profit) AS Total_Profit
    FROM superstore
    GROUP BY Year
),

profit_with_previous AS (
    SELECT
        Year,
        Total_Profit,
        LAG(Total_Profit) OVER (
            ORDER BY Year
        ) AS Previous_Year_Profit
    FROM yearly_profit
)

SELECT
    Year,
    Total_Profit,
    Previous_Year_Profit,
    ROUND(
        (Total_Profit - Previous_Year_Profit)
        * 100.0 / NULLIF(ABS(Previous_Year_Profit), 0),
        2
    ) AS YoY_Profit_Growth_Percent
FROM profit_with_previous
ORDER BY Year;


-- ============================================================
-- 15. CUSTOMER PERFORMANCE
-- ============================================================

SELECT
    "Customer ID",
    "Customer Name",
    Segment,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity,
    COUNT(DISTINCT "Order ID") AS Total_Orders
FROM superstore
GROUP BY
    "Customer ID",
    "Customer Name",
    Segment
ORDER BY Total_Sales DESC;


-- ============================================================
-- 16. TOP 10 CUSTOMERS BY SALES
-- ============================================================

SELECT
    "Customer ID",
    "Customer Name",
    Segment,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore
GROUP BY
    "Customer ID",
    "Customer Name",
    Segment
ORDER BY Total_Sales DESC
LIMIT 10;


-- ============================================================
-- 17. TOP 10 CUSTOMERS BY PROFIT
-- ============================================================

SELECT
    "Customer ID",
    "Customer Name",
    Segment,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore
GROUP BY
    "Customer ID",
    "Customer Name",
    Segment
ORDER BY Total_Profit DESC
LIMIT 10;


-- ============================================================
-- 18. LOSS-MAKING CUSTOMERS
-- ============================================================

SELECT
    "Customer ID",
    "Customer Name",
    Segment,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM superstore
GROUP BY
    "Customer ID",
    "Customer Name",
    Segment
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;


-- ============================================================
-- END OF ANALYSIS
-- ============================================================
```
