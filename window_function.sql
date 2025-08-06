-- rank : used for ranking , finding highest and lowest indivisually or in group . It will provide common rank to same value leads to inconsistency in rank for descendants
select table.*, rank() over([partition by col1 ,col2] order by col1 desc, col2 asc) as rank from table

-- dense_rank : same as rank , the only differnce is it provide unique ranking no matter values are similar or not whihc means consistent and unique values
select table.*, dense_rank() over([partition by col1, col2] order by col1 desc , col2 asc) as denserank from table

-- lead : if you want to peek forward in data. It is used for analyzing trend, doing compairsion , or operation where future values are  needed 
select table.*, lead(column_name, offset, default_value) over([partition by col1, col2] order by col1 desc , col2 asc) as new_column from table

-- lag : if you want to peek backward in data. It is used for anlyzing history, doing comparision or operation where history data is required
select  table.*, lag(column_name, offset, default_value) over([partition by col1, col2] order by col1 desc , col2 asc) as new_column from table

-- row number : ALWAYS unique sequential numbers (1,2,3,4...) where No consideration for ties and Use additional ORDER BY columns for consistency
select  table.*, row_number() over([partition by col1, col2] order by col1 desc , col2 asc) as order from table









  
-- more explained

-- COMPLETE WINDOW FUNCTIONS REFERENCE
-- Sample data for examples
WITH EmployeeData AS (
    SELECT 'Alice' as Name, 'Sales' as Department, 75000 as Salary
    UNION ALL SELECT 'Bob', 'Sales', 75000
    UNION ALL SELECT 'Charlie', 'Sales', 65000
    UNION ALL SELECT 'Diana', 'IT', 80000
    UNION ALL SELECT 'Eve', 'IT', 85000
    UNION ALL SELECT 'Frank', 'IT', 85000
)

-- ==========================================
-- RANKING FUNCTIONS COMPARISON
-- ==========================================

SELECT 
    Name,
    Department,
    Salary,
    
    -- RANK: Assigns same rank to ties, skips subsequent ranks
    RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) as RankCol,
    
    -- DENSE_RANK: Assigns same rank to ties, NO gaps in ranking
    DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) as DenseRankCol,
    
    -- ROW_NUMBER: Always assigns unique sequential numbers (no ties)
    ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) as RowNumCol
    
FROM EmployeeData
ORDER BY Department, Salary DESC;

/*
Results will show:
Name     | Dept | Salary | RankCol | DenseRankCol | RowNumCol
---------|------|--------|---------|--------------|----------
Alice    | Sales| 75000  |    1    |      1       |    1
Bob      | Sales| 75000  |    1    |      1       |    2
Charlie  | Sales| 65000  |    3    |      2       |    3
Eve      | IT   | 85000  |    1    |      1       |    1
Frank    | IT   | 85000  |    1    |      1       |    2
Diana    | IT   | 80000  |    3    |      2       |    3
*/

-- ==========================================
-- RANK FUNCTION (Corrected explanation)
-- ==========================================
-- RANK: Assigns same rank to ties, then SKIPS ranks (creates gaps)
-- This creates "inconsistency" in sequential numbering, not descendants

SELECT 
    Name,
    Salary,
    RANK() OVER (ORDER BY Salary DESC) as SalaryRank
FROM EmployeeData;

-- Example output:
-- Alice: Rank 1 (75000)
-- Bob: Rank 1 (75000) - same salary, same rank
-- Eve: Rank 3 (85000) - rank 2 is skipped!
-- Frank: Rank 3 (85000)
-- Diana: Rank 5 (80000) - rank 4 is skipped!

-- ==========================================
-- DENSE_RANK FUNCTION (Corrected explanation)  
-- ==========================================
-- DENSE_RANK: Same rank for ties, but NO gaps in ranking sequence
-- Note: It doesn't provide "unique" ranking - ties still get same rank

SELECT 
    Name,
    Salary,
    DENSE_RANK() OVER (ORDER BY Salary DESC) as DenseSalaryRank
FROM EmployeeData;

-- Example output:
-- Alice: Dense Rank 1 (75000)
-- Bob: Dense Rank 1 (75000) - same salary, same rank
-- Eve: Dense Rank 2 (85000) - no gap, continues sequence
-- Frank: Dense Rank 2 (85000)
-- Diana: Dense Rank 3 (80000) - consecutive numbering

