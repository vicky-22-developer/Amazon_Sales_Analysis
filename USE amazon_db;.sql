 USE amazon_db;
 SELECT*FROM amzon_sales
 LIMIT 10;

-- --1. Total number of order
SELECT COUNT(*) AS Total_orders
from amzon_sales;

-- --2. Total Revenue
SELECT SUM(Amount) as total_revenue
from amzon_sales;

-- 3. Order by status
SELECT Status, COUNT(*) AS total_order
FROM amzon_sales
GROUP BY Status 
ORDER BY total_order DESC;

-- --4. Unique Product cataegory
SELECT distinct Category
FROM amzon_sales 
ORDER BY Category;

-- --5. Average order values
SELECT AVG(Amount) as Avg_Order
FROM amzon_sales;

-- -- 6. How many orders are B2B
SELECT B2B,COUNT(*) as total_order
FROM amzon_sales
GROUP BY B2B;
 
 -- --7.  Month wise heighest number of order
SELECT Order_Month,COUNT(*) as total_order
FROM amzon_sales
GROUP BY Order_Month
order by total_order DESC
LIMIT 1;

-- 8. Find the Top 10 States by Total Revenue.
SELECT `ship-state`, SUM(Amount) as total_revenue
FROM amzon_sales
GROUP BY `ship-state`
ORDER BY total_revenue DESC
LIMIT 10;
-- 9. Find Total Revenue and Units Sold for each Category.
SELECT Category, SUM(Amount) as total_revenue,SUM(Qty) as total_unit_sold,AVG(Amount) as agv_revenue
FROM amzon_sales
GROUP BY Category 
ORDER BY total_revenue DESC;

-- 10. What is the overall Cancellation Rate in percentage?
SELECT ROUND (COUNT(case when status = 'cancelled' then 1 end)*100/COUNT(*),2) as cancellation_rate_pct
FROM amzon_sales;

-- 11. Compare Expedited vs Standard Shipping usage.
SELECT 
    `ship-service-level`,
    COUNT(*) AS total_orders,
    ROUND(AVG(amount), 2) AS avg_order_value,
    ROUND(SUM(amount),2) AS total_revenue
FROM amzon_sales
GROUP BY `ship-service-level`
ORDER BY total_orders DESC;

-- 12. Find Monthly Revenue along with its % share of total revenue.
select `ship-service-level`,count(*) as total_order,ROUND(avg(Amount),2) as avg_order_value,ROUND(SUM(Amount),2) as total_revenue
from amzon_sales
group by `ship-service-level`
order by total_order desc;

-- 13. Which are the Top 5 Cities by number of orders?
SELECT `ship-city`, COUNT(*) as total_order
FROM amzon_sales
WHERE Status ='shipped'
GROUP BY `ship-city`
ORDER BY total_order DESC
LIMIT 5;

-- 14. Compare Revenue between Amazon Fulfilled vs Merchant Fulfilled orders.
SELECT Fulfilment,COUNT(*) AS total_order,ROUND(SUM(Amount),2) as total_revenue,ROUND(avg(Amount),2) as agv_revenue
FROM amzon_sales
group by  Fulfilment
order by total_revenue DESC;

-- 15. Find the Cancellation Rate % for each Category.
select category,
		count(*) as total_orders,
        count(case when status='cancelled' then 1 end) as cancelled_orders,
        round(count(case when status='cancelled' then 1 end) *100/count(*),2) as cancellation_rate_pct
from amzon_sales
group by category
order by cancellation_rate_pct desc;



-- 16. Classify States into Top, Mid and Low Tier based on Revenue.
with state_revenue as(
	select `ship-state`,
        sum(Amount)  as total_revenue,
        ntile(3) over(order by sum(Amount) desc) as tier
	from amzon_sales
    group by `ship-state`
)
select `ship-state`,total_revenue,
		case tier
				when 1 then 'Top Tier'
                when 2 then 'Mid Tier'
                when 3 then 'Low Tier'
		end as state_tier
from state_revenue
order by total_revenue desc;
        
-- 17. Find the Top Performing Category for each Month.
WITH monthly_cat AS (
    SELECT
        order_month,
        MIN(Date) AS month_start,
        category,
        ROUND(SUM(amount),2) AS revenue,
        RANK() OVER (
            PARTITION BY order_month
            ORDER BY SUM(amount) DESC
        ) AS rnk
    FROM amzon_sales
    GROUP BY order_month, category
)
SELECT order_month, category, revenue
FROM monthly_cat
WHERE rnk = 1
ORDER BY month_start;