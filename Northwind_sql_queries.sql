-- Query 1: List all customers
SELECT * FROM Customers;
GO

-- Query 2: Find all orders made by a specific customer (e.g., 'ALFKI')
SELECT * FROM Orders WHERE CustomerID = 'ALFKI';
GO

-- Query 3: List all products that are out of stock
SELECT ProductName FROM Products WHERE UnitsInStock = 0;
GO

-- Query 4: Count the number of products in each category
SELECT CategoryID, COUNT(ProductID) AS NumberOfProducts
FROM Products
GROUP BY CategoryID;
GO

-- Query 5: List all employees, showing their last name and the city they live in
SELECT LastName, City FROM Employees;
GO

-- Query 6: List all customers and the total number of orders they have made
SELECT Customers.CustomerID, Customers.CompanyName, COUNT(Orders.OrderID) AS NumberOfOrders
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY Customers.CustomerID, Customers.CompanyName;
GO

-- Query 7: Find details of all orders placed in a certain year (e.g., 1997)
SELECT * FROM Orders
WHERE YEAR(OrderDate) = 1997;
GO

-- Query 8: List products along with the supplier name and category name
SELECT Products.ProductName, Suppliers.CompanyName AS SupplierName, Categories.CategoryName
FROM Products
JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID
JOIN Categories ON Products.CategoryID = Categories.CategoryID;
GO

-- Query 9: List employees and their supervisors (note that some employees may not have supervisors)
SELECT e.LastName AS EmployeeLastName, m.LastName AS ManagerLastName
FROM Employees e
LEFT JOIN Employees m ON e.ReportsTo = m.EmployeeID;
GO

-- Query 10: Find customers who have never placed an order
SELECT Customers.CustomerID, Customers.CompanyName
FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.OrderID IS NULL;
GO

-- Query 11: Find the total order amount for each customer, including shipping
SELECT Customers.CustomerID, Customers.CompanyName, SUM(OrderDetails.UnitPrice * OrderDetails.Quantity) + SUM(Orders.Freight) AS TotalOrderAmount
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
GROUP BY Customers.CustomerID, Customers.CompanyName;
GO

-- Query 12: List products that have been ordered more than a certain number of times (e.g., 20 times)
SELECT Products.ProductName, COUNT(OrderDetails.ProductID) AS TimesOrdered
FROM Products
JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID
GROUP BY Products.ProductName
HAVING COUNT(OrderDetails.ProductID) > 20;
GO

-- Query 13: List customers along with their most frequently ordered product
SELECT Customers.CustomerID, Customers.CompanyName, Products.ProductName, MAX(ProductCount) AS MaxProductCount
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
JOIN (SELECT OrderID, ProductID, COUNT(*) AS ProductCount
      FROM OrderDetails
      GROUP BY OrderID, ProductID) AS OrderCounts ON Orders.OrderID = OrderCounts.OrderID
JOIN Products ON OrderCounts.ProductID = Products.ProductID
GROUP BY Customers.CustomerID, Customers.CompanyName, Products.ProductName
ORDER BY Customers.CustomerID, MaxProductCount DESC;
GO

-- Query 14: Find the month in each year with the highest total orders placed
SELECT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, COUNT(OrderID) AS TotalOrders
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY YEAR(OrderDate), COUNT(OrderID) DESC;
GO

-- Query 15: For each product, find the order that purchased the most of that product (including the quantity and order details)
SELECT Products.ProductName, OrderDetails.OrderID, MAX(OrderDetails.Quantity) AS MaxQuantity
FROM Products
JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID
GROUP BY Products.ProductName, OrderDetails.OrderID
ORDER BY Products.ProductName, MaxQuantity DESC;
GO

-- Query 16: Calculate running totals of order amounts for each customer
WITH OrderAmounts AS (
    SELECT 
        Orders.CustomerID, 
        Orders.OrderID, 
        SUM(OrderDetails.UnitPrice * OrderDetails.Quantity) OVER (PARTITION BY Orders.CustomerID ORDER BY Orders.OrderID) AS RunningTotal
    FROM Orders
    JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
)
SELECT * FROM OrderAmounts;
GO

-- Query 17: Rank customers based on total order amounts and return top 10
;WITH RankedCustomers AS (
    SELECT 
        CustomerID, 
        SUM(UnitPrice * Quantity) AS TotalOrderAmount,
        RANK() OVER (ORDER BY SUM(UnitPrice * Quantity) DESC) AS Rank
    FROM Orders
    JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
    GROUP BY CustomerID
)
SELECT TOP 10 * FROM RankedCustomers
WHERE Rank <= 10;
GO

-- Query 18: Find products that have never been ordered in any order
SELECT 
    Products.ProductName
FROM Products
LEFT JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID
WHERE OrderDetails.ProductID IS NULL;
GO

-- Query 19: Calculate the monthly growth rate in sales
WITH MonthlySales AS (
    SELECT 
        YEAR(OrderDate) AS Year, 
        MONTH(OrderDate) AS Month, 
        SUM(UnitPrice * Quantity) AS TotalSales
    FROM Orders
    JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
SalesGrowth AS (
    SELECT *,
           LAG(TotalSales, 1, 0) OVER (ORDER BY Year, Month) AS PrevMonthSales,
           (TotalSales - LAG(TotalSales, 1, TotalSales) OVER (ORDER BY Year, Month)) / NULLIF(LAG(TotalSales, 1, 0) OVER (ORDER BY Year, Month), 0) * 100.0 AS GrowthPercentage
    FROM MonthlySales
)
SELECT Year, Month, GrowthPercentage
FROM SalesGrowth
WHERE GrowthPercentage IS NOT NULL;
GO

