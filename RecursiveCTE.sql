with recursive cte as (
  select 1 as n
  union all 
  select n+1 from cte where n < 3
)

-- base conditon 
-- union all
--recursive condition

-- in sql we do recursion in toop down manner where we start from top and let condition follow to bootom
