-- Query to display the name and email of all users who have placed an order.
SELECT u.id AS Id, u.name AS Name, u.email AS Email 
FROM Users u 
WHERE u.id IN (SELECT DISTINCT user_id FROM Orders);

-- Query to display the profit from the sale of each catalog.
SELECT
    c.id AS catalog_id,
    c.product_name,
    SUM((c.selling_price - c.manufacturing_cost) * od.quantity) AS total_profit
FROM Catalog c
JOIN OrderDetails od ON c.id = od.product_id
GROUP BY c.id, c.product_name
ORDER BY total_profit DESC;

-- Query to display the number of orders placed for each catalog.
SELECT c.id AS product_id, COUNT(o.id) AS total_orders
FROM Catalog c 
LEFT JOIN Users u ON u.id = c.ordered_by_user_id 
LEFT JOIN Orders o ON u.id = o.user_id 
GROUP BY c.id;

-- Query to display the number of locations for each warehouse.
SELECT warehouse_id AS WarehouseId, COUNT(*) AS LocationCount 
FROM Location 
GROUP BY warehouse_id;

-- Query to display the total manufacturing cost of each order for all stores.
SELECT
    o.id AS order_id,
    SUM(c.manufacturing_cost * od.quantity) AS total_manufacturing_cost
FROM Orders o
JOIN OrderDetails od ON o.id = od.order_id
JOIN Catalog c ON od.product_id = c.id
JOIN Warehouse w ON o.warehouse_id = w.id
GROUP BY o.id, w.name, w.country;

-- Query to display the average profit per order in a specific month for each store.
SELECT
    t.id StoreID,
    DATEPART(YEAR, o.order_time) AS order_year,
    DATEPART(MONTH, o.order_time) AS order_month,
    SUM((c.selling_price - c.manufacturing_cost) * od.quantity) / COUNT(DISTINCT o.id) AS average_profit_per_order
FROM Orders o
JOIN OrderDetails od ON o.id = od.order_id
JOIN Catalog c ON od.product_id = c.id
JOIN ThirdParty t ON o.third_party_id = t.id
WHERE DATEPART(YEAR, o.order_time) = 2023
    AND DATEPART(MONTH, o.order_time) = 9
GROUP BY DATEPART(YEAR, o.order_time), DATEPART(MONTH, o.order_time), t.id;

-- Query to display all available products along with their SKU.
SELECT product_name AS ProductName, sku FROM Catalog;

-- Query to display the total cost and number of orders for each customer within a specific time range.
SELECT
    u.id AS customer_id,
    COUNT(o.id) AS total_orders,
    SUM(o.total_cost) AS total_cost
FROM Users u
JOIN Orders o ON u.id = o.user_id
WHERE o.order_time BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY u.id
ORDER BY total_cost DESC;

-- Query to display the number of containers in each warehouse.
SELECT w.id AS WarehouseId, ISNULL(COUNT(l.id), 0) AS ContainerCount
FROM Warehouse w
LEFT JOIN Location l ON w.id = l.warehouse_id AND l.has_container = 1 
GROUP BY w.id;

-- Query to calculate the average profit for each day of the week for each third party.
WITH DailyProfit AS (
    SELECT 
        O.third_party_id,
        DATENAME(WEEKDAY, O.order_time) AS DayOfWeek,
        CONVERT(VARCHAR, O.order_time, 23) AS OrderDate,
        SUM(C.selling_price - C.manufacturing_cost) AS TotalProfit
    FROM Orders O
    JOIN Catalog C ON O.user_id = C.ordered_by_user_id
    GROUP BY O.third_party_id, CONVERT(VARCHAR, O.order_time, 23), DATENAME(WEEKDAY, O.order_time)
)
SELECT 
    third_party_id,
    DayOfWeek,
    AVG(TotalProfit) AS AverageProfit
FROM DailyProfit
GROUP BY third_party_id, DayOfWeek
ORDER BY third_party_id, 
    CASE DayOfWeek
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- Query to find the top three countries that bring the most profit to the stores.
WITH ProfitByCountry AS (
    SELECT 
        c.manufacturing_country,
        SUM((c.selling_price - c.manufacturing_cost) * od.quantity) AS TotalProfit
    FROM OrderDetails od
    JOIN Catalog c ON od.product_id = c.id
    GROUP BY c.manufacturing_country
)
SELECT TOP 3
    manufacturing_country,
    TotalProfit
FROM ProfitByCountry
ORDER BY TotalProfit DESC;

-- Query to find the users who bring the most profit to the stores.
WITH ProfitByUser AS (
    SELECT 
        od.ordered_by_user_id,
        SUM((c.selling_price - c.manufacturing_cost) * od.quantity) AS TotalProfit
    FROM OrderDetails od
    JOIN Catalog c ON od.product_id = c.id
    GROUP BY od.ordered_by_user_id
)
SELECT
    pu.ordered_by_user_id,
    SUM(pu.TotalProfit) AS TotalProfit
