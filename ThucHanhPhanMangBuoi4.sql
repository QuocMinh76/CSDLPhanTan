-- PHAN MANH NGANG
-- Cau 1
USE master
GO
CREATE DATABASE Northwind1
GO

USE Northwind1
GO

-- Cau 2
CREATE TABLE KH1 (
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address][nvarchar](60)NULL,
	[City][nvarchar](15)NULL,
	[Region][nvarchar](15)NULL,
	[PostalCode][nvarchar](10)NULL,
	[Country][nvarchar](15)NULL,
	[Phone][nvarchar](24)NULL,
	[Fax][nvarchar](24)NULL)
GO

CREATE TABLE KH2 (
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address][nvarchar](60)NULL,
	[City][nvarchar](15)NULL,
	[Region][nvarchar](15)NULL,
	[PostalCode][nvarchar](10)NULL,
	[Country][nvarchar](15)NULL,
	[Phone][nvarchar](24)NULL,
	[Fax][nvarchar](24)NULL)
GO

INSERT INTO Northwind1.dbo.KH1
SELECT *
FROM Northwind.dbo.Customers c
WHERE (c.Country = N'USA') OR (c.Country = N'UK')
GO

INSERT INTO Northwind1.dbo.KH2
SELECT *
FROM Northwind.dbo.Customers c
WHERE (c.Country <> N'USA') AND (c.Country <> N'UK')
GO

-- Cau 3
SELECT * FROM Northwind1.dbo.KH1 ORDER BY Country
GO

-- Cau 4
SELECT * FROM Northwind1.dbo.KH2 ORDER BY Country
GO

-- Cau 5: Muc 1
SELECT * FROM Northwind.dbo.Customers
GO

-- Cau 6: Muc 2
-- Cach 1: Khong dung duoc ORDER BY
USE Northwind1
GO

SELECT * FROM Northwind1.dbo.KH1
UNION
SELECT * FROM Northwind1.dbo.KH2

-- Cach 2: Dung duoc ORDER BY
USE Northwind1
GO

CREATE PROC DSTatCaKHMuc2Cach2
AS
BEGIN
	IF EXISTS(
			SELECT *
			FROM sys.tables
			JOIN sys.schemas
			ON sys.tables.schema_id = sys.schemas.schema_id
			WHERE sys.schemas.name = 'dbo' AND sys.tables.name = 'TAM')
		DROP TABLE Northwind1.dbo.TAM
	SELECT * INTO Northwind1.dbo.TAM FROM Northwind1.dbo.KH1
	INSERT INTO Northwind1.dbo.TAM SELECT * FROM Northwind1.dbo.KH2
	SELECT * FROM Northwind1.dbo.TAM ORDER BY Country	
END
GO

EXEC DSTatCaKHMuc2Cach2
GO

DROP TABLE Northwind1.dbo.TAM
GO

DROP PROC DSTatCaKHMuc2Cach2
GO

-- Cau 7
USE Northwind
GO

CREATE PROC DSKHQuocGia(@QG nvarchar(30))
AS
BEGIN
		SELECT * FROM Northwind.dbo.Customers WHERE Country = @QG
END
GO

EXEC DSKHQuocGia 'Canada'
GO

EXEC DSKHQuocGia 'USA'
GO

-- Cau 8
USE Northwind1
GO

CREATE PROC DSKHQuocGia2(@QG nvarchar(30))
AS
BEGIN
	IF (@QG = N'USA' OR @QG = N'UK')
		SELECT * FROM Northwind1.dbo.KH1 WHERE Country = @QG
	ELSE
		SELECT * FROM Northwind1.dbo.KH2 WHERE Country = @QG
END
GO

EXEC DSKHQuocGia2 'Canada'
GO

EXEC DSKHQuocGia2 'USA'
GO

-- Cau 9
USE Northwind1
GO

SELECT * INTO Northwind1.dbo.DH1
FROM Northwind.dbo.Orders o
WHERE o.CustomerID IN
		(SELECT CustomerID FROM Northwind1.dbo.KH1)
		--(SELECT CustomerID FROM Northwind.dbo.Customers WHERE Country = N'UK' OR Country = N'USA')
GO

SELECT * INTO Northwind1.dbo.DH2
FROM Northwind.dbo.Orders o
WHERE o.CustomerID IN
		(SELECT CustomerID FROM Northwind1.dbo.KH2)
		--(SELECT CustomerID FROM Northwind.dbo.Customers WHERE Country <> N'UK' AND Country <> N'USA')
GO

-- Cau 10
USE Northwind
GO
--Muc1
SELECT * FROM Northwind.dbo.Orders
GO
--Muc2
SELECT * FROM Northwind1.dbo.DH1
UNION
SELECT * FROM Northwind1.dbo.DH2
GO

-- Cau 12
USE Northwind
GO

CREATE PROC DSDHQuocGia(@QG nvarchar(30))
AS
BEGIN
		SELECT * FROM Northwind.dbo.Orders o
		WHERE o.CustomerID IN (SELECT CustomerID FROM Northwind.dbo.Customers WHERE Country = @QG)
END
GO

EXEC DSDHQuocGia 'Canada'
GO

EXEC DSDHQuocGia 'USA'
GO

-- Cau 13
USE Northwind1
GO

CREATE PROC DSDHQuocGia2(@QG nvarchar(30))
AS
BEGIN
	IF (@QG = N'USA' OR @QG = N'UK')
		SELECT * FROM Northwind1.dbo.DH1 o1
		WHERE o1.CustomerID IN (SELECT CustomerID FROM Northwind1.dbo.KH1 WHERE Country = @QG)
	ELSE
		SELECT * FROM Northwind1.dbo.DH2 o2
		WHERE o2.CustomerID IN (SELECT CustomerID FROM Northwind1.dbo.KH2 WHERE Country = @QG)
END
GO

EXEC DSDHQuocGia2 'Canada'
GO

EXEC DSDHQuocGia2 'USA'
GO

-- PHAN MANH DOC
-- Cau 14

USE Northwind1
GO

SELECT [EmployeeID], [LastName], [FirstName], [TitleOfCourtesy] INTO Northwind1.dbo.NV1
FROM Northwind.dbo.Employees

SELECT [EmployeeID], [Title], [Birthdate], [HireDate]
	, [Address], [City], [Region]
	, [PostalCode], [Country], [HomePhone]
	, [Extension], [Photo], [Notes]
	, [ReportsTo], [PhotoPath]
	INTO Northwind1.dbo.NV2
FROM Northwind.dbo.Employees
GO

-- Cau 15
-- Muc1:
SELECT * FROM Northwind.dbo.Employees
GO

-- Cau 16
-- Muc2:
SELECT * FROM Northwind1.dbo.NV1 em1, Northwind1.dbo.NV2 em2
WHERE em1.EmployeeID = em2.EmployeeID
GO
