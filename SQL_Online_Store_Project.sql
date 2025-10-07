-- إنشاء قاعدة البيانات
CREATE DATABASE online_store;
GO

USE online_store;
GO

-- جدول العملاء
CREATE TABLE customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(100),
    city NVARCHAR(50),
    country NVARCHAR(50),
    email NVARCHAR(100)
);
GO

-- جدول المنتجات
CREATE TABLE products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_name NVARCHAR(100),
    category NVARCHAR(50),
    price DECIMAL(10,2),
    stock INT
);
GO

-- جدول الطلبات
CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

-- إدخال بيانات العملاء
INSERT INTO customers (full_name, city, country, email) VALUES
(N'Ahmed Ali', N'Cairo', N'Egypt', N'ahmed.ali@email.com'),
(N'Sara Hassan', N'Alexandria', N'Egypt', N'sara.hassan@email.com'),
(N'Omar Khaled', N'Casablanca', N'Morocco', N'omar.khaled@email.com'),
(N'Layla Said', N'Tunis', N'Tunisia', N'layla.said@email.com'),
(N'Hassan Noor', N'Algiers', N'Algeria', N'hassan.noor@email.com');
GO

-- إدخال بيانات المنتجات
INSERT INTO products (product_name, category, price, stock) VALUES
(N'Laptop HP', N'Electronics', 15000, 20),
(N'iPhone 14', N'Mobiles', 35000, 15),
(N'Headphones Sony', N'Accessories', 2500, 50),
(N'Smart Watch Samsung', N'Electronics', 7000, 25),
(N'Camera Canon', N'Photography', 22000, 10);
GO

-- إدخال بيانات الطلبات
INSERT INTO orders (customer_id, product_id, quantity, order_date) VALUES
(1, 1, 1, '2025-01-10'),
(2, 2, 2, '2025-02-14'),
(3, 3, 3, '2025-03-22'),
(4, 4, 1, '2025-04-11'),
(5, 5, 1, '2025-05-30'),
(1, 2, 1, '2025-06-05'),
(2, 1, 2, '2025-07-08'),
(3, 4, 2, '2025-08-12'),
(4, 3, 4, '2025-09-01'),
(5, 2, 1, '2025-10-03');
GO
SELECT name FROM sys.databases WHERE name = 'online_store';
SELECT name 
FROM sys.tables;

SELECT * FROM customers;

SELECT * FROM products;

SELECT * FROM orders;

EXEC sp_fkeys 'orders';


SELECT full_name, city, email
FROM customers
WHERE country = 'Egypt' AND city LIKE 'C%';


SELECT c.full_name, p.product_name, o.quantity, o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;

SELECT p.product_name AS Product, SUM(o.quantity) AS Total_Sold
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name;

UPDATE products
SET stock = stock - 1
WHERE product_id = 2;

DELETE FROM orders
WHERE order_id = 10;

DELETE FROM orders
WHERE order_id = 10;


SELECT p.category, COUNT(o.order_id) AS Total_Orders, SUM(o.quantity) AS Total_Quantity
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
HAVING SUM(o.quantity) > 2
ORDER BY Total_Orders DESC;


SELECT 
    COUNT(*) AS Total_Orders,
    SUM(quantity) AS Total_Quantity,
    AVG(quantity) AS Avg_Quantity,
    MIN(quantity) AS Min_Quantity,
    MAX(quantity) AS Max_Quantity
FROM orders;