FROM ProfitByUser pu
GROUP BY pu.ordered_by_user_id
ORDER BY TotalProfit DESC;

-- Query to display the number of products available in each country.
SELECT
    w.country,
    COUNT(c.id) AS product_count
FROM Catalog c
JOIN ThirdParty t ON t.id = c.third_party_id
JOIN Warehouse w ON w.third_party_id = t.id
GROUP BY w.country
ORDER BY product_count DESC;

-- Query to display the activity percentage of each third party based on the number of orders.
SELECT
    tp.id AS ThirdPartyID,
    COUNT(o.id) AS TotalOrders,
    ROUND(CAST(COUNT(o.id) * 100.0 / (SELECT COUNT(*) FROM Orders) AS DECIMAL(10,2)), 2) AS ActivityPercentage
FROM ThirdParty tp
LEFT JOIN Orders o ON tp.id = o.third_party_id
GROUP BY tp.id
ORDER BY ActivityPercentage DESC;

-- Query to display the average monthly profit for each third party within a one-year period.
SELECT
    t.id AS third_party_id,
    YEAR(o.order_time) AS SaleYear,
    MONTH(o.order_time) AS SaleMonth,
    AVG((c.selling_price - c.manufacturing_cost) * od.quantity) AS AvgMonthlyProfit
FROM Orders o
JOIN OrderDetails od ON o.id = od.order_id
JOIN Catalog c ON od.product_id = c.id
JOIN ThirdParty t ON o.third_party_id = t.id
WHERE o.order_time >= DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) - 1, 0)
    AND o.order_time < DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)
GROUP BY YEAR(o.order_time), MONTH(o.order_time), t.id
ORDER BY SaleYear, SaleMonth;

-- Query to compare the average profit of orders placed during the middle of the week versus the end of the week.
WITH MiddleOfWeek AS (
    SELECT 
        AVG((c.selling_price - c.manufacturing_cost) * od.quantity) AS AvgProfitMiddleOfWeek
    FROM Orders o
    JOIN OrderDetails od ON o.id = od.order_id
    JOIN Catalog c ON od.product_id = c.id
    WHERE DATEPART(WEEKDAY, o.order_time) IN (2, 3, 4, 5, 6)
),
EndOfWeek AS (
    SELECT 
        AVG((c.selling_price - c.manufacturing_cost) * od.quantity) AS AvgProfitEndOfWeek
    FROM Orders o
    JOIN OrderDetails od ON o.id = od.order_id
    JOIN Catalog c ON od.product_id = c.id
    WHERE DATEPART(WEEKDAY, o.order_time) IN (1, 7)
)
SELECT 
    AvgProfitMiddleOfWeek,
    AvgProfitEndOfWeek
FROM MiddleOfWeek, EndOfWeek;

-- Query to find the users who make the most purchases.
WITH UserPurchaseCounts AS (
    SELECT
        ordered_by_user_id,
        COUNT(DISTINCT order_id) AS NumOrders
    FROM OrderDetails
    GROUP BY ordered_by_user_id
)
SELECT TOP 10
    ordered_by_user_id AS UserId,
    NumOrders
FROM UserPurchaseCounts
ORDER BY NumOrders DESC;

-- Query to find the geographical distribution of orders and determine which countries have the highest sales.
WITH SalesByCountry AS (
    SELECT
        w.country,
        SUM(od.quantity * c.selling_price) AS TotalSales
    FROM Orders o
    JOIN Warehouse w ON o.warehouse_id = w.id
    JOIN OrderDetails od ON o.id = od.order_id
    JOIN Catalog c ON od.product_id = c.id
    GROUP BY w.country
)
SELECT
    country,
    TotalSales
FROM SalesByCountry
ORDER BY TotalSales DESC;

-- Query to find the average profit in different age groups.
WITH ProfitByAgeGroup AS (
    SELECT
        CASE
            WHEN age BETWEEN 20 AND 29 THEN '20-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            ELSE '50+'
        END AS AgeGroup,
        SUM((c.selling_price - c.manufacturing_cost) * od.quantity) AS TotalProfit
    FROM OrderDetails od
    JOIN Orders o ON od.order_id = o.id
    JOIN Catalog c ON od.product_id = c.id
    JOIN Users u ON o.user_id = u.id
    GROUP BY CASE
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END
)
SELECT
    AgeGroup,
    AVG(TotalProfit) AS AvgProfit
FROM ProfitByAgeGroup
GROUP BY AgeGroup
ORDER BY AgeGroup;
