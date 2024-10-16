
-- Create TABLE

CREATE TABLE retail_sales(
transaction_id INT PRIMARY KEY,	
sale_date DATE,	 
sale_time TIME,	
customer_id	INT,
gender	VARCHAR(15),
age	INT,
category VARCHAR(15),	
quantity	INT,
price_per_unit FLOAT,	
cogs	FLOAT,
total_sale FLOAT
);


-- to check the data in the table

select * from retail_sales;


-- to count the number of rows in the table

 SELECT COUNT(*) FROM retail_sales;


-- Data Cleaning

SELECT * FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
--

DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;


-- Data Exploration

-- How many sales we have?

SELECT COUNT(*) as total_sale FROM retail_sales;


-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales;


-- How many uniuque category we have ?

SELECT DISTINCT category FROM retail_sales


-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Find all sales where the category is 'Electronics'.
-- Q.4 Calculate the total COGS (cost of goods sold) for each sale date.
-- Q.5 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.6 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.7 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.8 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.9 Find the most common sale time from the table.
-- Q.10 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.11 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.12 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.13 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
-- Q.14 Calculate the average spending (total_sale) for each age group (e.g., under 30, 30-40, 40-50, etc.).
-- Q.15 Identify transactions where the total sale is less than the sum of the product's quantity * price_per_unit (indicating a discount).
-- Q.16 Calculate the profit margin for each transaction as a percentage of the total sale.
-- Q.17 Identify customers who have not made a purchase in the last 6 months.
-- Q.18 Calculate the 7-day moving average of total sales for trend analysis.
-- Q.19 Identify the customers who have the highest number of transactions.
-- Q.20 For each transaction, calculate the profit margin percentage ((total_sale - cogs) / total_sale).

sql
 -- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

select * from retail_sales where sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

select * from retail_sales where category='Clothing'
	and
	to_char(sale_date,'YYYY-MM')='2022-11'
	and
	quantity >=4;


-- Q.3 Find all sales where the category is 'Electronics'.

select * from retail_sales where category = 'Electronics';


-- Q.4 Calculate the total COGS (cost of goods sold) for each sale date.

select sale_date, sum(cogs) as total_cogs from retail_sales
group by sale_date;


-- Q.5 Write a SQL query to calculate the total sales (total_sale) for each category.

select category,sum(total_sale) as net_sale,count(*) as total_orders from retail_sales
group by 1;


-- Q.6 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

select avg(age) as Avg_Age from retail_sales where category='Beauty';


-- Q.7 Write a SQL query to find all transactions where the total_sale is greater than 1000.

select * from retail_sales where total_sale > 1000;


-- Q.8 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

select category,gender,count(*) as total_trans from retail_sales 
group by category,gender 
order by 1;

-- Q.9 Find the most common sale time from the table.

select sale_time, COUNT(*) as sale_count from retail_sales
group by sale_time
order by sale_count desc
limit 1;


-- Q.10 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

select year,month,avg_sale from (
	select Extract(year from sale_date) as year,
	Extract(month from sale_date) as month,
	avg(total_sale) as avg_sale,
	rank() over(partition by Extract(year from sale_date) order by avg(total_sale) desc) as rank
from retail_sales
group by 1,2
) as total
where rank=1;


-- Q.11 Write a SQL query to find the top 5 customers based on the highest total sales 

select customer_id,sum(total_sale) as total_sales from retail_sales
group by 1
order by 2 desc
limit 5;


-- Q.12 Write a SQL query to find the number of unique customers who purchased items from each category.

select category,count(distinct customer_id) as cnt_unique_cs from retail_sales
group by category;


-- Q.13 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

with hourly_sale
as
(
select *,
    case
        when extract(HOUR from sale_time) < 12 then 'Morning'
        when extract(HOUR from sale_time) between 12 and 17 then 'Afternoon'
        else 'Evening'
    end as shift
from retail_sales
)
select shift, count(*) as total_orders from hourly_sale
group by shift;


-- Q.14 Calculate the average spending (total_sale) for each age group (e.g., under 30, 30-40, 40-50, etc.).

select 
    case 
        when age < 30 then 'Under 30'
        when age between 30 and 40 then '30-40'
        when age between 40 AND 50 then '40-50'
        else '50 and above'
    end as age_group,
    AVG(total_sale) as avg_spending
from retail_sales
group by age_group
order by avg_spending desc;


-- Q.15 Identify transactions where the total sale is less than the sum of the product's quantity * price_per_unit (indicating a discount).

select transaction_id, total_sale, (quantity * price_per_unit) as expected_sale
from retail_sales
where total_sale < (quantity * price_per_unit);


-- Q.16 Calculate the profit margin for each transaction as a percentage of the total sale.

select transaction_id, total_sale, cogs,
       ((total_sale - cogs) / total_sale) * 100 as profit_margin_percentage
from retail_sales;


-- Q.17 Identify customers who have not made a purchase in the last 6 months.

select customer_id
from retail_sales
group by customer_id
having max(sale_date) < DATE_SUB(CURDATE(), INTERVAL 6 MONTH);


-- Q.18 Calculate the 7-day moving average of total sales for trend analysis.

select sale_date, total_sale,
    AVG(total_sale) over (order by sale_date rows between 6 preceding and current row) as moving_avg_sales
from retail_sales;


-- Q.19 Identify the customers who have the highest number of transactions.

select customer_id, count(transaction_id) as num_transactions
from retail_sales
group by customer_id
order by num_transactions desc
limit 10;


-- Q.20 For each transaction, calculate the profit margin percentage ((total_sale - cogs) / total_sale).

select transaction_id, total_sale, cogs, 
       ((total_sale - cogs) / total_sale) * 100 as profit_margin_percentage
from retail_sales;


-- End of project

