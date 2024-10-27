-- bitwise

SELECT IF(1 & 1 , 'TRUE' , 'FALSE');

SELECT IF(1 & 0 , 'TRUE' , 'FALSE');

SELECT IF(1 | 1 , 'TRUE' , 'FALSE');

SELECT IF(0 | 1 , 'TRUE' , 'FALSE');

SELECT IF(0 | 0 , 'TRUE' , 'FALSE');

SELECT (4 >> 1) AS "RIGHT SHIFT (HALF)";

SELECT (1 << 2) AS "LEFT SHIFT (POWER OF 2)";

SELECT BIT_COUNT(5) AS "SET BIT IN 5";


-- comparison 

select if( 3 > 4 , 'Greater' , 'Smaller');

select if( 2 < 1 , 'Smaller' , 'Greater');

select if(3 >= 3 , 'Greater than or equal' , 'Smaller');

select if( 4 <= 3 , 'Smaller than or equal' , 'Greater');

select if( 'a' = 'a' , 'Equal' , 'Not Equal');

select if('a' != 'b' , 'Not Equal' , 'Equal' );


-- arithematic

select 2 + 2 as "Addition";

select 3 * 3 as "Multiplication";

select 4 % 2 as "Remainder";

select 4 / 2 as "Quotient";

select 4 - 4 as "Subtraction";


-- LOGICAL OPERTORS

-- AND : BOTH CONDITION MUST BE TRUE
SELECT TRUE && FALSE AS "AND"; 

-- OR : IF ANY OF THE CONDITION GETS TRUE
SELECT TRUE || FALSE AS "OR";

-- OPPOSITE OF VALUE
SELECT !TRUE AS "NOT TRUE";

-- TRUE ONLY WHEN BOTH ARE DIFFERENT
SELECT TRUE XOR TRUE AS "XOR";




-- assign operator

-- create a variable using '@'
-- set is used to assign value to variable
set @num1 = 4, @num2 = 4;

set @num1 = @num1 + @num2;

select @num1;

-- you can also assign values  by :=
select @num3 := 5 , @num5 := 6;
select @num3 + @num5 as "Sum";




--  functions : 

-- abs  : absolute values

select abs(-4) as "positive" 

select @a := 3 , @b := 5;

select abs(@a- @b) as "abs(a - b)"; 


-- ADDDATE('DATE' , TIME INTERVAL) OR DATE_ADD( 'DATE' , TIME INTERVAL) : IT WILL ADD THE DURATION TO FIRST ARGUMENT

SELECT DATE_ADD('2025-08-01' , INTERVAL 31 DAY ) AS "1 MONTH AFTER 1 AUGUST 2025";

SELECT ADDDATE('2025-08-01' , INTERVAL 365 DAY) AS "1 YEAR AFTER 1 AUGUST 2025";


-- AVG : GET AVERAGE OF THE VALUES 

CREATE TABLE SCORES(
  MATH_SCORE INT,
  SCIENCE_SCORE INT,
  GK_SCORE INT
);

INSERT INTO SCORES VALUES(100,200,150) , (250,350,150) , (130,160,170);

SELECT AVG(MATH_SCORE) AS "MATH AVERAGE SCORE" FROM SCORES;

CREATE TABLE SCORES(
  MATH_SCORE INT,
  SCIENCE_SCORE INT,
  GK_SCORE INT
);



-- BETWEEN AND : EXTRACT VALUE BETWEEN THE RANGE 

CREATE TABLE SCORES(
  MATH_SCORE INT,
  SCIENCE_SCORE INT,
  GK_SCORE INT
);

INSERT INTO SCORES VALUES(100,200,150) , (250,350,150) , (130,160,170);

SELECT MATH_SCORE FROM SCORES WHERE MATH_SCORE BETWEEN 100 AND 200


-- CASE : IT'S LIKE PATTERN MATCHING IN SCALA OR (SWITCH IN CPP)
CREATE TABLE INFO(
  PERSON_ID INT,
  AGE INT,
  NAME VARCHAR(15),
  GENDER INT
);

INSERT INTO INFO VALUES(1, 23 , 'RAMESH' , 1) , (2, 19, 'AKSHITA' , 0) , (3, 45 , 'RAJESH' , 1), (4 , 35 , 'KEMINI' , 0);

SELECT CASE GENDER WHEN 1 THEN 'MALE' WHEN 0 THEN 'FEMALE' END FROM INFO;




-- CAST() : CONVERSION OF VARIABEL FORM 1 DATATYPE T ANOTHER 
SELECT  @VAL1 := 4;

SELECT CAST(@VAL1 AS CHAR) AS "CHARACTER VALUE";


-- CEIL() : SMALLEST  VALUE GREATER TAHN ARGUMENT
SELECT CEIL(4.45) AS "CEIL OF 4.45"


-- FLOOR() : GREATEST VALUE SMALLER THAN ARGUMENT
SELECT FLOOR(4.75) AS "CEIL OF 4.75"


-- CHAR_LENGTH() : RETURN LENGTH OF STRING
SELECT CHAR_LENGTH("HI HOW ARE YOU") AS "LENGTH";


-- COALESCE() : SELECT FIRST NON-NULL VALUE IF PRESENT OTHERWISE RETURN NULL
SELECT COALESCE(NULL , NULL , 4 ,NULL , 5 , NULL) AS "FIRST NON NULL VALUES"
SELECT COALESCE(NULL , NULL , NULL) AS "VALUE IF ALL NULL"


-- CONCAT() : CONCATENTAION OF ALL ARGUMENTS
SELECT CONCAT("S" , "q" , "l") AS "CONCATENATED STRING"



-- COUNT()  : RETURN NUMBER OF RECORDS
CREATE TABLE SCORES(
  SCORE INT
);

INSERT INTO SCORES VALUES (1) , (2) , (3) , (NULL) , (NULL);

-- IT WILL COUNT BOTH NON-NULL AND NULL VALUES 
SELECT COUNT(*) FROM SCORES;

-- IT WILL ONLY COUNT NON NULL ENTRIES
SELECT COUNT(SCORE) FROM SCORES;