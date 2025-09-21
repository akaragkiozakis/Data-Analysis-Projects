-- Displaying product sales per year and quarter with growth trends
WITH sales_per_quarter AS (
    SELECT p.ProductID, p.Name AS Product_Name, COUNT(s.SalesOrderID) AS Orders, 
           DATEPART(QUARTER, h.OrderDate) AS Sales_Quarter, 
           DATEPART(YEAR,h.OrderDate) AS Sales_Year
    FROM Sales.SalesOrderDetail s
    JOIN Production.Product p
        ON p.ProductID = s.ProductID
    JOIN Sales.SalesOrderHeader h
        ON h.SalesOrderID = s.SalesOrderID
    GROUP BY p.ProductID, p.Name, DATEPART(QUARTER, h.OrderDate), DATEPART(YEAR,h.OrderDate)
), 
ranked_sales AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY ProductID ORDER BY Sales_Year, Sales_Quarter) AS Quarter_Rank,
           LAG(Orders) OVER(PARTITION BY ProductID ORDER BY Sales_Year, Sales_Quarter) AS Prev_Orders
    FROM sales_per_quarter
),
sales_trends AS (
    SELECT *,
           CASE 
               WHEN Prev_Orders IS NULL THEN NULL
               WHEN Orders > Prev_Orders THEN 1
               ELSE 0
           END AS IsIncrease
    FROM ranked_sales
)
SELECT ProductID, Product_Name, Sales_Year, Sales_Quarter, Orders, Prev_Orders, IsIncrease
FROM sales_trends
ORDER BY ProductID, Sales_Year, Sales_Quarter;



-- Displaying top 5 products based on profit
SELECT TOP 5 p.ProductID, p.Name,
       ROUND(SUM((o.UnitPrice - p.StandardCost) * o.OrderQty),2) AS Profit,
       SUM(o.OrderQty) AS Total_Orders
FROM Production.Product p
JOIN Sales.SalesOrderDetail o
    ON o.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY Profit DESC;


-- Displaying orders and whether they were on time or delayed
SELECT d.PurchaseOrderID, h.ShipDate, d.DueDate,
       CASE
           WHEN h.ShipDate > d.DueDate THEN 'Delayed'
           ELSE 'On Time'
       END AS Order_Info
FROM Purchasing.PurchaseOrderDetail d
JOIN Purchasing.PurchaseOrderHeader h
    ON d.PurchaseOrderID = h.PurchaseOrderID;
