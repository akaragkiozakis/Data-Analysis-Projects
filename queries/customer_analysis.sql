-- Finding out the number of customers
SELECT COUNT(DISTINCT CustomerID)
FROM Sales.Customer;


-- Displaying top 10 customers who have paid the most money
SELECT TOP 10 
    soh.CustomerID,
    CONCAT(pp.FirstName, ' ', pp.LastName) AS FullName,
    SUM(soh.TotalDue) AS Total_Amount_Paid
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c
    ON c.CustomerID = soh.CustomerID
JOIN Person.Person pp
    ON pp.BusinessEntityID = c.CustomerID
GROUP BY soh.CustomerID, CONCAT(pp.FirstName, ' ', pp.LastName)
ORDER BY Total_Amount_Paid DESC;


-- Displaying average amount each customer paid
SELECT soh.CustomerID,
       CONCAT(pp.FirstName, ' ', pp.LastName) AS FullName,
       SUM(soh.TotalDue) AS Total_Amount_Paid,
       ROUND(AVG(soh.TotalDue), 2) AS Avg_Amount
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c
    ON c.CustomerID = soh.CustomerID
JOIN Person.Person pp
    ON pp.BusinessEntityID = c.CustomerID
GROUP BY soh.CustomerID, CONCAT(pp.FirstName, ' ', pp.LastName)
ORDER BY Total_Amount_Paid DESC;


-- Displaying total orders per customer and how many months they are active, plus orders per month
SELECT soh.CustomerID,
       CONCAT(pp.FirstName, ' ', pp.LastName) AS FullName,
       COUNT(soh.SalesOrderID) AS Orders, 
       MIN(soh.OrderDate) AS Min, 
       MAX(soh.OrderDate) AS Max, 
       DATEDIFF(MONTH, MIN(soh.OrderDate), MAX(soh.OrderDate)) AS Active_Months,
       ROUND(CAST(COUNT(soh.SalesOrderID) AS FLOAT) /
             NULLIF(DATEDIFF(MONTH, MIN(soh.OrderDate), MAX(soh.OrderDate)), 0), 2) AS Orders_per_Month
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c
    ON c.CustomerID = soh.CustomerID
JOIN Person.Person pp
    ON pp.BusinessEntityID = c.CustomerID
GROUP BY soh.CustomerID, CONCAT(pp.FirstName, ' ', pp.LastName)
HAVING DATEDIFF(MONTH, MIN(soh.OrderDate), MAX(soh.OrderDate)) >= 5
   AND COUNT(soh.SalesOrderID) >= 5;



-- Displaying customers' last order, recency, total orders, and total amount
SELECT CustomerID,
       MAX(OrderDate) AS Last_Order, 
       COUNT(SalesOrderID) AS Total_Orders,
       DATEDIFF(DAY, MAX(OrderDate), GETDATE()) AS Recency,
       SUM(TotalDue) AS Total_Amount
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY CustomerID ASC;


-- Displaying customer lifetime value and classification
WITH Activity AS (
    SELECT CustomerID,
           MIN(OrderDate) AS First_Order,
           MAX(OrderDate) AS LastOrder, 
           DATEDIFF(MONTH, MIN(OrderDate), MAX(OrderDate)) AS Active_Months
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT a.CustomerID,
       a.Active_Months,
       ROUND(SUM(s.TotalDue) / NULLIF(a.Active_Months,0), 2) AS CLV,
       CASE 
           WHEN ROUND(SUM(s.TotalDue) / NULLIF(a.Active_Months,0), 2) IS NULL THEN NULL
           WHEN ROUND(SUM(s.TotalDue) / NULLIF(a.Active_Months,0), 2) BETWEEN 1.40 AND 15000.00 THEN 'Low CLV'
           WHEN ROUND(SUM(s.TotalDue) / NULLIF(a.Active_Months,0), 2) BETWEEN 15000.00 AND 35000.00 THEN 'Medium CLV'
           ELSE 'High CLV'
       END AS Rate
FROM Activity a
JOIN Sales.SalesOrderHeader s
    ON a.CustomerID = s.CustomerID
GROUP BY a.CustomerID, a.Active_Months
ORDER BY a.CustomerID ASC;
