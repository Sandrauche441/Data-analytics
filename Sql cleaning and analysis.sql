--1. DATA CLEANING FOR CUSTOMER DEMOGRAPHIC
SELECT * FROM [dbo].[CustomerDemographic] 
--A.CHECK FOR NULLS AND FILL Let's check the data and see if there are empty or null cells.
SELECT *
FROM CustomerDemographic
WHERE
  customer_id IS NULL
  OR first_name IS NULL
  OR last_name IS NULL
  OR gender IS NULL
  OR past_3_years_bike_related_purchases IS NULL
  OR DOB IS NULL
  OR job_title IS NULL
  OR job_industry_category IS NULL
  OR wealth_segment IS NULL
  OR deceased_indicator IS NULL
  OR owns_car IS NULL
  OR tenure IS NULL;
  
 --Ai). LET'S remove the unneccessary columns like 'default' 
  ALTER TABLE [dbo].[CustomerDemographic]
 DROP COLUMN [default]
 ALTER TABLE [dbo].[CustomerDemographic]
 DROP COLUMN F11

 --Aii).Lets fill the job_industry_category, for all the Structural Engineer has job_industry_category as n/a, except one which is 'Property'
--lets fill the others as 'Property' in the job_industry_category
--select * from [dbo].[CustomerDemographic] where  job_title = 'Structural Engineer'
UPDATE [dbo].[CustomerDemographic]
SET job_industry_category = 'Property' where job_title = 'Structural Engineer'

SELECT * FROM [dbo].[CustomerDemographic] WHERE  job_title = 'Structural Engineer'
--lets fill the others as 'Property' in the job_industry_category

UPDATE [dbo].[CustomerDemographic]
SET job_industry_category = 'Property' where job_title = 'Structural Engineer'

--Aiii). Lets check the other job_industry_category with n/a and try to populate with information from job_title
select * from [dbo].[CustomerDemographic] where  job_industry_category = 'n/a' 
select * from [dbo].[CustomerDemographic] where  job_title = 'Senior Editor'
select * from [dbo].[CustomerDemographic] where job_title IS NULL 

UPDATE [dbo].[CustomerDemographic]
SET job_industry_category = 'Financial Services' where job_title = 'Media Manager iv'
SELECT * FROM [dbo].[CustomerDemographic] WHERE  job_title = 'Structural Engineer'


  --B. LETS CHECK DISTINCT ROWS FOR ALL THE COLUMNS AND UPDATE TO CORRECT FORMAT. 
  --FOR GENDER
  SELECT DISTINCT gender FROM [dbo].[CustomerDemographic];

-- lets conform them to just Female, Male or U. 
UPDATE [dbo].[CustomerDemographic]
SET gender = 'Male'
WHERE gender= 'M';
UPDATE [dbo].[CustomerDemographic]
SET gender = 'Female'


--C. STANDARDIZE THE DATE FORMAT 
--First check the datatype for [CustomerDemographic$] table
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CustomerDemographic'

--ITS DATETIME, LETS CHANGE IT TO DATE TYPE ONLY

ALTER TABLE [dbo].[CustomerDemographic]
ALTER COLUMN [DOB] DATE

