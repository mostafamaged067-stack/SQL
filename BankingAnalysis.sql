-- ============================================
-- BankingAnalysis Database - Full Setup Script (SQL Server Compatible)
-- ============================================

-- Step 1: Create Database
CREATE DATABASE BankingAnalysis;
GO

-- Step 2: Use Database
USE BankingAnalysis;
GO

-- Step 3: Create Tables
CREATE TABLE BankClients (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    AccountNumber NVARCHAR(20) UNIQUE NOT NULL,
    Country NVARCHAR(50),
    Balance DECIMAL(12,2) DEFAULT 0.00
);

CREATE TABLE BankTransactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    [Date] DATE NOT NULL,
    [Type] NVARCHAR(20) CHECK ([Type] IN ('Deposit', 'Withdrawal', 'Transfer')),
    Amount DECIMAL(12,2) NOT NULL,
    Description NVARCHAR(200),
    IsFraud BIT DEFAULT 0
);

CREATE TABLE FraudDetectionAlerts (
    AlertID INT IDENTITY(1,1) PRIMARY KEY,
    TransactionID INT FOREIGN KEY REFERENCES Transactions(TransactionID) ON DELETE CASCADE,
    RiskScore DECIMAL(5,2) DEFAULT 0.00,
    AlertDate DATE DEFAULT GETDATE()
);
GO

-- Step 4: Insert Sample Data
INSERT INTO BankClients (Name, AccountNumber, Country, Balance) VALUES
(N'Ahmed Mohamed', 'ACC001', 'Egypt', 5000.00),
(N'Fatma Ali', 'ACC002', 'Saudi Arabia', 12000.00),
(N'Ali Hassan', 'ACC003', 'Egypt', 3000.00),
(N'Sarah Ahmed', 'ACC004', 'UAE', 8000.00),
(N'Mohamed Khaled', 'ACC005', 'Jordan', 2000.00);

INSERT INTO BankTransactions (CustomerID, [Date], [Type], Amount, Description, IsFraud) VALUES
(1, '2023-10-01', 'Deposit', 1000.00, N'Salary deposit', 0),
(1, '2023-10-02', 'Withdrawal', 500.00, N'Groceries', 0),
(1, '2023-10-03', 'Transfer', 20000.00, N'Suspicious foreign transfer', 1),
(2, '2023-10-01', 'Deposit', 5000.00, N'Cash deposit', 0),
(2, '2023-10-05', 'Withdrawal', 1000.00, N'ATM withdrawal', 0),
(2, '2023-10-06', 'Transfer', 15000.00, N'Transfer to friend', 0),
(3, '2023-10-04', 'Deposit', 2000.00, N'Car sale', 0),
(3, '2023-10-07', 'Withdrawal', 300.00, N'Electric bill', 0),
(3, '2023-10-08', 'Transfer', 50000.00, N'Unexpected large transfer', 1),
(4, '2023-10-09', 'Deposit', 3000.00, N'Investment', 0),
(4, '2023-10-10', 'Withdrawal', 200.00, N'Shopping', 0),
(4, '2023-10-11', 'Transfer', 1000.00, N'Bill payment', 0),
(5, '2023-10-12', 'Deposit', 1500.00, N'Gift', 0),
(5, '2023-10-13', 'Withdrawal', 800.00, N'Travel', 0),
(5, '2023-10-14', 'Transfer', 25000.00, N'Foreign country transfer', 1),
(1, '2023-10-15', 'Deposit', 600.00, N'Investment return', 0),
(2, '2023-10-16', 'Withdrawal', 1200.00, N'Electronics purchase', 0),
(3, '2023-10-17', 'Transfer', 400.00, N'Family help', 0),
(4, '2023-10-18', 'Deposit', 700.00, N'Bonus', 0),
(5, '2023-10-19', 'Withdrawal', 150.00, N'Meal', 0);

INSERT INTO FraudDetectionAlerts (TransactionID, RiskScore) VALUES
(3, 95.50),
(9, 98.00),
(15, 92.30);
GO

-- Step 5: Verify Data
SELECT * FROM BankClients;
SELECT * FROM BankTransactions;
SELECT * FROM FraudDetectionAlerts;


------------------------------------------------------------
-- Banking Analysis Project - Complete SQL Script
------------------------------------------------------------

