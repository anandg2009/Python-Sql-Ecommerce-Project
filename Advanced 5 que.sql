# 1) Calculate the moving average of order values for each customer over their order history.

SELECT customer_id, 
       order_purchase_timestamp, 
       payment,
       AVG(payment) OVER (PARTITION BY customer_id 
                          ORDER BY order_purchase_timestamp
                          ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS mov_avg
FROM (
    SELECT o.customer_id, 
           o.order_purchase_timestamp, 
           p.payment_value AS payment
    FROM payments p
    JOIN orders o ON p.order_id = o.order_id
) AS a;

# 2) Calculate the cumulative sales per month for each year

SELECT years,
       months,
       payment,
       SUM(payment) OVER (ORDER BY years, months) AS cumulative_sales
FROM (
    SELECT YEAR(o.order_purchase_timestamp) AS years,
           MONTH(o.order_purchase_timestamp) AS months,
           ROUND(SUM(p.payment_value), 2) AS payment
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY years, months
) AS a
ORDER BY years, months;

# 3) Calculate the year-over-year growth rate of total sales

WITH a AS (
    SELECT YEAR(o.order_purchase_timestamp) AS years,
           ROUND(SUM(p.payment_value), 2) AS payment
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY years
    ORDER BY years
)

SELECT years,
       ROUND(((payment - LAG(payment, 1) OVER (ORDER BY years)) / LAG(payment, 1) OVER (ORDER BY years)) * 100, 2) AS growth_rate
FROM a;

# 4) Calculate the retention rate of customers, defined as the percentage of customers who make another purchase within 6 months of their first purchase

with a as (select customers.customer_id,
min(orders.order_purchase_timestamp) first_order
from customers join orders
on customers.customer_id = orders.customer_id
group by customers.customer_id),

b as (select a.customer_id, count(distinct orders.order_purchase_timestamp) next_order
from a join orders
on orders.customer_id = a.customer_id
and orders.order_purchase_timestamp > first_order
and orders.order_purchase_timestamp < 
date_add(first_order, interval 6 month)
group by a.customer_id) 

select 100 * (count( distinct a.customer_id)/ count(distinct b.customer_id)) 
from a left join b 
on a.customer_id = b.customer_id ;


# 5) Identify the top 3 customers who spent the most money in each year

SELECT years, customer_id, payment, d_rank
FROM (
    SELECT YEAR(o.order_purchase_timestamp) AS years,
           o.customer_id,
           ROUND(SUM(p.payment_value), 2) AS payment,
           DENSE_RANK() OVER (PARTITION BY YEAR(o.order_purchase_timestamp) ORDER BY SUM(p.payment_value) DESC) AS d_rank
    FROM orders o
    JOIN payments p ON p.order_id = o.order_id
    GROUP BY years, o.customer_id
) AS a
WHERE d_rank <= 3;



