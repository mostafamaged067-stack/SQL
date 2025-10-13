-- 1. Customers
CREATE TABLE dbo.Customers (
  CustomerID INT IDENTITY(1,1) PRIMARY KEY,
  FirstName NVARCHAR(100),
  LastName NVARCHAR(100),
  Email NVARCHAR(255) UNIQUE,
  Phone NVARCHAR(30),
  CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
  IsActive BIT DEFAULT 1,
  Country NVARCHAR(100),
  City NVARCHAR(100),
  BirthDate DATE NULL
);

-- 2. Categories
CREATE TABLE dbo.Categories (
  CategoryID INT IDENTITY(1,1) PRIMARY KEY,
  Name NVARCHAR(150),
  ParentCategoryID INT NULL,
  CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentCategoryID) REFERENCES dbo.Categories(CategoryID)
);

-- 3. Products
CREATE TABLE dbo.Products (
  ProductID INT IDENTITY(1,1) PRIMARY KEY,
  SKU NVARCHAR(50) UNIQUE,
  Name NVARCHAR(255),
  CategoryID INT,
  Price DECIMAL(10,2),
  Cost DECIMAL(10,2),
  CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
  IsActive BIT DEFAULT 1,
  CONSTRAINT FK_Products_Category FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID)
);

-- 4. Inventory
CREATE TABLE dbo.Inventory (
  InventoryID INT IDENTITY(1,1) PRIMARY KEY,
  ProductID INT,
  Quantity INT,
  ReorderLevel INT DEFAULT 10,
  LastUpdated DATETIME2 DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_Inventory_Product FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);

-- 5. Orders (Header)
CREATE TABLE dbo.Orders (
  OrderID BIGINT IDENTITY(100000,1) PRIMARY KEY,
  CustomerID INT,
  OrderDate DATETIME2 DEFAULT SYSUTCDATETIME(),
  TotalAmount DECIMAL(12,2),
  Currency NVARCHAR(10) DEFAULT 'EGP',
  Status NVARCHAR(50) DEFAULT 'Pending', -- Pending, Paid, Shipped, Completed, Cancelled, Returned
  ShippingAddress NVARCHAR(500),
  BillingAddress NVARCHAR(500),
  IPAddress NVARCHAR(45),
  UserAgent NVARCHAR(1000),
  CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID)
);

-- 6. OrderItems
CREATE TABLE dbo.OrderItems (
  OrderItemID BIGINT IDENTITY(1,1) PRIMARY KEY,
  OrderID BIGINT,
  ProductID INT,
  Quantity INT,
  UnitPrice DECIMAL(10,2),
  Discount DECIMAL(10,2) DEFAULT 0,
  CONSTRAINT FK_OrderItems_Order FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID),
  CONSTRAINT FK_OrderItems_Product FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);

-- 7. Payments
CREATE TABLE dbo.Payments (
  PaymentID BIGINT IDENTITY(1,1) PRIMARY KEY,
  OrderID BIGINT,
  PaymentMethod NVARCHAR(50), -- Card, PayPal, CashOnDelivery
  Amount DECIMAL(12,2),
  PaymentStatus NVARCHAR(50), -- success, failed, pending
  TransactionID NVARCHAR(255),
  PaidAt DATETIME2,
  CardLast4 NVARCHAR(4) NULL,
  BillingIP NVARCHAR(45) NULL,
  CONSTRAINT FK_Payments_Order FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID)
);

-- 8. Shipments
CREATE TABLE dbo.Shipments (
  ShipmentID BIGINT IDENTITY(1,1) PRIMARY KEY,
  OrderID BIGINT,
  ShippedAt DATETIME2,
  DeliveredAt DATETIME2 NULL,
  Carrier NVARCHAR(100),
  TrackingNumber NVARCHAR(200),
  ShippingStatus NVARCHAR(50),
  CONSTRAINT FK_Shipments_Order FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID)
);

-- 9. Returns
CREATE TABLE dbo.Returns (
  ReturnID BIGINT IDENTITY(1,1) PRIMARY KEY,
  OrderID BIGINT,
  ReturnedAt DATETIME2,
  Reason NVARCHAR(500),
  RefundAmount DECIMAL(12,2),
  Status NVARCHAR(50),
  CONSTRAINT FK_Returns_Order FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID)
);

-- 10. Sessions (صفحات / سلوك)
CREATE TABLE dbo.Sessions (
  SessionID BIGINT IDENTITY(1,1) PRIMARY KEY,
  CustomerID INT NULL,
  SessionStart DATETIME2,
  SessionEnd DATETIME2 NULL,
  IPAddress NVARCHAR(45),
  Device NVARCHAR(100),
  Browser NVARCHAR(200),
  PagesViewed INT DEFAULT 0,
  Actions NVARCHAR(MAX) -- JSON أو نص يحتوي على الأحداث
);

