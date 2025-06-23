-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;
USE walmartSales;
-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- ---------------------------FEATURE ENGINEERING---------------------------------------------------------------------
-- time of a day------------------------------------------------------------------------------------------------------

SELECT 
	time,
    (CASE
    WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
    WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
    ELSE "Evening"
    
    END) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

-- day_name-----------------------------------------------------------------------------------------------------------

SELECT 
	date,
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- month name---------------------------------------------------------------------------------------------------------
SELECT
	date,
    MONTHNAME(date) as month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- -------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------Generic---------------------------------------------------------------
-- How many unique cities does the data have?

SELECT
DISTINCT city
FROM sales;

SELECT
COUNT(DISTINCT city)
FROM sales;
-- There are 3 branches (A,B,C)

-- In which city is each branch?
SELECT
DISTINCT city,
branch
FROM sales;
-- Branch A is in Yangon, branch B is in Mandalay, and 
-- -------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------PRODUCT---------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT 
DISTINCT product_line
FROM sales;

SELECT 
COUNT(DISTINCT product_line)
FROM sales;
-- there are 6 unique product lines
-- What is the most common payment method?
SELECT 
payment,
COUNT(payment) AS cnt
FROM sales
GROUP BY payment
ORDER BY cnt DESC;
-- Cash is the most common payment mthod

-- What is the most selling product line?
SELECT 
product_line,
COUNT(product_line) as cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- what is the total revenue by month?
SELECT 
month_name AS months,
SUM(total) as revenue
FROM sales
GROUP BY months
ORDER BY months ;
-- What month had the largest COGS?

SELECT 
month_name AS months,
SUM(cogs) AS cogs
FROM sales
GROUP BY months
ORDER BY cogs DESC;

-- What product line had the largest revenue?

SELECT 
product_line,
SUM(total) AS revenue
FROM sales
GROUP BY  product_line
ORDER BY revenue DESC;

-- What is the city with the largest revenue?
SELECT 
city,
SUM(total) as revenue
FROM sales
GROUP BY city
ORDER BY revenue DESC;

-- What product line had the largest VAT?

SELECT 
product_line,
AVG(tax_pct) AS VAT
FROM sales
GROUP BY product_line
ORDER BY VAT DESC;

-- Fetch each product line and add a column to those product line showing
--  "Good", "Bad". Good if its greater than average sales

SELECT 
product_line,
CASE
WHEN (SELECT AVG(total) >total FROM sales)THEN "Good"
ELSE "Bad" END AS rating
FROM sales;

SELECT 
  product_line,
  SUM(total) AS total_sales,
  CASE 
    WHEN SUM(total) > (
      SELECT AVG(line_sales)
      FROM (
        SELECT SUM(total) AS line_sales
        FROM sales
        GROUP BY product_line
      ) AS avg_subquery
    )
    THEN 'Good'
    ELSE 'Bad'
  END AS rating
FROM sales
GROUP BY product_line;


SELECT * FROM sales;

-- Which branch sold more products than average product sold?
SELECT 
branch,
SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?

SELECT 
gender,
product_line,
COUNT(gender) AS cnt
FROM sales
GROUP BY gender, product_line
ORDER BY cnt DESC;

-- What is the average rating of each product line?

SELECT 
product_line,
ROUND(AVG(rating), 2) AS AVG_rating
FROM sales
GROUP BY product_line
ORDER BY AVG_rating DESC;
-- --------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------SALES------------------------------------------------------------

-- Number of sales made in each time of the day per weekday

SELECT 
time_of_day,
COUNT(*) as total_sales
FROM sales
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?

SELECT 
customer_type,
SUM(total) as revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT 
city,
AVG(tax_pct) as VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most in VAT?
SELECT
customer_type,
avg(tax_pct) as VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT;

-- --------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------CUSTOMER------------------------------------------------------------
-- How many unique customer types does the data have?

SELECT DISTINCT
customer_type
FROM sales;

-- How many unique payment methods does the data have?

SELECT distinct
payment AS payment_method
FROM sales;

-- What is the most common customer type?
SELECT 
customer_type,
COUNT(*) AS cnt
FROM sales
GROUP BY customer_type
ORDER BY cnt DESC;

-- Which customer type buys the most?

SELECT 
customer_type,
SUM(quantity) as total_quantity
FROM sales
GROUP BY customer_type
ORDER BY total_quantity DESC;

-- What is the gender of most of the customers?

SELECT
gender,
COUNT(*) AS gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?

SELECT
gender,
COUNT(*) AS gender_cnt
FROM sales
WHERE branch = 'A'
GROUP BY gender
ORDER BY gender_cnt DESC;

SELECT
gender,
COUNT(*) AS gender_cnt
FROM sales
WHERE branch = 'B'
GROUP BY gender
ORDER BY gender_cnt DESC;

SELECT
gender,
COUNT(*) AS gender_cnt
FROM sales
WHERE branch = 'C'
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Which time of the day do customers give most ratings?
SELECT 
time_of_day,
AVG(rating) as rating
FROM sales
GROUP BY time_of_day
ORDER BY rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT 
time_of_day,
AVG(rating) as rating
FROM sales
WHERE branch = 'C' 
GROUP BY time_of_day
ORDER BY rating DESC;

-- Which day fo the week has the best avg ratings?

SELECT
day_name,
AVG(rating) AS rating
FROM sales
GROUP BY day_name
ORDER BY rating DESC;



-- Which day of the week has the best average ratings per branch?
SELECT
day_name,
AVG(rating) AS rating
FROM sales
WHERE branch = 'A'   -- check for B and C  as well
GROUP BY day_name
ORDER BY rating DESC;


