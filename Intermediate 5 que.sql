# 1) Calculate the number of orders per month in 2018

SELECT MONTHNAME(order_purchase_timestamp) AS monthname, 
       COUNT(order_id) AS order_count
FROM orders 
WHERE YEAR(order_purchase_timestamp) = 2018
GROUP BY MONTHNAME(order_purchase_timestamp);

# 2) Find the average number of products per order, grouped by customer city

WITH count_per_order AS (
    SELECT o.customer_id, COUNT(oi.order_id) AS order_count
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT c.customer_city, ROUND(AVG(cp.order_count), 2) AS average_orders
FROM customers c
JOIN count_per_order cp ON c.customer_id = cp.customer_id
GROUP BY c.customer_city
ORDER BY average_orders DESC;

# 3) Calculate the percentage of total revenue contributed by each product category.

SELECT UPPER(products.product_category) AS category,
       ROUND((SUM(payments.payment_value) / (SELECT SUM(payment_value) FROM payments)) * 100, 2) AS sales_percentage
FROM products
JOIN order_items ON products.product_id = order_items.product_id
JOIN payments ON payments.order_id = order_items.order_id
GROUP BY category
ORDER BY sales_percentage DESC;

# 4) Identify the correlation between product price and the number of times a product has been purchased.

SELECT products.product_category,
       COUNT(order_items.product_id) AS product_count,
       ROUND(AVG(order_items.price), 2) AS average_price
FROM products
JOIN order_items ON products.product_id = order_items.product_id
GROUP BY products.product_category;

# 5) Calculate the total revenue generated by each seller, and rank them by revenue.

SELECT *,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS rn
FROM (
    SELECT order_items.seller_id, 
           SUM(payments.payment_value) AS revenue
    FROM order_items
    JOIN payments ON order_items.order_id = payments.order_id
    GROUP BY order_items.seller_id
) AS a;


