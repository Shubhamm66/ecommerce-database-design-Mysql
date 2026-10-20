
# E-commerce Database Design & Analytics | MySQL

## Project Overview

This capstone project focuses on designing a relational database for an e-commerce store and using SQL to analyze customer behavior, product revenue, inventory levels and order performance.

The project contains five related tables, sample data and 10 business analysis queries written in MySQL.

## Project Objectives

- Design a relational database for an e-commerce store.
- Define primary keys and foreign key relationships.
- Populate the database with sample customer, product, order and payment data.
- Analyze revenue, inventory, customer spending and order status.
- Answer business questions using SQL queries.

## Tools & Technologies

- MySQL
- SQL
- MySQL Workbench (if used)

## Database Schema

Database name: `shubhshop`

The database consists of five tables:

| Table | Description |
|---|---|
| `customers` | Customer information, email, city, and signup date |
| `products` | Product name, category, price and stock |
| `orders` | Customer orders, order date and order status |
| `order_items` | Products and quantities included in orders |
| `payments` | Payment method, amount and payment date |

### Table Relationships

- `orders.customer_id` → `customers.customer_id`
- `order_items.order_id` → `orders.order_id`
- `order_items.product_id` → `products.product_id`
- `payments.order_id` → `orders.order_id`

Primary keys uniquely identify records, while foreign keys establish relationships between the tables.

## Project Files

1. `ecommerce_database_design.sql`
   - Creates the database and five tables.
2. `ecommerce_populates_table.sql`
   - Inserts sample data into the tables.
3. `ecommerce_Business_insights.sql`
   - Contains 10 SQL queries for business analysis.


## SQL Concepts Used

- Database and table creation
- Primary keys and foreign keys
- INSERT statements
- INNER JOIN and LEFT JOIN
- GROUP BY and HAVING
- Aggregate functions: SUM(), COUNT(), AVG()
- Conditional aggregation using CASE
- COALESCE() for handling missing values
- Subqueries and derived tables
- ORDER BY and LIMIT
- ROUND() for percentage calculations

## How to Run the Project

1. Install MySQL and open MySQL Workbench or another MySQL client.
2. Execute `ecommerce_database_design.sql`.
3. Execute `ecommerce_populates_table.sql`.
4. Execute `ecommerce_Business_insights.sql`.
5. Review the results returned by the analysis queries.

**Important:** Execute the scripts in the order listed above. The sample data and analysis queries depend on the database and tables being created first.

## Key Learning Outcomes

- Understanding relational database design and table relationships.
- Writing SQL queries across multiple related tables.
- Using aggregate functions to analyze revenue and spending.
- Applying subqueries and conditional logic to business questions.
- Analyzing product inventory, order statuses and customer behavior.

## Conclusion

This project demonstrates practical SQL skills through database design, sample data management, and business-oriented analysis. It provides experience in translating e-commerce business questions into SQL queries.

## Author

**Shubham Modokar**

Aspiring Data Analyst

Skills: SQL | MySQL | Python | Excel | Power BI