-- ==========================================
-- ROW_NUMBER FUNCTION
-- ==========================================
-- ROW_NUMBER: Assigns unique sequential numbers regardless of ties
-- Always provides 1, 2, 3, 4... with no gaps or duplicates

SELECT 
    Name,
    Department,
    Salary,
    ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC, Name) as RowNum
FROM EmployeeData;

-- When values are identical, ORDER BY additional columns (like Name) 
-- to ensure consistent row numbering across executions

-- ==========================================
-- LEAD FUNCTION (Peek Forward)
-- ==========================================
-- LEAD: Access future rows for trend analysis and comparisons

WITH SalesData AS (
    SELECT 'Q1' as Quarter, 100000 as Revenue
    UNION ALL SELECT 'Q2', 120000
    UNION ALL SELECT 'Q3', 115000  
    UNION ALL SELECT 'Q4', 140000
)
SELECT 
    Quarter,
    Revenue,
    LEAD(Revenue, 1, 0) OVER (ORDER BY Quarter) as NextQuarterRevenue,
    
    -- Calculate growth rate
    CASE 
        WHEN LEAD(Revenue, 1, 0) OVER (ORDER BY Quarter) > 0 
        THEN ROUND((LEAD(Revenue, 1, 0) OVER (ORDER BY Quarter) - Revenue) * 100.0 / Revenue, 2)
        ELSE NULL 
    END as GrowthRate
FROM SalesData;

-- ==========================================
-- LAG FUNCTION (Peek Backward)
-- ==========================================
-- LAG: Access historical rows for trend analysis and comparisons

SELECT 
    Quarter,
    Revenue,
    LAG(Revenue, 1, 0) OVER (ORDER BY Quarter) as PreviousQuarterRevenue,
    
    -- Calculate change from previous quarter
    Revenue - LAG(Revenue, 1, 0) OVER (ORDER BY Quarter) as RevenueChange,
    
    -- Trend analysis
    CASE 
        WHEN Revenue > LAG(Revenue, 1, 0) OVER (ORDER BY Quarter) THEN 'Increasing'
        WHEN Revenue < LAG(Revenue, 1, 0) OVER (ORDER BY Quarter) THEN 'Decreasing'
        WHEN LAG(Revenue, 1, 0) OVER (ORDER BY Quarter) = 0 THEN 'First Period'
        ELSE 'Stable'
    END as Trend
FROM SalesData;

-- ==========================================
-- PRACTICAL EXAMPLES WITH ALL FUNCTIONS
-- ==========================================

-- Example 1: Employee ranking analysis
SELECT 
    Name,
    Department,
    Salary,
    
    -- Different ranking approaches
    RANK() OVER (ORDER BY Salary DESC) as OverallRank,
    DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) as DeptRank,
    ROW_NUMBER() OVER (ORDER BY Salary DESC, Name) as RowNumber,
    
    -- Salary comparisons
    LAG(Salary) OVER (ORDER BY Salary DESC) as HigherSalary,
    LEAD(Salary) OVER (ORDER BY Salary DESC) as LowerSalary,
    
    -- Analysis
    Salary - LAG(Salary, 1, Salary) OVER (ORDER BY Salary DESC) as SalaryGapAbove
FROM EmployeeData
ORDER BY Salary DESC;

-- Example 2: Finding top performers per department
WITH RankedEmployees AS (
    SELECT 
        Name,
        Department,
        Salary,
        DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) as DeptRank
    FROM EmployeeData
)
SELECT * 
FROM RankedEmployees 
WHERE DeptRank <= 2;  -- Top 2 in each department

-- Example 3: Trend analysis with LEAD/LAG
WITH MonthlyData AS (
    SELECT '2024-01' as Month, 50000 as Sales
    UNION ALL SELECT '2024-02', 55000
    UNION ALL SELECT '2024-03', 52000
    UNION ALL SELECT '2024-04', 60000
)
SELECT 
    Month,
    Sales,
    LAG(Sales) OVER (ORDER BY Month) as PrevMonth,
    LEAD(Sales) OVER (ORDER BY Month) as NextMonth,
    
    -- Three-month trend
    CASE 
        WHEN Sales > LAG(Sales) OVER (ORDER BY Month) 
         AND Sales > LEAD(Sales) OVER (ORDER BY Month) THEN 'Peak'
        WHEN Sales < LAG(Sales) OVER (ORDER BY Month) 
         AND Sales < LEAD(Sales) OVER (ORDER BY Month) THEN 'Trough'
        ELSE 'Normal'
    END as TrendPattern
FROM MonthlyData;
