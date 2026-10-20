-- SELECT * FROM customers;

-- SELECT * FROM products;

-- SELECT * FROM orders;

-- SELECT * FROM order_items;

-- SELECT * FROM payments;

-- SELECT SUM(amount) AS total_revenue FROM payments;

-- SELECT p.product_name,
--        SUM(oi.quantity * p.price) AS revenue
-- FROM order_items oi
-- JOIN products p ON oi.product_id = p.product_id
-- JOIN orders o ON oi.order_id = o.order_id
-- WHERE o.order_status = 'Delivered'
-- GROUP BY p.product_name
-- ORDER BY revenue DESC;

-- USE shubhshop;


-- 1. Which customers have cancelled orders but have also completed delivered orders?

SELECT 
    c.customer_id,
    c.name,
    COUNT(CASE WHEN o.order_status = 'Cancelled' THEN 1 END) AS cancelled_orders,
    COUNT(CASE WHEN o.order_status = 'Delivered' THEN 1 END) AS delivered_orders
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING 
    COUNT(CASE WHEN o.order_status = 'Cancelled' THEN 1 END) > 0
    AND
    COUNT(CASE WHEN o.order_status = 'Delivered' THEN 1 END) > 0;


-- 2. Which products generate high revenue but have low stock?

SELECT 
    p.product_id,
    p.product_name,
    p.stock,
    SUM(oi.quantity * p.price) AS revenue
FROM products p
JOIN order_items oi 
    ON p.product_id = oi.product_id
JOIN orders o 
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name, p.stock
HAVING 
    SUM(oi.quantity * p.price) > 
    (SELECT AVG(product_revenue)
     FROM (
         SELECT SUM(oi2.quantity * p2.price) AS product_revenue
         FROM products p2
         JOIN order_items oi2 
             ON p2.product_id = oi2.product_id
         JOIN orders o2 
             ON oi2.order_id = o2.order_id
         WHERE o2.order_status = 'Delivered'
         GROUP BY p2.product_id
     ) AS revenue_data)
    AND p.stock < 50
ORDER BY revenue DESC;


-- 3. Which products have high stock but very low sales?

SELECT 
    p.product_id,
    p.product_name,
    p.stock,
    COALESCE(SUM(
        CASE 
            WHEN o.order_status = 'Delivered' 
            THEN oi.quantity 
            ELSE 0 
        END
    ), 0) AS units_sold
FROM products p
LEFT JOIN order_items oi 
    ON p.product_id = oi.product_id
LEFT JOIN orders o 
    ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name, p.stock
HAVING p.stock > 100
   AND units_sold <= 2
ORDER BY p.stock DESC;


-- 4. Which cities have many customers but relatively low revenue?

SELECT 
    c.city,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COALESCE(SUM(
        CASE 
            WHEN o.order_status = 'Delivered'
            THEN oi.quantity * p.price
            ELSE 0
        END
    ), 0) AS revenue
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
LEFT JOIN order_items oi 
    ON o.order_id = oi.order_id
LEFT JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY c.city
HAVING total_customers >= 2
   AND revenue < 3000
ORDER BY total_customers DESC, revenue ASC;


-- 5. Which customers contribute more than the average customer spending?

SELECT 
    c.customer_id,
    c.name,
    SUM(oi.quantity * p.price) AS total_spending
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
JOIN order_items oi 
    ON o.order_id = oi.order_id
JOIN products p 
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.name
HAVING total_spending > (
    SELECT AVG(customer_spending)
    FROM (
        SELECT 
            c2.customer_id,
            SUM(oi2.quantity * p2.price) AS customer_spending
        FROM customers c2
        JOIN orders o2 
            ON c2.customer_id = o2.customer_id
        JOIN order_items oi2 
            ON o2.order_id = oi2.order_id
        JOIN products p2 
            ON oi2.product_id = p2.product_id
        WHERE o2.order_status = 'Delivered'
        GROUP BY c2.customer_id
    ) AS customer_data
)
ORDER BY total_spending DESC;


-- 6. Which products generate more revenue from delivered orders than cancelled/pending orders?

SELECT 
    p.product_id,
    p.product_name,

    SUM(
        CASE 
            WHEN o.order_status = 'Delivered'
            THEN oi.quantity * p.price
            ELSE 0
        END
    ) AS delivered_revenue,

    SUM(
        CASE 
            WHEN o.order_status IN ('Cancelled', 'Pending')
            THEN oi.quantity * p.price
            ELSE 0
        END
    ) AS cancelled_pending_revenue

FROM products p
JOIN order_items oi 
    ON p.product_id = oi.product_id
JOIN orders o 
    ON oi.order_id = o.order_id

GROUP BY p.product_id, p.product_name

HAVING delivered_revenue > cancelled_pending_revenue

ORDER BY delivered_revenue DESC;


-- 7. What percentage of total revenue comes from the top 5 products?

SELECT 
    ROUND(
        SUM(revenue) * 100 /
        (SELECT SUM(amount) FROM payments),
        2
    ) AS top_5_product_revenue_percentage
FROM (
    SELECT 
        p.product_id,
        SUM(oi.quantity * p.price) AS revenue
    FROM products p
    JOIN order_items oi 
        ON p.product_id = oi.product_id
    JOIN orders o 
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.product_id
    ORDER BY revenue DESC
    LIMIT 5
) AS top_products;


-- 8. What percentage of total revenue comes from the top 5 customers?

SELECT 
    ROUND(
        SUM(total_spending) * 100 /
        (SELECT SUM(amount) FROM payments),
        2
    ) AS top_5_customer_revenue_percentage
FROM (
    SELECT 
        c.customer_id,
        SUM(oi.quantity * p.price) AS total_spending
    FROM customers c
    JOIN orders o 
        ON c.customer_id = o.customer_id
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    JOIN products p 
        ON oi.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id
    ORDER BY total_spending DESC
    LIMIT 5
) AS top_customers;


-- 9. Which product category has the highest average revenue per order?

SELECT 
    p.category,
    ROUND(
        SUM(oi.quantity * p.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_revenue_per_order
FROM products p
JOIN order_items oi 
    ON p.product_id = oi.product_id
JOIN orders o 
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY average_revenue_per_order DESC
LIMIT 1;


-- 10. Which customers have never completed a delivered order?

SELECT 
    c.customer_id,
    c.name,
    c.city
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
    AND o.order_status = 'Delivered'
WHERE o.order_id IS NULL
ORDER BY c.customer_id;