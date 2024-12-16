USE RetailSales;

SELECT *
FROM Categories

SELECT *
FROM Employees

SELECT *
FROM Orders

SELECT * 
FROM Products

SELECT *
FROM Suppliers


-- YEAR
------------------------------------------------------------------------------------------------------------------------------
WITH Timecte AS

(SELECT *, DATEPART(YEAR, OrderDate) AS Year
FROM Orders)
SELECT Year,
       FORMAT(ROUND(SUM(Sales),0),'N0') AS Total_sales,
	   ROUND(SUM(Sales)*100/(LAG(SUM(Sales),1) OVER(ORDER BY Year)),2) AS Sales_YoY,
	   SUM(Quantity) AS Total_Quantities,
	   ROUND(SUM(Quantity)*100/(LAG(SUM(Quantity),1) OVER(ORDER BY Year)),2) AS Quantities_YoY,
	   COUNT(DISTINCT OrderID) AS No_of_Order,
	   ROUND(COUNT(DISTINCT OrderID)*100/(LAG(COUNT(DISTINCT OrderID),1) OVER(ORDER BY Year)),2) AS NoOrders_YoY
FROM Timecte
GROUP BY Year
ORDER BY Year

--MONTH
WITH Timecte AS
(SELECT *,
      DATEPART(MONTH, OrderDate) AS Month,
	  DATEPART(YEAR, OrderDate) AS Year
FROM Orders)

SELECT Month,
       FORMAT(ROUND(SUM(CASE WHEN Timecte.Year = '2015' THEN Sales END),0),'N0') AS TS_2015,
	   FORMAT(ROUND(SUM(CASE WHEN Timecte.Year = '2018' THEN Sales END),0),'N0') AS TS_2018,
	   FORMAT(ROUND(SUM(CASE WHEN Timecte.Year = '2019' THEN Sales END),0),'N0') AS TS_2019,
	   FORMAT(ROUND(SUM(CASE WHEN Timecte.Year = '2020' THEN Sales END),0),'N0') AS TS_2020,
	   FORMAT(ROUND(SUM(CASE WHEN Timecte.Year = '2021' THEN Sales END),0),'N0') AS TS_2021
FROM Timecte
GROUP BY Month
ORDER BY Month

--2,Overall trending by category
-- By year
WITH Timecte AS
(SELECT *, DATEPART(YEAR,OrderDate) AS Year
FROM Orders)

SELECT c.Category, t.Year,
       FORMAT(ROUND(SUM(t.Sales),0),'N0') AS Total_sales,
	   FORMAT(ROUND(SUM(t.Quantity),0),'N0') AS Total_sales,
	  COUNT(DISTINCT t.OrderID) AS Total_sales

FROM Products p
JOIN Timecte t 
ON p.ProductID = t.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
WHERE Year IN (2018,2019,2021)
GROUP BY c.Category, t.Year
ORDER BY c.Category, t.Year

-- By Month

WITH Timecte AS
(SELECT *,
      DATEPART(MONTH, OrderDate) AS Month,
	  DATEPART(YEAR, OrderDate) AS Year
FROM Orders)
SELECT c.Category, t.Month,
       FORMAT(ROUND(SUM(t.Sales),0),'N0') AS Total_sales,
	   FORMAT(ROUND(SUM(t.Quantity),0),'N0') AS Total_sales,
	  COUNT(DISTINCT t.OrderID) AS Total_sales

FROM Products p
JOIN Timecte t 
ON p.ProductID = t.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
WHERE Year IN (2018,2019,2021)
GROUP BY c.Category, t.Month
ORDER BY c.Category, t.Month

WITH Timecte AS
(SELECT *,FORMAT(OrderDate,'yyyy-MM') AS Month
FROM Orders)
SELECT c.Category,Month,
       FORMAT(ROUND(SUM(t.Sales),0),'N0') AS Total_sales,
	   FORMAT(ROUND(SUM(t.Quantity),0),'N0') AS Total_sales,
	  COUNT(DISTINCT t.OrderID) AS Total_sales

FROM Products p
JOIN Timecte t 
ON p.ProductID = t.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
WHERE LEFT(Month,4) IN (2018,2019,2021)
GROUP BY c.Category, t.Month
ORDER BY c.Category, t.Month

--Distribution of sales across product categories

------------------------------------------------------------------------
WITH cte AS
(SELECT c.Category, 
      DATEPART(YEAR,o.OrderDate) AS Year,
	  o.Sales
FROM Products p 
JOIN Orders o
ON p.ProductID = o.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID),
sumcte AS
(SELECT cte.Category, 
        SUM(CASE WHEN cte.Year = 2018 THEN cte.Sales END) AS Total_Sales_2018,
        SUM(CASE WHEN cte.Year = 2019 THEN cte.Sales END) AS Total_Sales_2019,
        SUM(CASE WHEN cte.Year = 2021 THEN cte.Sales END) AS Total_Sales_2021
 FROM cte 
 GROUP BY cte.Category)
 
