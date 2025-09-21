-- Displaying monthly and yearly total amounts
SELECT ROUND(SUM(TotalDue),2) AS Total_Amount,
       MONTH(OrderDate) AS Month,
       YEAR(OrderDate) AS Year
FROM Sales.SalesOrderHeader
GROUP BY MONTH(OrderDate), YEAR(OrderDate)
ORDER BY Total_Amount DESC;


-- Displaying the 3 most profitable territories
SELECT TOP 3 ROUND(SUM(soh.TotalDue),2) AS Total_Amount,
       t.Name,
       t.TerritoryID
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory t
    ON t.TerritoryID = soh.TerritoryID
GROUP BY t.Name, t.TerritoryID
ORDER BY Total_Amount DESC;
