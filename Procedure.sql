-- STORED PROCEDURES vs FUNCTIONS: Key Differences

-- ==========================================
-- STORED PROCEDURES
-- ==========================================

-- 1. Creation and Execution
CREATE PROCEDURE GetEmployeesByDept(@DeptID INT)
AS
BEGIN
    SELECT * FROM Employees WHERE DepartmentID = @DeptID;
    UPDATE Departments SET LastAccessed = GETDATE() WHERE ID = @DeptID;
END;

-- Called using EXEC or EXECUTE
EXEC GetEmployeesByDept @DeptID = 1;
EXECUTE GetEmployeesByDept 1;

-- 2. Can perform multiple operations
CREATE PROCEDURE ProcessOrderTransaction(@OrderID INT, @CustomerID INT)
AS
BEGIN
    BEGIN TRANSACTION;
    
    INSERT INTO Orders (OrderID, CustomerID, OrderDate) 
    VALUES (@OrderID, @CustomerID, GETDATE());
    
    UPDATE Customers SET LastOrderDate = GETDATE() 
    WHERE CustomerID = @CustomerID;
    
    SELECT 'Order processed successfully' AS Result;
    
    COMMIT TRANSACTION;
END;

-- ==========================================
-- FUNCTIONS
-- ==========================================

-- 1. Scalar Function - returns single value
CREATE FUNCTION CalculateAge(@BirthDate DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @BirthDate, GETDATE());
END;

-- Called within SELECT statements or expressions
SELECT Name, dbo.CalculateAge(BirthDate) AS Age 
FROM Employees;

-- 2. Table-Valued Function - returns table
CREATE FUNCTION GetEmployeesByDepartment(@DeptName VARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT e.*, d.DepartmentName
    FROM Employees e
    INNER JOIN Departments d ON e.DepartmentID = d.ID
    WHERE d.DepartmentName = @DeptName
);

-- Called like a table in FROM clause
SELECT * FROM dbo.GetEmployeesByDepartment('Sales');

-- ==========================================
-- KEY DIFFERENCES SUMMARY
-- ==========================================

/*
STORED PROCEDURES:
- Called using EXEC/EXECUTE
- Can perform DML operations (INSERT, UPDATE, DELETE)
- Can have multiple result sets
- Can use transactions
- Can have OUT parameters
- Cannot be used in SELECT statements
- Can call other procedures and functions
- Used for complex business logic

FUNCTIONS:
- Called within expressions or FROM clauses
- Cannot perform DML operations (read-only)
- Must return a value (scalar or table)
- Cannot use transactions
- Only IN parameters
- Can be used in SELECT, WHERE clauses
- Cannot call procedures
- Used for calculations and data retrieval

WHEN TO USE WHAT:
- Use PROCEDURES for: Business processes, data modifications, complex workflows
- Use FUNCTIONS for: Calculations, data transformations, reusable expressions