-- 11. Reviews
CREATE TABLE dbo.Reviews (
  ReviewID BIGINT IDENTITY(1,1) PRIMARY KEY,
  ProductID INT,
  CustomerID INT,
  Rating TINYINT CHECK (Rating BETWEEN 1 AND 5),
  ReviewText NVARCHAR(MAX),
  CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_Reviews_Product FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID),
  CONSTRAINT FK_Reviews_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID)
);

-- 12. TransactionsLog (بوابة الدفع)
CREATE TABLE dbo.TransactionsLog (
  LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
  TransactionID NVARCHAR(255),
  OrderID BIGINT NULL,
  EventTime DATETIME2 DEFAULT SYSUTCDATETIME(),
  StatusCode INT,
  Message NVARCHAR(1000),
  RawPayload NVARCHAR(MAX)
);

-- 13. FraudFlags
CREATE TABLE dbo.FraudFlags (
  FlagID BIGINT IDENTITY(1,1) PRIMARY KEY,
  OrderID BIGINT NULL,
  CustomerID INT NULL,
  FlagType NVARCHAR(100), -- e.g., "HighVelocity", "MultipleCards", "ShippingMismatch"
  Details NVARCHAR(MAX),
  CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
  Resolved BIT DEFAULT 0
);


-- مثال على عملاء
INSERT INTO dbo.Customers (FirstName, LastName, Email, Phone, Country, City, BirthDate)
VALUES 
('Ahmed','Ali','ahmed.ali@example.com','01012345678','Egypt','Cairo','1995-05-12'),
('Sara','Hassan','sara.h@example.com','01198765432','Egypt','Alexandria','1992-10-01');

-- فئات
INSERT INTO dbo.Categories (Name) VALUES ('Electronics'),('Home Appliances'),('Fashion');

-- منتجات
INSERT INTO dbo.Products (SKU, Name, CategoryID, Price, Cost)
VALUES ('SKU-0001','Smartphone X',1,7999.00,5000.00),
       ('SKU-0002','Microwave 20L',2,1200.00,700.00),
       ('SKU-0003','T-Shirt Cotton',3,199.00,70.00);

-- مخزون
INSERT INTO dbo.Inventory (ProductID, Quantity) VALUES (1,150),(2,60),(3,500);

-- طلب + تفاصيل
INSERT INTO dbo.Orders (CustomerID, TotalAmount, ShippingAddress, BillingAddress, IPAddress, UserAgent)
VALUES (1,8198.00,'Cairo, Maadi','Cairo, Maadi','41.32.12.5','Mozilla/5.0...');

INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES (100000,1,1,7999.00),(100000,3,1,199.00);

-- دفع
INSERT INTO dbo.Payments (OrderID, PaymentMethod, Amount, PaymentStatus, TransactionID, PaidAt, CardLast4, BillingIP)
VALUES (100000,'Card',8198.00,'success','TXN123456','2025-10-01T10:05:00','1234','41.32.12.5');

-- لوج بوابة الدفع
INSERT INTO dbo.TransactionsLog (TransactionID, OrderID, StatusCode, Message, RawPayload)
VALUES ('TXN123456',100000,200,'APPROVED','{...}');


-- إنشاء Index لتحسين استعلامات البحث على Orders حسب OrderDate و CustomerID
CREATE INDEX IX_Orders_OrderDate_Customer ON dbo.Orders(OrderDate, CustomerID);

-- Index على Payments حسب PaymentStatus و PaidAt
CREATE INDEX IX_Payments_Status_PaidAt ON dbo.Payments(PaymentStatus, PaidAt);

-- Index على TransactionsLog حسب TransactionID و EventTime (للبحث السريع)
CREATE INDEX IX_TransLog_TransactionID_EventTime ON dbo.TransactionsLog(TransactionID, EventTime);


SELECT
  FORMAT(OrderDate,'yyyy-MM') AS YearMonth,
  COUNT(DISTINCT OrderID) AS OrdersCount,
  SUM(TotalAmount) AS Revenue,
  AVG(TotalAmount) AS AvgOrderValue
FROM dbo.Orders
WHERE OrderDate >= DATEADD(month,-12,GETDATE())
  AND Status IN ('Paid','Shipped','Completed')
GROUP BY FORMAT(OrderDate,'yyyy-MM')
ORDER BY YearMonth;