-- 1. Display transactions for a specific client with filtering by date and type
SELECT 
    t.TransactionID AS ID, 
    t.[Date], 
    t.[Type], 
    t.Amount AS Amount, 
    t.Description
FROM BankTransactions t
JOIN BankClients c ON t.CustomerID = c.CustomerID
WHERE 
    c.Name LIKE 'Ahmed%'  -- Text search using LIKE
    AND (t.[Date] >= '2023-10-01' OR t.[Type] = 'Deposit')  -- Combined conditions
ORDER BY t.[Date] DESC;  -- Sort by date descending


------------------------------------------------------------
-- 2. Search for suspicious transactions (keywords + high amount)
------------------------------------------------------------
SELECT 
    t.TransactionID, 
    t.Description, 
    t.Amount
FROM BankTransactions t
WHERE 
    (t.Description LIKE '%suspicious%' OR t.Description LIKE '%foreign%')  -- keyword filter
    AND t.Amount > 10000;  -- amount filter


------------------------------------------------------------
-- 3. Monthly spending summary per client (2023)
------------------------------------------------------------
SELECT 
    c.Name AS ClientName,
    MONTH(t.[Date]) AS MonthNumber,
    COUNT(t.TransactionID) AS TransactionCount,
    SUM(CASE WHEN t.[Type] = 'Withdrawal' THEN t.Amount ELSE 0 END) AS TotalSpending,
    AVG(t.Amount) AS AverageAmount,
    MIN(t.Amount) AS MinAmount,
    MAX(t.Amount) AS MaxAmount
FROM BankClients c
JOIN BankTransactions t ON c.CustomerID = t.CustomerID
WHERE YEAR(t.[Date]) = 2023
GROUP BY c.CustomerID, c.Name, MONTH(t.[Date])
HAVING SUM(CASE WHEN t.[Type] = 'Withdrawal' THEN t.Amount ELSE 0 END) > 1000
ORDER BY TotalSpending DESC;


------------------------------------------------------------
-- 4. Fraud analysis by country
------------------------------------------------------------
SELECT 
    c.Country AS Country,
    COUNT(CASE WHEN t.IsFraud = 1 THEN 1 END) AS FraudCount,
    MAX(f.RiskScore) AS HighestRisk
FROM BankClients c
JOIN BankTransactions t ON c.CustomerID = t.CustomerID
LEFT JOIN FraudDetectionAlerts f ON t.TransactionID = f.TransactionID
GROUP BY c.Country
HAVING COUNT(CASE WHEN t.IsFraud = 1 THEN 1 END) > 0
ORDER BY FraudCount DESC;


------------------------------------------------------------
-- 5. Detect clients with multiple large transactions on the same day
------------------------------------------------------------
SELECT 
    c.Name AS ClientName,
    t.[Date],
    COUNT(*) AS LargeTransactionCount,
    SUM(t.Amount) AS TotalAmount
FROM BankClients c
JOIN BankTransactions t ON c.CustomerID = t.CustomerID
WHERE 
    t.Amount > 10000 
    AND (t.[Type] = 'Transfer' OR t.IsFraud = 1)
GROUP BY c.CustomerID, c.Name, t.[Date]
HAVING COUNT(*) > 1
ORDER BY TotalAmount DESC;


------------------------------------------------------------
-- 6. Update and insert fraud alert for specific transaction
------------------------------------------------------------
-- Step 1: Update transaction #6 (Fatma's transfer) if amount is large
UPDATE t
SET 
    t.IsFraud = 1,
    t.Description = t.Description + ' - Suspicious'
FROM BankTransactions t
INNER JOIN BankClients c ON t.CustomerID = c.CustomerID
WHERE 
    t.TransactionID = 6 
    AND t.Amount > 10000;

-- Step 2: Insert new fraud alert for that transaction
INSERT INTO FraudDetectionAlerts (TransactionID, RiskScore)
VALUES (6, 90.00);


------------------------------------------------------------
-- 7. Delete old or small transactions for Egyptian clients
------------------------------------------------------------
DELETE t
FROM BankTransactions t
INNER JOIN BankClients c ON t.CustomerID = c.CustomerID
WHERE 
    (t.Date < '2023-10-01' OR t.Amount < 10.00)
    AND c.Country = 'Egypt'
    AND t.IsFraud = 0;