SELECT Category,
       FORMAT(Total_Sales_2018, 'N0') AS Total_Sales_2018,
       FORMAT(Total_Sales_2019, 'N0') AS Total_Sales_2019,
       FORMAT(Total_Sales_2021, 'N0') AS Total_Sales_2021,
       ROUND((Total_Sales_2018 * 100) / (SUM(Total_Sales_2018) OVER ()), 1) AS Propotion_2018,
       ROUND((Total_Sales_2019 * 100) / (SUM(Total_Sales_2019) OVER ()), 1) AS Propotion_2019,
       ROUND((Total_Sales_2021 * 100) / (SUM(Total_Sales_2021) OVER ()), 1) AS Propotion_2021
FROM sumcte
ORDER BY ROUND((Total_Sales_2021 * 100) / (SUM(Total_Sales_2021) OVER ()), 1) DESC
-------------------------------------------------------------------------------------------------------
-- 4 Distribution of sales across customer segment
-------------------------------------------------------------------------------------------------------
WITH classify AS 
(SELECT CategoryID, Category,
	   (CASE WHEN Category LIKE '%Women%' OR Category LIKE '%Ladies%' THEN 'Woman'
		  WHEN Category LIKE '%Men%' THEN 'Men'
		  WHEN Category LIKE '%Baby%' OR Category LIKE '%Children%' THEN 'Children'
		  ELSE 'General'
	   END) AS Targer_Customer FROM Categories),
timecte AS
  (SELECT c.Targer_Customer,
       DATEPART(YEAR, o.OrderDate) AS Year, o.Sales AS Sales
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
JOIN classify c ON p.CategoryID = c.CategoryID),
sumcte AS
(SELECT t.Targer_Customer, 
      SUM(CASE WHEN Year = 2018 THEN Sales END) AS Total_Sales_2018,
	  SUM(CASE WHEN Year = 2019 THEN Sales END) AS Total_Sales_2019,
	  SUM(CASE WHEN Year = 2021 THEN Sales END) AS Total_Sales_2021
FROM timecte t GROUP BY t.Targer_Customer)

SELECT Targer_Customer,
       FORMAT(Total_Sales_2018,'N0') AS Total_Sales_2018,
	   FORMAT(Total_Sales_2019,'N0') AS Total_Sales_2019,
	   FORMAT(Total_Sales_2021,'N0') AS Total_Sales_2021,
	   ROUND(Total_Sales_2018*100/(SUM(Total_Sales_2018) OVER()),1) AS Propotion_2018,
	   ROUND(Total_Sales_2019*100/(SUM(Total_Sales_2019) OVER()),1) AS Propotion_2019,
	   ROUND(Total_Sales_2021*100/(SUM(Total_Sales_2021) OVER()),1) AS Propotion_2021
FROM sumcte ORDER BY ROUND(Total_Sales_2021*100/(SUM(Total_Sales_2021) OVER()),1) DESC

---------------------------------------------------------------------------------------------------------------------
--5 Sales by Suppliers
---------------------------------------------------------------------------------------------------------------------
WITH timecte AS
(SELECT *, DATEPART(YEAR, OrderDate) AS Year
FROM Orders)

SELECT s.Supplier,
       FORMAT(SUM(t.Sales), 'N0') AS Total_Sales,
	   COUNT(DISTINCT t.OrderID) AS No_of_orders,
	   (2021-MIN(t.Year)+1) AS Seniority,
	   COUNT(DISTINCT p.CategoryID) AS Diversity_of_Cate,
	   COUNT(DISTINCT P.ProductID) AS Diversity_of_Product
FROM timecte t
JOIN Products p
ON t.ProductID = p.ProductID
JOIN Suppliers s
ON s.SupplierID = p.SupplierID
GROUP BY s.Supplier
ORDER BY COUNT(DISTINCT t.OrderID) DESC

-----------------------------------------------------------------------------------------------------------------
-- by customer
--------------------------------------------------------------------------------------------------------------
 WITH timecte AS
(SELECT *, DATEPART(WEEKDAY,OrderDate) AS Day_of_week, 
         (CASE WHEN DATEPART(WEEKDAY,OrderDate) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END) Type_of_day
FROM Orders)
SELECT Type_of_day, 
       COUNT(DISTINCT OrderID)/COUNT(DISTINCT Day_of_week) AS avg_no_of_order,
	   ROUND(AVG(Sales),2) AS avg_sale_value
