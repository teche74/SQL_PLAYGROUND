-- MYSQL PIVOT OPERATIONS
-- MySQL doesn't have native PIVOT, but we can simulate it with conditional aggregation

-- ==========================================
-- SAMPLE DATA SETUP
-- ==========================================

-- Create sample sales data
CREATE TABLE sales_data (
    salesperson VARCHAR(50),
    quarter VARCHAR(10),
    amount DECIMAL(10,2)
);

INSERT INTO sales_data VALUES
('Alice', 'Q1', 10000),
('Alice', 'Q2', 12000),
('Alice', 'Q3', 11000),
('Alice', 'Q4', 15000),
('Bob', 'Q1', 8000),
('Bob', 'Q2', 9000),
('Bob', 'Q3', 10000),
('Bob', 'Q4', 12000),
('Charlie', 'Q1', 7000),
('Charlie', 'Q2', 8500),
('Charlie', 'Q3', 9000),
('Charlie', 'Q4', 11000);

-- ==========================================
-- BASIC PIVOT USING CONDITIONAL AGGREGATION
-- ==========================================

-- Transform rows to columns: quarters become columns
SELECT 
    salesperson,
    SUM(CASE WHEN quarter = 'Q1' THEN amount ELSE 0 END) AS Q1,
    SUM(CASE WHEN quarter = 'Q2' THEN amount ELSE 0 END) AS Q2,
    SUM(CASE WHEN quarter = 'Q3' THEN amount ELSE 0 END) AS Q3,
    SUM(CASE WHEN quarter = 'Q4' THEN amount ELSE 0 END) AS Q4,
    SUM(amount) AS Total
FROM sales_data
GROUP BY salesperson
ORDER BY salesperson;

-- Alternative using IF() function (MySQL specific)
SELECT 
    salesperson,
    SUM(IF(quarter = 'Q1', amount, 0)) AS Q1,
    SUM(IF(quarter = 'Q2', amount, 0)) AS Q2,
    SUM(IF(quarter = 'Q3', amount, 0)) AS Q3,
    SUM(IF(quarter = 'Q4', amount, 0)) AS Q4,
    SUM(amount) AS Total
FROM sales_data
GROUP BY salesperson
ORDER BY salesperson;

-- ==========================================
-- ADVANCED PIVOT EXAMPLES
-- ==========================================

-- Example 1: Multiple metrics pivot
CREATE TABLE product_sales (
    product VARCHAR(50),
    region VARCHAR(50),
    sales_amount DECIMAL(10,2),
    units_sold INT
);

INSERT INTO product_sales VALUES
('Laptop', 'North', 50000, 25),
('Laptop', 'South', 45000, 22),
('Laptop', 'East', 40000, 20),
('Tablet', 'North', 30000, 50),
('Tablet', 'South', 35000, 60),
('Tablet', 'East', 28000, 45);

-- Pivot both sales amount and units by region
SELECT 
    product,
    -- Sales Amount by Region
    SUM(CASE WHEN region = 'North' THEN sales_amount ELSE 0 END) AS North_Sales,
    SUM(CASE WHEN region = 'South' THEN sales_amount ELSE 0 END) AS South_Sales,
    SUM(CASE WHEN region = 'East' THEN sales_amount ELSE 0 END) AS East_Sales,
    
    -- Units Sold by Region  
    SUM(CASE WHEN region = 'North' THEN units_sold ELSE 0 END) AS North_Units,
    SUM(CASE WHEN region = 'South' THEN units_sold ELSE 0 END) AS South_Units,
    SUM(CASE WHEN region = 'East' THEN units_sold ELSE 0 END) AS East_Units,
    
    -- Totals
    SUM(sales_amount) AS Total_Sales,
    SUM(units_sold) AS Total_Units
FROM product_sales
GROUP BY product;

-- ==========================================
-- DYNAMIC PIVOT (When columns are unknown)
-- ==========================================

-- Step 1: Get distinct values for pivot columns
SELECT DISTINCT quarter FROM sales_data ORDER BY quarter;

