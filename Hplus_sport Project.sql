# Hplus sport Project

USE hplussport;

-- View data in Customer table
SELECT * FROM Customer;

-- View data in Product table
SELECT * FROM Product;

-- Insert new grape flavor product into table
INSERT INTO Product (ProductID, 
		ProductCode, 
		ProductName, 
		Size, 
		Variety, 
		Price, 
		Status) 
VALUES ( 17, 
	'MWPRA20',
    'Mineral Water',
    20,
    'Grape',
    '1.79',
    'ACTIVE');
  
-- Sort Orders table
SELECT * 
FROM orders
ORDER BY CreationDate;

-- Find null values in Customer table
SELECT *
FROM customer
WHERE FirstName is null OR LastName is null OR Email is null OR Phone is null OR Address is null;

-- Create new month columns
SELECT *,
		MONTH(CreationDate) as MonthNumber,
		MONTHNAME(CreationDate) as MonthName 
FROM Orders;

-- Insert new customer into Customer table
INSERT INTO customer VALUES(
    1100,
    'Jane',
    'Paterson',
    'jane.paterson@gmail.com',
    '(912)459-2910',
    '4029 Park Street',
    'Kansas City',
    'MO',
    '64161'
  );
  
-- Find how many products sold
SELECT COUNT(DISTINCT ProductID) AS total_unique_product,
	SUM(Quantity) AS total_quantity
FROM orderitem;

-- Find how many products sold only includes ones status as paid.
SELECT COUNT(DISTINCT ProductID) AS total_unique_product,
	SUM(Quantity) AS total_quantity
FROM orderitem
RIGHT JOIN orders USING (OrderID)
WHERE Status = 'paid';

-- Determine which items are discontinued
SELECT *
FROM product
WHERE Status = 'DISCONTINUED';

-- Determine which sales people made no sales
SELECT *
FROM salesperson
WHERE SalespersonID NOT IN (SELECT SalespersonID FROM orders);

-- Find top product size sold
SELECT 
	Size,
	SUM(Quantity) AS total_sale_per_product
FROM orderitem AS oi
LEFT JOIN product AS p ON oi.ProductID = p.ProductID
GROUP BY Size
ORDER BY total_sale_per_product DESC
LIMIT 1;

-- Find top 3 items sold
SELECT oi.ProductID,
	Size,
	SUM(Quantity) AS total_sale_per_product
FROM orderitem AS oi
LEFT JOIN product AS p ON oi.ProductID = p.ProductID
GROUP BY oi.ProductID
ORDER BY total_sale_per_product DESC
LIMIT 3;

-- Find sales by month and year
SELECT SUM(TotalDue) AS total_sale,
	COUNT(OrderID) as TotalOrders,
	MONTH(CreationDate) AS month_sale,
    YEAR(CreationDate) AS year_sales
FROM orders
GROUP BY month_sale, year_sales
ORDER BY year_sales, month_sale;

-- Find average daily sales
SELECT SUM(TotalDue)/COUNT(CreationDate)AS avg_sale_amount
FROM orders;

-- Find average daily product sold
SELECT 
SUM(Quantity) /
COUNT(DISTINCT CreationDate) as AverageDailySales
FROM Orders
LEFT JOIN OrderItem
ON Orders.OrderID = OrderItem.OrderID;

-- Find top customers
SELECT o.CustomerID,
    c.FirstName,
    c.LastName,
    SUM(TotalDue) AS total_amount
FROM orders AS o
JOIN customer AS c
ON o.CustomerID = c.CustomerID
GROUP BY o.CustomerID 
ORDER BY total_amount DESC
LIMIT 1;

-- Find top customers along with order and quanity
SELECT
FirstName,
LastName,
COUNT(DISTINCT o.OrderID) as TotalOrders,
SUM(Quantity) as TotalQuantity,
SUM(DISTINCT TotalDue) as TotalAmount
FROM Orders AS o
LEFT OUTER JOIN OrderItem AS oi
ON o.OrderID = oi.OrderID
LEFT OUTER JOIN Customer AS c
ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID
ORDER BY TotalAmount DESC 
LIMIT 1;

-- Determine customers never made an order
SELECT 
	c.CustomerID,
    c.FirstName,
    c.LastName
FROM Customer AS c
LEFT JOIN Orders AS o
ON o.CustomerID = c.CustomerID
WHERE OrderID IS NULL;

-- Find infrequent customers:who only ordered once
SELECT o.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(OrderID) AS order_count
FROM orders AS o
JOIN customer AS c
ON o.CustomerID = c.CustomerID
GROUP BY o.CustomerID 
HAVING order_count = 1;

-- Determine top customer state
SELECT State,
	COUNT(DISTINCT o.OrderID) as TotalOrders,
	SUM(Quantity) as TotalQuantity,
	SUM(DISTINCT TotalDue) as TotalAmount
FROM Orders AS o
LEFT OUTER JOIN OrderItem AS oi
ON o.OrderID = oi.OrderID
LEFT OUTER JOIN Customer AS c
ON o.CustomerID = c.CustomerID
GROUP BY State
ORDER BY TotalAmount DESC
LIMIT 1;

-- Determine what products sold together
-- STEP 1:
SELECT *
FROM orderitem AS a
INNER JOIN orderitem AS b 
ON a.OrderID = b.OrderID;
-- STEP 2: this result still contains dupliate product ID
SELECT *
FROM orderitem AS a
INNER JOIN orderitem AS b 
ON a.OrderID = b.OrderID
WHERE a.ProductID != b.ProductID;
-- STEP 3:
SELECT a.ProductID AS product1,
	b.ProductID AS product2,
    COUNT(*) as count_purchased
FROM orderitem AS a
INNER JOIN orderitem AS b 
ON a.OrderID = b.OrderID AND a.ProductID < b.ProductID
GROUP BY a.ProductID, b.ProductID
ORDER BY count_purchased DESC;

-- Calculate repeat customer rate: The rate who made more than 1 order
WITH repeat_customer AS (
SELECT CustomerID as repeat_cus
FROM Orders
GROUP BY CustomerID
HAVING COUNT(OrderID)> 1)
SELECT COUNT(DISTINCT repeat_cus)/COUNT(DISTINCT CustomerID)*100 AS repeat_customer_rate
FROM Orders
LEFT JOIN repeat_customer ON repeat_customer.repeat_cus = Orders.CustomerID;

