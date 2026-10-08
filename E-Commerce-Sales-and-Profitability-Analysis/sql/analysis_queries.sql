CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;
CREATE TABLE ecommerce_sales (
    Order_Date DATE,
    Product_Name VARCHAR(255),
    Category VARCHAR(100),
    Region VARCHAR(100),
    Quantity INT,
    Sales DECIMAL(12,2),
    Profit DECIMAL(12,2)
);
DESCRIBE ecommerce_sales;
SELECT *
FROM ecommerce_sales
LIMIT 10;
SELECT COUNT(*) AS Total_Rows
FROM ecommerce_sales;

SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_sales
GROUP BY Category
ORDER BY Total_Profit DESC;

-- Data validation
USE ecommerce_analysis;
-- number of records
SELECT COUNT(*) AS Total_Rows
FROM ecommerce_sales;
-- Preview data
SELECT *
FROM ecommerce_sales
LIMIT 10;

-- OVERALL SALES ANALYSIS --

-- Total Sales
SELECT
    SUM(Sales) AS Total_Sales
FROM ecommerce_sales;
-- Total Profit
SELECT
    SUM(Profit) AS Total_Profit
FROM ecommerce_sales;
-- Total Transactions
SELECT
    COUNT(*) AS Total_Transactions
FROM ecommerce_sales;
-- Total Quantity
SELECT
    SUM(Quantity) AS Total_Quantity
FROM ecommerce_sales;
-- Average Transaction Value
SELECT
    SUM(Sales) / COUNT(*) AS Average_Transaction_Value
FROM ecommerce_sales;
-- Overall Profit Margin
SELECT
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_sales;

-- Monthly Sales Analysis
SELECT
    YEAR(`Order Date`) AS Sales_Year,
    MONTH(`Order Date`) AS Sales_Month,
    SUM(Sales) AS Total_Sales
FROM ecommerce_sales
GROUP BY
    YEAR(`Order Date`),
    MONTH(`Order Date`)
ORDER BY
    Sales_Year,
    Sales_Month;

-- Monthly Profit Analysis
SELECT
    YEAR(`Order Date`) AS Sales_Year,
    MONTH(`Order Date`) AS Sales_Month,
    SUM(Profit) AS Total_Profit
FROM ecommerce_sales
GROUP BY
    YEAR(`Order Date`),
    MONTH(`Order Date`)
ORDER BY
    Sales_Year,
    Sales_Month;
    
-- Sales by Category
SELECT
    Category,
    SUM(Sales) AS Total_Sales
FROM ecommerce_sales
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Profit by Category
SELECT
    Category,
    SUM(Profit) AS Total_Profit
FROM ecommerce_sales
GROUP BY Category
ORDER BY Total_Profit DESC;

-- Quantity by Category
SELECT
    Category,
    SUM(Quantity) AS Total_Quantity
FROM ecommerce_sales
GROUP BY Category
ORDER BY Total_Quantity DESC;

-- Category Profitability
SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_sales
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Sales by Region
SELECT
    Region,
    SUM(Sales) AS Total_Sales
FROM ecommerce_sales
GROUP BY Region
ORDER BY Total_Sales DESC;

-- Profit by Region
SELECT
    Region,
    SUM(Profit) AS Total_Profit
FROM ecommerce_sales
GROUP BY Region
ORDER BY Total_Profit DESC;

-- Quantity by Region
SELECT
    Region,
    SUM(Quantity) AS Total_Quantity
FROM ecommerce_sales
GROUP BY Region
ORDER BY Total_Quantity DESC;

-- Regional Profitability
SELECT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_sales
GROUP BY Region
ORDER BY Total_Sales DESC;

-- Category Performance Within Each Region
SELECT
    Region,
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_sales
GROUP BY
    Region,
    Category
ORDER BY
    Region,
    Total_Sales DESC;
    
-- PROFITABLITY ANALYSIS -- 

-- Overall Profit Margin
SELECT
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Overall_Profit_Margin_Percent
FROM ecommerce_sales;

-- Profit Margin by Category
SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_sales
GROUP BY Category
ORDER BY Profit_Margin_Percent DESC;

-- Profit Margin by Region
SELECT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM ecommerce_sales
GROUP BY Region
ORDER BY Profit_Margin_Percent DESC;

-- High Sales / Low Profit --

WITH product_summary AS (
    SELECT
        `Product Name`,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit
    FROM ecommerce_sales
    GROUP BY `Product Name`
)

SELECT
    `Product Name`,
    Total_Sales,
    Total_Profit,
    ROUND(
        (Total_Profit / NULLIF(Total_Sales, 0)) * 100,
        2
    ) AS Profit_Margin
FROM product_summary
ORDER BY Total_Sales DESC;

WITH product_summary AS (
    SELECT
        `Product Name`,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit,
        (SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100 AS Profit_Margin
    FROM ecommerce_sales
    GROUP BY `Product Name`
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY Total_Sales) AS Sales_Rank,
        ROW_NUMBER() OVER (ORDER BY Profit_Margin) AS Margin_Rank,
        COUNT(*) OVER () AS Total_Products
    FROM product_summary
),

medians AS (
    SELECT
        AVG(
            CASE
                WHEN Sales_Rank IN (
                    FLOOR((Total_Products + 1) / 2),
                    CEIL((Total_Products + 1) / 2)
                )
                THEN Total_Sales
            END
        ) AS Median_Sales,

        AVG(
            CASE
                WHEN Margin_Rank IN (
                    FLOOR((Total_Products + 1) / 2),
                    CEIL((Total_Products + 1) / 2)
                )
                THEN Profit_Margin
            END
        ) AS Median_Margin

    FROM ranked
)

SELECT
    p.`Product Name`,
    p.Total_Sales,
    p.Total_Profit,
    ROUND(p.Profit_Margin, 2) AS Profit_Margin,
    ROUND(m.Median_Sales, 2) AS Median_Sales,
    ROUND(m.Median_Margin, 2) AS Median_Profit_Margin
FROM product_summary p
CROSS JOIN medians m
WHERE
    p.Total_Sales > m.Median_Sales
    AND p.Profit_Margin < m.Median_Margin
ORDER BY p.Total_Sales DESC;