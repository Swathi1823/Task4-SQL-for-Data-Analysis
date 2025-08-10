	-- ecommerce_sample.sql
-- Simple e-commerce schema (MySQL-compatible). 
-- To load into MySQL: mysql -u root -p < ecommerce_sample.sql
-- Notes: For PostgreSQL, change AUTO_INCREMENT to SERIAL or IDENTITY. For SQLite, use INTEGER PRIMARY KEY AUTOINCREMENT.

DROP DATABASE IF EXISTS ecommerce_sample;
CREATE DATABASE ecommerce_sample;
USE ecommerce_sample;

-- Customers
CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(20),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Categories
CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL
);

-- Products
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  category_id INT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  stock INT NOT NULL DEFAULT 0,
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Orders
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(30) DEFAULT 'pending',
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order items (order_details)
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Addresses
CREATE TABLE addresses (
  address_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  address_line VARCHAR(255),
  city VARCHAR(80),
  state VARCHAR(80),
  country VARCHAR(80),
  postal_code VARCHAR(20),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Payments
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  method VARCHAR(50),
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Sample data (small set so you can run queries immediately)
INSERT INTO customers (full_name, email, phone) VALUES
('Asha Kumar', 'asha.kumar@example.com', '+91-9876543210'),
('Ravi Sharma', 'ravi.sharma@example.com', '+91-9123456780'),
('Maya Patel', 'maya.patel@example.com', '+91-9988776655'),
('John Doe', 'john.doe@example.com', '+1-555-0100');

INSERT INTO categories (name) VALUES
('Coffee'), ('Tea'), ('Accessories'), ('Snacks');

INSERT INTO products (name, category_id, price, stock) VALUES
('Espresso Roast', 1, 9.99, 120),
('Colombian Medium Roast', 1, 12.50, 80),
('Masala Chai', 2, 6.00, 200),
('Ceramic Mug 350ml', 3, 7.25, 150),
('Biscotti Pack', 4, 4.50, 300),
('French Press 1L', 3, 24.99, 40);

-- Orders
INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2025-07-15 10:05:00', 'delivered'),
(2, '2025-07-16 13:20:00', 'delivered'),
(1, '2025-07-20 09:45:00', 'pending'),
(3, '2025-07-21 18:30:00', 'delivered'),
(4, '2025-07-22 20:00:00', 'shipped');

-- Order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 2, 2, 12.50),
(1, 4, 1, 7.25),
(2, 1, 1, 9.99),
(3, 5, 5, 4.50),
(4, 3, 3, 6.00),
(5, 6, 1, 24.99),
(2, 5, 2, 4.50);

-- Payments
INSERT INTO payments (order_id, amount, payment_date, method) VALUES
(1, 32.25, '2025-07-15 10:06:00', 'card'),
(2, 18.99, '2025-07-16 13:21:00', 'card'),
(4, 18.00, '2025-07-21 18:31:00', 'upi'),
(5, 24.99, '2025-07-22 20:05:00', 'card');

-- Indexes to help typical queries
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Helpful view: monthly sales (MySQL/MariaDB)
DROP VIEW IF EXISTS monthly_sales;
CREATE VIEW monthly_sales AS
SELECT
  DATE_FORMAT(o.order_date, '%Y-%m') AS `year_month`,
  SUM(oi.quantity * oi.unit_price) AS total_sales,
  COUNT(DISTINCT o.order_id) AS orders_count
FROM orders o
JOIN order_items oi 
  ON o.order_id = oi.order_id
GROUP BY `year_month`;

SELECT c.customer_id, c.full_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Quick sample query (you can copy into your client)
-- SELECT c.full_name, o.order_id, o.order_date, SUM(oi.quantity * oi.unit_price) AS order_total
-- FROM customers c
-- JOIN orders o ON c.customer_id = o.customer_id
-- JOIN order_items oi ON o.order_id = oi.order_id
-- GROUP BY o.order_id
-- ORDER BY order_total DESC;
-- Find total sales by country, sorted from highest to lowest