-- Next is to change it to age instead of date of birth, add a new column first, then get the age
ALTER TABLE [dbo].[CustomerDemographic]
ADD [Customer's age] int

UPDATE [dbo].[CustomerDemographic]
SET [Customer's age] = DATEDIFF (YEAR, [DOB], GETDATE())
   SELECT * FROM [dbo].[CustomerDemographic]

--LET'S CHECK THE MAX AND MIN AGE
SELECT MAX([Customer's age]) AS MaxAge, MIN([Customer's age]) AS MinAge
FROM [dbo].[CustomerDemographic];
--NOW LET'S GROUP THE AGES SINCE WE KNOW THE highest and lowest ALREADY

ALTER TABLE [dbo].[CustomerDemographic]
ADD Age_group VARCHAR(50)

UPDATE CustomerDemographic
SET Age_group = 
CASE
  WHEN [Customer's age] BETWEEN 20 AND 29 THEN '20s'
  WHEN [Customer's age] BETWEEN 30 AND 39 THEN '30s'
  WHEN [Customer's age] BETWEEN 40 AND 49 THEN '40s'
  WHEN [Customer's age] BETWEEN 50 AND 59 THEN '50s'
  WHEN [Customer's age] BETWEEN 60 AND 69 THEN '60s'
   WHEN [Customer's age] IS NULL THEN 'NULL'
  ELSE '70s and Above'
END 

--D. SOME OF THE SPELLING ARE WRONG, LETS CHANGE THAT UPDATE [dbo].[CustomerAddress]

UPDATE [dbo].[CustomerDemographic]
SET job_industry_category = 'Agriculture'
WHERE job_industry_category = 'Argiculture';


-- 2. DATA CLEANING FOR TRANSACTION TABLE

--A. TO CHECK IF THE DATA TYPES ARE MATCHING

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesTransaction'

--B.  product_first_sold_date is float, we need to convert it to datetime.

ALTER TABLE [dbo].[SalesTransaction]
ALTER COLUMN product_first_sold_date DATETIME;
ALTER TABLE [dbo].[SalesTransaction]
ALTER COLUMN product_first_sold_date DATE;

--C. ALSO CHANGE TRANSACTION DATETIME TO DATE 
ALTER TABLE [dbo].[SalesTransaction]
ALTER COLUMN transaction_date DATE;

--TO CHECK FOR NULL VALUES, WHERE BRAND IS NULL. 
SELECT * FROM [dbo].[SalesTransaction] where brand IS NULL
SELECT * FROM [dbo].[SalesTransaction] where brand = 'n/a'

--WHERE BRAND IS NULL ALSO HAVE EMPTY PRODUCT LINE, PRODUCT SIZE, STANDARD COST AND PRODUCT FIRST SOLD DATE. SO IT IS UNLIKELY THE
--THE DATA IS OF ANY USE, SO WE WILL DELETE THE DATA WHERE BRAND IS NULL.

DELETE FROM  [dbo].[SalesTransaction]
WHERE brand is null



--3. DATA CLEANING FOR CUSTOMER ADDRESS 
--State: Inconsistencies are observed in the usage of initials and full names.
--We should use the DISTINCT function to identify and rectify these inconsistencies, 
--ensuring uniformity throughout the dataset.

--CHECK DISTINCT ROWS FOR STATE
SELECT * FROM [dbo].[CustomerAddress] 
SELECT DISTINCT state FROM [dbo].[CustomerAddress]

-- Conform the VICTORIA to Vic, and New South wales to NSW. 
UPDATE [dbo].[CustomerAddress]
SET state = 'Vic' where state = 'Victoria'

UPDATE [dbo].[CustomerAddress]
SET state = 'NSW' where state = 'New South Wales'

SELECT DISTINCT property_valuation FROM [dbo].[CustomerAddress] order by property_valuation
--We have 12 distinct property valuations.


--4. JOINING THE TABLES WITH THE NEEDED COLUMNS
--NOW WE HAVE ALL THE COLUMNS WE NEED, LETS MAKE A NEW TABLE TO EXCLUDE ALL THE COLUMNS THAT WE DONT NEED AND AT THE SAME TIME JOIN IT TO THE ADDRESS TABLE
--A Joining the customer demographics with customer Address. WE WILL MAKE THIS THE TABLE FROM WHICH WE QUERY OFF FROM
DROP TABLE IF EXISTS UNIFIEDTHREE
SELECT 
       cd.[customer_id]
      ,cd.[gender]
      ,cd.[past_3_years_bike_related_purchases]
      ,cd.[job_industry_category]
      ,cd.[wealth_segment]
      ,cd.[owns_car]
      ,cd.[tenure]
      ,cd.[Age_group]
      ,ca.[postcode]
      ,ca.[state]
      ,ca.[property_valuation]
	   ,t.[transaction_id]
       ,t.[product_id]
      , t.[transaction_date]
      , t.[brand]
      , t.[product_line]
      , t.[product_class]
      , t.[product_size]
      , t.[list_price]
      , t.[standard_cost]
      , t.[product_first_sold_date]
	  INTO  UNIFIEDTHREE
      FROM [dbo].[CustomerDemographic] cd 
	  INNER JOIN [dbo].[CustomerAddress] ca ON cd.[customer_id] = ca.[customer_id]
      INNER JOIN [dbo].[SalesTransaction] t ON  cd.[customer_id] = t.[customer_id] 
 
 --NEXT IS TO ADD A COLUMN TO GET THE VALUE FOR EACH PRODUCT BY SUBTRACTING STANDARD_COST FROM LIST_PRICE. 

--ONCE MORE CHECK THE DATA, OBSERVED THAT WHEREEVER THERE IS GENDER 'U', THE AGE GROUP AND TENURE IS NULL.
--ITS BETTER TO REMOVE THEM AS IT WONT BE USEFUL IN THE ANALYSES
DELETE FROM [dbo].[UnifiedData]   WHERE gender = 'U'
	
--5. ANALYSES OF CUSTOMER SEGMENTATION

--TOP 10 CUSTOMERS BY NUMBER OF TRANSACTIONS AND THEIR TOTAL PURCHASE VALUE

SELECT TOP 10
    ut.Customer_Id, COUNT(Transaction_Id) AS Transaction_Count,
	ut.State, cd.[Customer's age], 
	ut.gender,
	--ROUND(SUM(ut.list_price),0) AS Total_purchase_value, 
	CONCAT(cd.first_name , ' ', cd.last_name) AS Customers_name,
	cd.Tenure
FROM 
    [dbo].[UNIFIEDTHREE] ut INNER JOIN [dbo].[CustomerDemographic] cd ON ut.Customer_Id = cd.Customer_Id 
GROUP BY 
      ut.Customer_Id, ut.State, cd.[Customer's age] , ut.gender, cd.first_name , cd.last_name, cd.Tenure
	  --list_price
	ORDER BY Transaction_Count DESC

--VALUE OF PURCHASE FOR EACH AGE GROUP
SELECT
    Age_group, Round(SUM(list_price),0) AS Total_purchase_value
    --gender
FROM
    UNIFIEDTHREE
	WHERE Age_group <> 'NULL'
GROUP BY
	   Age_group
	   --gender
	ORDER BY  Total_purchase_value DESC
	
	--Number of bike purchase and avg purchase value for each gender
	SELECT
    gender, Round(Avg(list_price),0) AS total_purchase_value,
    ROUND(SUM(distinct(past_3_years_bike_related_purchases)),0) AS total_bike_purchases
FROM
    UNIFIEDTHREE
	WHERE gender <> 'NULL'
GROUP BY
	  gender
	ORDER BY  total_bike_purchases DESC , gender DESC
	
--. Calculate the total number of bike-related purchases made by different industry group customer over the past 3 years.

SELECT job_industry_category,ROUND(SUM(DISTINCT(past_3_years_bike_related_purchases)),0) AS last_three_years_bike_purchases ,  
 Round(SUM(list_price),0) AS total_purchase_value

FROM [dbo].[UNIFIEDTHREE]
WHERE job_industry_category <> 'n/a'
GROUP BY job_industry_category
ORDER BY total_purchase_value desc


-- lets identify high-value customers based on their total purchase value.
with total_purchase  as (SELECT customer_id, ROUND(Sum(List_Price),0) AS Total_Purchase_value 
rank () partition by customer_id order by ROUND(Sum(List_Price),0) )
FROM [dbo].[UNIFIEDTHREE]
GROUP BY Customer_id )
--ORDER BY Total_Purchase_value DESC)
select 

customer_id, ROUND(Sum(List_Price),0) from [dbo].[UNIFIEDTHREE]
WITH total_purchase AS (
    SELECT customer_id, ROUND(SUM(List_Price), 0) AS Total_Purchase_value,
           DENSE_RANK() OVER (ORDER BY ROUND(SUM(List_Price), 0) DESC) AS Purchase_rank
    FROM [dbo].[UNIFIEDTHREE]
    GROUP BY customer_id
)
SELECT customer_id, Total_Purchase_value
FROM total_purchase
WHERE Purchase_rank = 2;



--group customers total purchase value based on their ages
SELECT Age_group, round(sum(List_Price),0) AS Total_Purchase_value 
FROM [dbo].[UNIFIEDTHREE]
WHERE Age_group <> 'NULL'
GROUP BY Age_group 
ORDER BY Total_Purchase_value DESC

-- Group customers by their total purchase value
SELECT
    CASE
        WHEN Customers_Purchase_range = '<2000' THEN '<2000'
        WHEN Customers_Purchase_range = '2001-5000' THEN '2001-5000'
        WHEN Customers_Purchase_range = '5001-10000' THEN '5001-10000'
        ELSE '>10000'
    END AS Purchase_range,
	   COUNT(customer_id) AS Number_of_Customers,
    CASE
        WHEN Customers_Purchase_range = '<2000' THEN 'Very_Low_purchase_customers'
        WHEN Customers_Purchase_range = '2001-5000' THEN 'Low_purchase_customers'
        WHEN Customers_Purchase_range = '5001-10000' THEN 'Middle_purchase_customers'
        ELSE 'High_purchase_customers'
    END AS Customer_class
FROM (
    SELECT
        customer_id,
        ROUND(SUM(List_Price), 0) AS Total_Purchase_value,
        CASE
            WHEN ROUND(SUM(List_Price), 0) < 2000 THEN '<2000'
            WHEN ROUND(SUM(List_Price), 0) BETWEEN 2001 AND 5000 THEN '2001-5000'
            WHEN ROUND(SUM(List_Price), 0) BETWEEN 5001 AND 10000 THEN '5001-10000'
            ELSE '>10000'
        END AS Customers_Purchase_range
    FROM [dbo].[UNIFIEDTHREE]
    GROUP BY customer_id
) AS subquery
GROUP BY Customers_Purchase_range
ORDER BY Number_of_Customers;


-- LETS FIND OUT THE demographic distribution of those with high Total_Purchase_value
SELECT count(distinct customer_id)No_customer_per_state, state, brand, round(SUM(List_Price),0) AS Total_Purchase_value FROM [dbo].[UNIFIEDTHREE]
GROUP BY  state , brand
ORDER BY Total_Purchase_value desc, No_customer_per_state DESC

--Most Popular Brands and Product Lines by Number of Purchases:
	SELECT 
	brand, Product_line ,
	COUNT(*) AS product_line_count
	FROM
    UNIFIEDTHREE
GROUP BY
  brand,   Product_line
ORDER BY
    product_line_count DESC;
	-- Most profitable product_lines
SELECT TOP 10
    product_id,
    ROUND(SUM(list_price - standard_cost),0) AS total_profit
FROM
    UNIFIEDTHREE
GROUP BY
    product_id
ORDER BY
    total_profit DESC


	--1. Identify the top 5 most profitable product lines:

	SELECT Product_line, ROUND(AVG(list_price - standard_cost),0) Avg_profit FROM  
[dbo].[UNIFIEDTHREE] GROUP BY product_line


--Analyze the profitability trend over time by calculating the total profit per month
SELECT DATEPART(month, transaction_date) AS month, ROUND(avg(list_price - standard_cost),0) AS total_profit
FROM UNIFIEDTHREE
GROUP BY DATEPART(year and month, transaction_date);

SELECT MONTH(transaction_date) AS month, YEAR(transaction_date), ROUND(avg(list_price - standard_cost),0) AS total_profit
FROM UNIFIEDTHREE
GROUP BY MONTH(transaction_date) , YEAR(transaction_date)

--CLV
SELECT
    customer_id,
    SUM(list_price) AS total_profit,
    DATEDIFF(YEAR, MIN(product_first_sold_date), MAX(transaction_date)) AS customer_lifetime,
    CASE
        WHEN  DATEDIFF(YEAR, MIN(product_first_sold_date), MAX(transaction_date)) < 5 THEN 'short_cycle_customer'
        WHEN  DATEDIFF(YEAR, MIN(product_first_sold_date), MAX(transaction_date)) BETWEEN 5 AND 10 THEN 'Avg_cycle'
        WHEN  DATEDIFF(YEAR, MIN(product_first_sold_date), MAX(transaction_date)) BETWEEN 11 AND 19 THEN 'middle'
        WHEN  DATEDIFF(YEAR, MIN(product_first_sold_date), MAX(transaction_date)) BETWEEN 20 AND 26 THEN 'high_life_cycle'
        ELSE 'unknown'
    END AS lyftime
FROM
    [dbo].[UNIFIEDTHREE]
GROUP BY
    customer_id

	order by total_profit, customer_lifetime


	--CLV for each customer, and their number of purchases

	SELECT Customer_id, COUNT(Transaction_id)AS NO_OF_PURCHASES, 
	DATEDIFF (MONTH, MIN(Transaction_date), MAX(Transaction_date))-
	CASE
	WHEN MIN(Transaction_date) > MAX (Transaction_date) THEN 1
	ELSE 0     END AS customer_lifetime_months
	FROM UNIFIEDTHREE
	GROUP BY Customer_id


--the total purchase value or the average purchase amount for customers with the same customer lifetime months.

	SELECT customer_lifetime_months, 
	COUNT(Customer_id) AS no_of_customers, 
	ROUND(AVG(total_purchase_value),0) AS avg_purchase_clv
FROM (
    SELECT Customer_id, 
        CONCAT(DATEDIFF(MONTH, MIN(Transaction_date), MAX(Transaction_date)), ' ', 'Months')

		AS customer_lifetime_months,
        SUM(list_price) AS total_purchase_value
    FROM UNIFIEDTHREE
    GROUP BY Customer_id
) AS Subquery
GROUP BY customer_lifetime_months;


	
	
	----Write a query that calculates the average purchase customer lifetime months for customers in different age groups
	--(e.g., based on the "DOB" column) to analyze the relationship between age and customer lifetime.	
SELECT 
DATENAME(MONTH, DATEADD(MONTH, customer_lifetime_months -1 , '1900-01-01')) AS  month_name,
    COUNT(Customer_id) AS no_of_customers, 
    SUM(NO_OF_PURCHASES) AS no_of_purchase_times,
    ROUND(AVG(total_purchase_value), 0) AS avg_purchase_clv
FROM (
    SELECT Customer_id, COUNT(Transaction_id) AS NO_OF_PURCHASES,
        DATEPART(MONTH, Transaction_date) AS customer_lifetime_months,
        SUM(list_price) AS total_purchase_value
    FROM UNIFIEDTHREE
    GROUP BY Customer_id, DATEPART(MONTH, Transaction_date)
) AS Subquery
GROUP BY customer_lifetime_months;


--Which month had the most profit

SELECT 
        DATEname(MONTH, Transaction_date) AS month,
        ROUND(SUM(list_price- standard_cost),0) AS total_sales_profit
    FROM UNIFIEDTHREE
    GROUP BY DATEname(MONTH, Transaction_date)
	order by total_sales_profit desc