SELECT TOP 10
  p.ProductID,
  p.Name,
  SUM(oi.Quantity) AS UnitsSold,
  SUM(oi.Quantity * oi.UnitPrice - oi.Discount) AS Revenue
FROM dbo.OrderItems oi
JOIN dbo.Products p ON oi.ProductID = p.ProductID
JOIN dbo.Orders o ON oi.OrderID = o.OrderID
WHERE o.OrderDate >= DATEADD(month,-6,GETDATE())
  AND o.Status IN ('Paid','Shipped','Completed')
GROUP BY p.ProductID, p.Name
ORDER BY Revenue DESC;


-- عدد الجلسات التي انتهت بعمل طلب
WITH sessions_with_order AS (
  SELECT s.SessionID, s.CustomerID, COUNT(o.OrderID) AS OrdersCount
  FROM dbo.Sessions s
  LEFT JOIN dbo.Orders o
    ON s.CustomerID = o.CustomerID
    AND o.OrderDate BETWEEN s.SessionStart AND ISNULL(s.SessionEnd, DATEADD(minute,30,s.SessionStart))
  GROUP BY s.SessionID, s.CustomerID
)
SELECT
  (SELECT COUNT(*) FROM sessions_with_order WHERE OrdersCount > 0) AS SessionsWithOrder,
  (SELECT COUNT(*) FROM dbo.Sessions) AS TotalSessions,
  CAST(100.0 * (SELECT COUNT(*) FROM sessions_with_order WHERE OrdersCount > 0) / NULLIF((SELECT COUNT(*) FROM dbo.Sessions),0) AS DECIMAL(5,2)) AS ConversionRatePct;



  WITH signups AS (
  SELECT CustomerID, FORMAT(CreatedAt,'yyyy-MM') AS CohortMonth
  FROM dbo.Customers
),
orders_by_month AS (
  SELECT CustomerID, FORMAT(OrderDate,'yyyy-MM') AS OrderMonth
  FROM dbo.Orders
  WHERE OrderDate >= DATEADD(month,-12,GETDATE())
)
SELECT s.CohortMonth, o.OrderMonth, COUNT(DISTINCT o.CustomerID) AS ActiveCustomers
FROM signups s
JOIN orders_by_month o ON s.CustomerID = o.CustomerID
GROUP BY s.CohortMonth, o.OrderMonth
ORDER BY s.CohortMonth, o.OrderMonth;


-- نحسب Recency, Frequency, Monetary لكل عميل
WITH last_order AS (
  SELECT CustomerID, MAX(OrderDate) AS LastOrderDate, COUNT(OrderID) AS Frequency, SUM(TotalAmount) AS Monetary
  FROM dbo.Orders
  WHERE Status IN ('Paid','Shipped','Completed')
  GROUP BY CustomerID
)
SELECT
  c.CustomerID,
  c.FirstName,
  c.LastName,
  DATEDIFF(day, lo.LastOrderDate, GETDATE()) AS RecencyDays,
  lo.Frequency,
  lo.Monetary
FROM last_order lo
JOIN dbo.Customers c ON lo.CustomerID = c.CustomerID
ORDER BY lo.Monetary DESC;




;WITH rfm AS (
  SELECT
    c.CustomerID,
    DATEDIFF(day, MAX(o.OrderDate), GETDATE()) AS Recency,
    COUNT(o.OrderID) AS Frequency,
    SUM(o.TotalAmount) AS Monetary
  FROM dbo.Customers c
  LEFT JOIN dbo.Orders o ON c.CustomerID = o.CustomerID AND o.Status IN ('Paid','Shipped','Completed')
  GROUP BY c.CustomerID
),
rfm_rank AS (
  SELECT *,
    NTILE(5) OVER (ORDER BY Recency ASC) AS RScore,       -- أقل Recency أفضل => رقميًا أقل يعني أفضل
    NTILE(5) OVER (ORDER BY Frequency DESC) AS FScore,
    NTILE(5) OVER (ORDER BY Monetary DESC) AS MScore
  FROM rfm
)
SELECT CustomerID, Recency, Frequency, Monetary, RScore, FScore, MScore,
       CAST(RScore AS VARCHAR)+CAST(FScore AS VARCHAR)+CAST(MScore AS VARCHAR) AS RFM_Score
FROM rfm_rank
ORDER BY Monetary DESC;



-- Orders from same IP with > X orders in last Y minutes
SELECT IPAddress, COUNT(*) AS OrdersCount, MIN(OrderDate) AS FirstOrder, MAX(OrderDate) AS LastOrder
FROM dbo.Orders
WHERE OrderDate >= DATEADD(hour,-1,GETDATE()) -- آخر ساعة
GROUP BY IPAddress
HAVING COUNT(*) >= 5;



