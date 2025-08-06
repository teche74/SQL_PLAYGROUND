-- left join : all the records from left table and common records between both table
select table1.*, table2.* from table1 left join table2 on table1.common_column = table2.common_column group by x where condition;

-- right join : all the records from right table and common records between both table
select table1.*, table2.* from table1 right join table2 on table1.common_col = table2.coomon_col group by x where condition;

-- self join : link table with itself
select table1.col1 , table2.col2  from table1 join table1 on table1.col1 = table1.col2 group by x where condition;

-- full join
SELECT table1.*, table2.* 
FROM table1 
LEFT JOIN table2 ON table1.common_column = table2.common_column 
WHERE condition

UNION

SELECT table1.*, table2.* 
FROM table1 
RIGHT JOIN table2 ON table1.common_column = table2.common_column 
WHERE table1.common_column IS NULL AND condition;