FROM timecte 
GROUP BY Type_of_day

-----------------------------------------------------------------------------------------------------
-- TOP 10 customer by sales
-----------------------------------------------------------------------------------------------------
SELECT TOP 10 CustomerID,
       FORMAT(SUM(Sales),'N0') AS Total_Sales,
	   SUM(Quantity) AS Total_quantities,
	   COUNT(DISTINCT OrderID) AS No_of_orders,
	   ROUND(SUM(Sales)/COUNT(DISTINCT OrderID),2) AS avg_value
FROM Orders
GROUP BY CustomerID
ORDER BY SUM(Sales) DESC
-------------------------------------------------------------------------------------------------------------
--customer with total sale >$30,000
------------------------------------------------------------------------------------------------------------
SELECT CustomerID,
       FORMAT(SUM(Sales),'N0') AS Total_Sales,
	   SUM(Quantity) AS Total_quantities,
	   COUNT(DISTINCT OrderID) AS No_of_orders,
	   ROUND(SUM(Sales)/COUNT(DISTINCT OrderID),2) AS avg_value
FROM Orders
GROUP BY CustomerID
HAVING SUM(Sales) > 30000
ORDER BY SUM(Sales) DESC

-------------------------------------------------------------------------------------------------------
-- total loyal customers
----------------------------------------------------------------------------------------------------------
WITH timecte AS
(SELECT *, DATEPART(YEAR, OrderDate) AS Year
FROM Orders)

SELECT CustomerID,
       (2021-MIN(t.Year)+1) AS Seniority
FROM timecte t
GROUP BY CustomerID
HAVING MAX(t.Year) = 2021
ORDER BY (2021-MIN(t.Year)+1) DESC

--------------------------------------------------------------------------------------------------------
----top 3 customer each country
------------------------------------------------------------------------------------------------------
WITH cte AS
(SELECT s.SupplierCountry,
       o.CustomerID,
	   FORMAT(SUM(o.Sales), 'N0') AS Total_Sales,
	   SUM(o.Quantity) AS No_of_orders,
	   DENSE_RANK() OVER(PARTITION BY s.SupplierCountry ORDER BY  SUM(o.Sales) DESC) AS Rank_by_sales
FROM Orders o
JOIN Products p
ON o.ProductID = p.ProductID
JOIN Suppliers s
ON p.SupplierID = s.SupplierID
GROUP BY  s.SupplierCountry, o.CustomerID)

SELECT *
FROM cte
WHERE Rank_by_sales <= 3

------------------------------------------------------------------------------------------------------------
--7 by order, multi-item order
-----------------------------------------------------------------------------------------------------------------
WITH cte AS
(SELECT DISTINCT OrderID, o.ProductID, Category
FROM Orders o
JOIN Products p
ON o.ProductID = p.ProductID
JOIN Categories c
ON c.CategoryID = p.CategoryID),

cte_com AS 
(SELECT c.OrderID, 
       STRING_AGG(c.Category,',') AS Combining
FROM cte c
GROUP BY c.OrderID
HAVING COUNT(DISTINCT c.ProductID) >1)

SELECT Combining, COUNT(OrderID)
FROM cte_com 
GROUP BY Combining
ORDER BY COUNT(OrderID) DESC

-------------------------------------------------------------------------------------------------------------------------
--- multi-item orders-cont
-------------------------------------------------------------------------------------------------------------------------
WITH cte AS
(SELECT OrderID
FROM Orders
GROUP BY OrderID
HAVING COUNT(DISTINCT ProductID) >1)

SELECT c.OrderID,
       COUNT(c.OrderID) OVER (PARTITION BY c.OrderID) AS number_of_product,
	   p.Product,
	   ca.Category
FROM cte c
JOIN Orders o
ON c.OrderID = o.OrderID
JOIN Products p
ON o.ProductID = p.ProductID
JOIN Categories ca
ON ca.CategoryID = p.CategoryID


------------------------------------------------------------------------------------------------------------------------------------
--Max and Min value of an order
--------------------------------------------------------------------------------------------------------
SELECT MAX(Sales) AS max_sale,
       MIN(Sales) AS min_sale
FROM Orders
           
----------------------------------------------------------------------------------------------------
-- classify order
-----------------------------------------------------------------------------------------------------
WITH cte AS 
(SELECT OrderID,
       (CASE WHEN SUM(Sales) <=0 THEN 'N/A' 
	        WHEN SUM(Sales) < 1000 THEN 'A_Low_Value'
			WHEN SUM(Sales) < 2000 THEN 'B_Medium_Value'
			ELSE 'C_High_Value' END) AS Classify
FROM Orders
GROUP BY OrderID)