SELECT p.CardLast4, COUNT(DISTINCT o.ShippingAddress) AS DistinctShipping, MIN(o.OrderDate) AS FirstOrder, MAX(o.OrderDate) AS LastOrder
FROM dbo.Payments p
JOIN dbo.Orders o ON p.OrderID = o.OrderID
WHERE p.CardLast4 IS NOT NULL
  AND o.OrderDate >= DATEADD(day,-7,GETDATE())
GROUP BY p.CardLast4
HAVING COUNT(DISTINCT o.ShippingAddress) >= 3;



SELECT o.OrderID, c.Email, o.ShippingAddress, o.BillingAddress, p.BillingIP
FROM dbo.Orders o
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
LEFT JOIN dbo.Payments p ON o.OrderID = p.OrderID
WHERE (o.ShippingAddress NOT LIKE '%' + o.BillingAddress + '%')
  AND p.BillingIP IS NOT NULL
  AND ( -- مثال: BillingIP geolocation logic not in DB but نقدر نشك:
       p.BillingIP NOT LIKE '41.%' -- لو مصر IPs غالبًا تبدأ بـ41.* (مثال)
      );



INSERT INTO dbo.FraudFlags (OrderID, CustomerID, FlagType, Details)
SELECT o.OrderID, o.CustomerID, 'HighVelocity',
       CONCAT('OrdersFromIP=',o.IPAddress,' Count=',cnt.OrdersCount)
FROM dbo.Orders o
JOIN (
  SELECT IPAddress, COUNT(*) AS OrdersCount
  FROM dbo.Orders
  WHERE OrderDate >= DATEADD(hour,-1,GETDATE())
  GROUP BY IPAddress
  HAVING COUNT(*) >= 5
) AS cnt ON o.IPAddress = cnt.IPAddress
WHERE o.OrderDate >= DATEADD(hour,-1,GETDATE());


-- View: MonthlySalesSummary
GO
CREATE VIEW dbo.vw_MonthlySalesSummary AS
SELECT
  FORMAT(OrderDate,'yyyy-MM') AS YearMonth,
  COUNT(DISTINCT OrderID) AS OrdersCount,
  SUM(TotalAmount) AS Revenue,
  AVG(TotalAmount) AS AvgOrder
FROM dbo.Orders
WHERE Status IN ('Paid','Shipped','Completed')
GROUP BY FORMAT(OrderDate,'yyyy-MM');


GO
CREATE PROCEDURE dbo.usp_GenerateMonthlyReport
  @YearMonth NVARCHAR(7) -- '2025-10'
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @start DATETIME2 = CONVERT(datetime2, @YearMonth + '-01');
  DECLARE @end DATETIME2 = DATEADD(month, 1, @start);

  -- Sales summary
  SELECT
    COUNT(DISTINCT OrderID) AS OrdersCount,
    SUM(TotalAmount) AS Revenue,
    AVG(TotalAmount) AS AvgOrderValue
  FROM dbo.Orders
  WHERE OrderDate >= @start AND OrderDate < @end
    AND Status IN ('Paid','Shipped','Completed');

  -- Top customers by revenue
  SELECT TOP 10 c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS CustomerRevenue
  FROM dbo.Orders o
  JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
  WHERE o.OrderDate >= @start AND o.OrderDate < @end
    AND o.Status IN ('Paid','Shipped','Completed')
  GROUP BY c.CustomerID, c.FirstName, c.LastName
  ORDER BY CustomerRevenue DESC;

  -- Top products
  SELECT TOP 10 p.ProductID, p.Name, SUM(oi.Quantity) AS UnitsSold, SUM(oi.Quantity * oi.UnitPrice) AS Revenue
  FROM dbo.OrderItems oi
  JOIN dbo.Orders o ON oi.OrderID = o.OrderID
  JOIN dbo.Products p ON oi.ProductID = p.ProductID
  WHERE o.OrderDate >= @start AND o.OrderDate < @end
    AND o.Status IN ('Paid','Shipped','Completed')
  GROUP BY p.ProductID, p.Name
  ORDER BY Revenue DESC;
END;


-- cumulative revenue per day last 30 days
SELECT
  CAST(OrderDate AS date) AS OrderDay,
  SUM(TotalAmount) AS DayRevenue,
  SUM(SUM(TotalAmount)) OVER (ORDER BY CAST(OrderDate AS date) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeRevenue
FROM dbo.Orders
WHERE OrderDate >= DATEADD(day,-30,GETDATE())
  AND Status IN ('Paid','Shipped','Completed')
GROUP BY CAST(OrderDate AS date)
ORDER BY OrderDay;