-- Step 2: Build dynamic query (in application code)
-- This is what you'd generate programmatically:

SET @sql = NULL;
SELECT
  GROUP_CONCAT(DISTINCT
    CONCAT(
      'SUM(CASE WHEN quarter = ''',
      quarter,
      ''' THEN amount ELSE 0 END) AS `',
      quarter, '`'
    )
  ) INTO @sql
FROM sales_data;

SET @sql = CONCAT('SELECT salesperson, ', @sql, ', SUM(amount) AS Total
                  FROM sales_data 
                  GROUP BY salesperson');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ==========================================
-- PIVOT WITH PERCENTAGES
-- ==========================================

SELECT 
    salesperson,
    SUM(CASE WHEN quarter = 'Q1' THEN amount ELSE 0 END) AS Q1_Amount,
    SUM(CASE WHEN quarter = 'Q2' THEN amount ELSE 0 END) AS Q2_Amount,
    SUM(CASE WHEN quarter = 'Q3' THEN amount ELSE 0 END) AS Q3_Amount,
    SUM(CASE WHEN quarter = 'Q4' THEN amount ELSE 0 END) AS Q4_Amount,
    
    -- Percentages of total
    ROUND(SUM(CASE WHEN quarter = 'Q1' THEN amount ELSE 0 END) * 100.0 / SUM(amount), 2) AS Q1_Pct,
    ROUND(SUM(CASE WHEN quarter = 'Q2' THEN amount ELSE 0 END) * 100.0 / SUM(amount), 2) AS Q2_Pct,
    ROUND(SUM(CASE WHEN quarter = 'Q3' THEN amount ELSE 0 END) * 100.0 / SUM(amount), 2) AS Q3_Pct,
    ROUND(SUM(CASE WHEN quarter = 'Q4' THEN amount ELSE 0 END) * 100.0 / SUM(amount), 2) AS Q4_Pct,
    
    SUM(amount) AS Total
FROM sales_data
GROUP BY salesperson;

-- ==========================================
-- UNPIVOT OPERATION (Reverse of Pivot)
-- ==========================================

-- Create pivoted table first
CREATE TABLE quarterly_sales AS
SELECT 
    salesperson,
    SUM(CASE WHEN quarter = 'Q1' THEN amount ELSE 0 END) AS Q1,
    SUM(CASE WHEN quarter = 'Q2' THEN amount ELSE 0 END) AS Q2,
    SUM(CASE WHEN quarter = 'Q3' THEN amount ELSE 0 END) AS Q3,
    SUM(CASE WHEN quarter = 'Q4' THEN amount ELSE 0 END) AS Q4
FROM sales_data
GROUP BY salesperson;

-- Unpivot: Convert columns back to rows using UNION ALL
SELECT salesperson, 'Q1' AS quarter, Q1 AS amount FROM quarterly_sales WHERE Q1 > 0
UNION ALL
SELECT salesperson, 'Q2' AS quarter, Q2 AS amount FROM quarterly_sales WHERE Q2 > 0
UNION ALL  
SELECT salesperson, 'Q3' AS quarter, Q3 AS amount FROM quarterly_sales WHERE Q3 > 0
UNION ALL
SELECT salesperson, 'Q4' AS quarter, Q4 AS amount FROM quarterly_sales WHERE Q4 > 0
ORDER BY salesperson, quarter;

-- ==========================================
-- CROSSTAB / CONTINGENCY TABLE
-- ==========================================

-- Example: Employee count by department and job level
CREATE TABLE employees (
    name VARCHAR(50),
    department VARCHAR(50),
    job_level VARCHAR(20)
);

INSERT INTO employees VALUES
('John', 'IT', 'Junior'),
('Jane', 'IT', 'Senior'),
('Mike', 'IT', 'Senior'),
('Sarah', 'Sales', 'Junior'),
('Tom', 'Sales', 'Senior'),
('Lisa', 'Sales', 'Manager'),
('David', 'HR', 'Junior'),
('Emma', 'HR', 'Senior');

-- Crosstab: Count employees by department vs job level
SELECT 
    department,
    SUM(CASE WHEN job_level = 'Junior' THEN 1 ELSE 0 END) AS Junior_Count,
    SUM(CASE WHEN job_level = 'Senior' THEN 1 ELSE 0 END) AS Senior_Count,
    SUM(CASE WHEN job_level = 'Manager' THEN 1 ELSE 0 END) AS Manager_Count,
    COUNT(*) AS Total_Employees
FROM employees
GROUP BY department;

-- ==========================================
-- PIVOT WITH NULL HANDLING
-- ==========================================

-- Handle NULL values properly in pivot
SELECT 
    salesperson,
    COALESCE(SUM(CASE WHEN quarter = 'Q1' THEN amount END), 0) AS Q1,
    COALESCE(SUM(CASE WHEN quarter = 'Q2' THEN amount END), 0) AS Q2,
    COALESCE(SUM(CASE WHEN quarter = 'Q3' THEN amount END), 0) AS Q3,
    COALESCE(SUM(CASE WHEN quarter = 'Q4' THEN amount END), 0) AS Q4,
    
    -- Show NULL as 'No Data' instead of 0
    CASE 
        WHEN SUM(CASE WHEN quarter = 'Q1' THEN amount END) IS NULL 
        THEN 'No Data' 
        ELSE CAST(SUM(CASE WHEN quarter = 'Q1' THEN amount END) AS CHAR)
    END AS Q1_Status
FROM sales_data
GROUP BY salesperson;

-- ==========================================
-- PERFORMANCE OPTIMIZATION TIPS
-- ==========================================

-- 1. Index the columns used in CASE conditions
CREATE INDEX idx_quarter ON sales_data(quarter);
CREATE INDEX idx_salesperson ON sales_data(salesperson);

-- 2. Use covering index for better performance
CREATE INDEX idx_covering ON sales_data(salesperson, quarter, amount);

-- 3. For large datasets, consider using temporary tables
CREATE TEMPORARY TABLE temp_pivot AS
SELECT 
    salesperson,
    SUM(CASE WHEN quarter = 'Q1' THEN amount ELSE 0 END) AS Q1,
    SUM(CASE WHEN quarter = 'Q2' THEN amount ELSE 0 END) AS Q2,
    SUM(CASE WHEN quarter = 'Q3' THEN amount ELSE 0 END) AS Q3,
    SUM(CASE WHEN quarter = 'Q4' THEN amount ELSE 0 END) AS Q4
FROM sales_data
GROUP BY salesperson;

-- ==========================================
-- COMMON PIVOT PATTERNS
-- ==========================================

/*
BASIC PIVOT TEMPLATE:
SELECT 
    grouping_column,
    SUM(CASE WHEN pivot_column = 'Value1' THEN measure_column ELSE 0 END) AS Value1,
    SUM(CASE WHEN pivot_column = 'Value2' THEN measure_column ELSE 0 END) AS Value2,
    SUM(CASE WHEN pivot_column = 'Value3' THEN measure_column ELSE 0 END) AS Value3
FROM source_table
GROUP BY grouping_column;

ALTERNATIVE WITH IF():
SELECT 
    grouping_column,
    SUM(IF(pivot_column = 'Value1', measure_column, 0)) AS Value1,
    SUM(IF(pivot_column = 'Value2', measure_column, 0)) AS Value2
FROM source_table
GROUP BY grouping_column;

DYNAMIC PIVOT STEPS:
1. Get distinct values: SELECT DISTINCT pivot_column FROM table
2. Build CASE statements dynamically in application
3. Execute generated SQL

UNPIVOT TEMPLATE:
SELECT col1, 'Label1' as category, col2 as value FROM table
UNION ALL
SELECT col1, 'Label2' as category, col3 as value FROM table
UNION ALL
SELECT col1, 'Label3' as category, col4 as value FROM table;
*/