SELECT Classify,
       COUNT(OrderID) AS Number_Orders
FROM cte
GROUP BY Classify
ORDER BY COUNT(OrderID) DESC


------------------------------------------------------------------------------
-- 5 products in each category
---------------------------------------------------------------------

WITH cte AS
(SELECT c.Category,
       p.Product,
	   FORMAT(SUM(o.Sales), 'N0') AS Total_Sales,
	   SUM(o.Quantity) AS Total_quantities,
	   COUNT(DISTINCT o.OrderID) AS no_of_orders,
	   COUNT(DISTINCT s.SupplierID) AS no_of_Suppliers,
	   DENSE_RANK() OVER(PARTITION BY c.Category ORDER BY  SUM(o.Sales) DESC) AS Rank_by_sales
FROM Orders o
JOIN Products p
ON o.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
JOIN Suppliers s
ON s.SupplierID = p.SupplierID
GROUP BY  c.Category, p.Product)

SELECT *
FROM cte
WHERE Rank_by_sales <= 5

---------------------------------------------------------------------------------------------------------------
-- top suppliers in each category
--------------------------------------------------------------------------------------------------------------------

SELECT c.Category,
       s.Supplier,
	   FORMAT(SUM(o.Sales), 'N0') AS Total_Sales,
	   COUNT(DISTINCT o.OrderID) AS no_of_orders,
	   COUNT(DISTINCT p.ProductID) AS no_of_products,
	   DENSE_RANK() OVER(PARTITION BY c.Category ORDER BY  SUM(o.Sales) DESC) AS Rank_by_sales
FROM Orders o
JOIN Products p
ON o.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
JOIN Suppliers s
ON s.SupplierID = p.SupplierID
GROUP BY  c.Category, s.Supplier

---------------------------------------------------------------------------------------------------------
---top 10 product by Sales
-------------------------------------------------------------------------------------------------------

SELECT  TOP 10 p.ProductID,
       p.Product,
	   c.Category,
	   FORMAT(SUM(o.Sales), 'N0') AS Total_Sales,
	   SUM(o.Quantity) Total_Quantities,
	   COUNT(DISTINCT o.OrderID) AS no_of_orders
FROM Orders o
JOIN Products p
ON o.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
GROUP BY  p.ProductID, p.Product,c.Category
ORDER BY SUM(o.Sales) DESC

------------------------------------------------------------------------------------------------
--Top 10 products by sales in 2021
-----------------------------------------------------------------------------------------
SELECT  TOP 10 p.ProductID,
       p.Product,
	   c.Category,
	   FORMAT(SUM(o.Sales), 'N0') AS Total_Sales,
	   SUM(o.Quantity) Total_Quantities,
	   COUNT(DISTINCT o.OrderID) AS no_of_orders
FROM Orders o
JOIN Products p
ON o.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
WHERE DATEPART(YEAR, OrderDate) = 2021
GROUP BY  p.ProductID, p.Product,c.Category
ORDER BY SUM(o.Sales) DESC

----------------------------------------------------------------------------------------
-- Top 5 highest-cost product
---------------------------------------------------------------------------------------------
SELECT  TOP 5 p.ProductID,
       p.Product,
	   c.Category,
	   FORMAT(AVG(o.Sales), 'N0') AS Total_Sales,
	   FORMAT(AVG(o.Costs), 'N0') AS Total_Costs,
	   FORMAT(AVG(o.Discount), 'N0') AS Total_Discount,
	   ROUND(AVG(o.Freight),2) AS avg_frieght
FROM Orders o
JOIN Products p
ON o.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
GROUP BY  p.ProductID, p.Product,c.Category
ORDER BY AVG(o.Costs) DESC

--------------------------------------------------------------------------------
-- Top discount products
-----------------------------------------------------------------

SELECT p.ProductID,
       p.Product,
	   c.Category,
	   FORMAT(AVG(o.Discount), 'N0') AS AVG_Discount
FROM Orders o
JOIN Products p
ON o.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
GROUP BY  p.ProductID, p.Product,c.Category
ORDER BY AVG(o.Discount) DESC

---------------------------------------------------------------------------------------------------------
--Products have Profit < 5% of Sales

SELECT p.ProductID,
       p.Product,
	   c.Category,
	   ROUND(AVG(o.Sales), 2) AS AVG_Sales,
	   ROUND(AVG(o.Profit), 2) AS AVG_Profit,
	   ROUND(AVG(o.Profit)*100/ AVG(o.Sales),2) AS Profits_Sale
FROM Orders o
JOIN Products p
ON o.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
GROUP BY  p.ProductID, p.Product,c.Category
ORDER BY p.ProductID