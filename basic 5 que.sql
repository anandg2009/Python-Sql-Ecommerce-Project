

-- 1) List all unique cities where customers are located

select distinct	customer_city from customers;

-- 2) Count the number of orders placed in 2017.

select count(order_id) as no_of_orders
from orders
where year(order_purchase_timestamp)=2017;


--  3) Find the total sales per category
SELECT products.product_category,round(sum(price),2) as total_sales
FROM order_items
JOIN products ON order_items.product_id = products.product_id
group by products.product_category;

 -- 4) Calculate the percentage of orders that were paid in installments
 
 SELECT SUM(CASE WHEN payment_installments >= 1 THEN 1 ELSE 0 END) / COUNT(*) * 100 as installment_percentage
FROM payments;

-- 5)Count the number of customers from each state. 

select count(customer_state) as no_of_state, customer_state
from customers
group by customer_state;