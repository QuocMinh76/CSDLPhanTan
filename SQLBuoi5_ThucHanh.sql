--BÀI THỰC HÀNH 5
-- CÂU 1
RESTORE DATABASE Northwind1
FROM DISK = N'D:\Northwind1.bak'
GO

-- CÂU 2
-- Mức 1:
USE Northwind
GO

CREATE VIEW ViewThongKeSLKHTheoQGMuc1
AS
SELECT Country, Count(CustomerID) AS SLKhachHang
FROM Northwind.dbo.Customers
GROUP BY Country
GO

SELECT * FROM Northwind.dbo.ViewThongKeSLKHTheoQGMuc1
GO

DROP VIEW ViewThongKeSLKHTheoQGMuc1
GO

-- Mức 2:
USE Northwind1
GO

CREATE VIEW ViewThongKeSLKHTheoQGMuc2
AS
SELECT Country, Count(CustomerID) AS SLKhachHang
FROM Northwind1.dbo.KH1
GROUP BY Country
UNION
SELECT Country, Count(CustomerID) AS SLKhachHang
FROM Northwind1.dbo.KH2
GROUP BY Country
GO

SELECT * FROM Northwind1.dbo.ViewThongKeSLKHTheoQGMuc2
GO

DROP VIEW ViewThongKeSLKHTheoQGMuc2
GO

-- CÂU 3
-- Mức 1:
USE Northwind
GO

CREATE VIEW ViewThongKeSLDHTheoQGMuc1
AS
SELECT Country, Count(OrderID) AS SLDonHang
FROM Northwind.dbo.Customers c JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID
GROUP BY Country
GO

SELECT * FROM Northwind.dbo.ViewThongKeSLDHTheoQGMuc1
GO

DROP VIEW ViewThongKeSLDHTheoQGMuc1
GO

-- Mức 2:
USE Northwind1
GO

CREATE VIEW ViewThongKeSLDHTheoQGMuc2
AS
SELECT Country, Count(OrderID) AS SLDonHang
FROM Northwind1.dbo.KH1 c JOIN Northwind1.dbo.DH1 o ON c.CustomerID = o.CustomerID
GROUP BY Country
UNION
SELECT Country, Count(OrderID) AS SLDonHang
FROM Northwind1.dbo.KH2 c JOIN Northwind1.dbo.DH2 o ON c.CustomerID = o.CustomerID
GROUP BY Country
GO

SELECT * FROM Northwind1.dbo.ViewThongKeSLDHTheoQGMuc2
GO

DROP VIEW ViewThongKeSLDHTheoQGMuc2
GO

-- CÂU 4
-- Mức 1:
USE Northwind
GO

CREATE PROC ProcKHChuaMuaHangMuc1
AS
BEGIN
	SELECT *
	FROM Northwind.dbo.Customers c
	WHERE c.CustomerID NOT IN (SELECT CustomerID FROM Northwind.dbo.Orders)
END
GO

EXEC ProcKHChuaMuaHangMuc1
GO
-- Mức 2:
USE Northwind1
GO

CREATE PROC ProcKHChuaMuaHangMuc2
AS
BEGIN
	SELECT *
	FROM Northwind1.dbo.KH1 c
	WHERE c.CustomerID NOT IN (SELECT CustomerID FROM Northwind1.dbo.DH1)
	UNION
	SELECT *
	FROM Northwind1.dbo.KH2 c
	WHERE c.CustomerID NOT IN (SELECT CustomerID FROM Northwind1.dbo.DH2)
END
GO

EXEC ProcKHChuaMuaHangMuc2
GO

-- CÂU 5
-- Mức 1:
USE Northwind
GO

CREATE PROC ProcThemKHMuc1
@MaKH nchar(5), @TenCongTy nvarchar(40), @ThanhPho nvarchar(15), @QuocGia nvarchar(15)
AS
BEGIN
	INSERT INTO Northwind.dbo.Customers(CustomerID, CompanyName, City, Country)
	VALUES (@MaKH, @TenCongTy, @ThanhPho, @QuocGia)
END
GO

EXEC ProcThemKHMuc1 'KH001', 'Công ty 001', 'HCMC', 'Vietnam'
GO
EXEC ProcThemKHMuc1 'KH002', 'Công ty 002', 'London', 'UK'
GO

SELECT * FROM Northwind.dbo.Customers
GO

-- Mức 2:
USE Northwind1
GO

CREATE PROC ProcThemKHMuc2
@MaKH nchar(5), @TenCongTy nvarchar(40), @ThanhPho nvarchar(15), @QuocGia nvarchar(15)
AS
BEGIN
	IF @QuocGia = 'USA' OR @QuocGia = 'UK'
		INSERT INTO Northwind1.dbo.KH1(CustomerID, CompanyName, City, Country)
		VALUES (@MaKH, @TenCongTy, @ThanhPho, @QuocGia)
	ELSE
		INSERT INTO Northwind1.dbo.KH2(CustomerID, CompanyName, City, Country)
		VALUES (@MaKH, @TenCongTy, @ThanhPho, @QuocGia)
END
GO

EXEC ProcThemKHMuc2 'KH001', 'Công ty 001', 'HCMC', 'Vietnam'
GO

EXEC ProcThemKHMuc2 'KH002', 'Công ty 002', 'London', 'UK'
GO

SELECT * FROM Northwind1.dbo.KH1
UNION
SELECT * FROM Northwind1.dbo.KH2
GO

-- CÂU 6
-- Mức 1:
USE Northwind
GO

CREATE PROC ProcSuaKHMuc1
@MaKH nchar(5), @ThanhPho nvarchar(15), @QuocGia nvarchar(15)
AS
BEGIN
	UPDATE Northwind.dbo.Customers
	SET City = @ThanhPho, Country = @QuocGia
	WHERE CustomerID = @MaKH
END
GO

EXEC ProcSuaKHMuc1 'KH001', 'San Francisco', 'USA'
GO
EXEC ProcSuaKHMuc1 'KH002', 'Hanoi', 'Vietnam'
GO

SELECT * FROM Northwind.dbo.Customers
GO

-- Mức 2:
USE Northwind1
GO

CREATE PROC ProcSuaKHMuc2
@MaKH nchar(5), @ThanhPho nvarchar(15), @QuocGia nvarchar(15)
AS
BEGIN
	DECLARE @TenCty nvarchar(50)
	IF EXISTS (SELECT CustomerID FROM Northwind1.dbo.KH1 WHERE CustomerID = @MaKH)
		BEGIN
		UPDATE Northwind1.dbo.KH1
		SET City = @ThanhPho, Country = @QuocGia
		WHERE CustomerID = @MaKH
		SELECT @TenCty = CompanyName FROM Northwind1.dbo.KH1 WHERE CustomerID = @MaKH
		IF @QuocGia <> 'USA' AND @QuocGia <> 'UK'
			BEGIN
			INSERT INTO Northwind1.dbo.KH2(CustomerID, CompanyName, City, Country)
			VALUES (@MaKH, @TenCty, @ThanhPho, @QuocGia)
			DELETE FROM KH1 WHERE CustomerID = @MaKH
			END
		END
	ELSE
		BEGIN
		UPDATE Northwind1.dbo.KH2
		SET City = @ThanhPho, Country = @QuocGia
		WHERE CustomerID = @MaKH
		SELECT @TenCty = CompanyName FROM Northwind1.dbo.KH2 WHERE CustomerID = @MaKH
		IF @QuocGia = 'USA' OR @QuocGia = 'UK'
			BEGIN
			INSERT INTO Northwind1.dbo.KH1(CustomerID, CompanyName, City, Country)
			VALUES (@MaKH, @TenCty, @ThanhPho, @QuocGia)
			DELETE FROM KH2 WHERE CustomerID = @MaKH
			END
		END
END
GO

EXEC ProcSuaKHMuc2 'KH001', 'San Francisco', 'USA'
GO
EXEC ProcSuaKHMuc2 'KH002', 'Hanoi', 'Vietnam'
GO

SELECT * FROM Northwind1.dbo.KH1
UNION
SELECT * FROM Northwind1.dbo.KH2
GO

-- CÂU 7
-- Mức 1:
USE Northwind
GO

CREATE PROC ProcXoaKHMuc1
@MaKH nchar(5)
AS
BEGIN
	DELETE FROM Northwind.dbo.Customers WHERE CustomerID = @MaKH
END
GO

EXEC ProcXoaKHMuc1 'KH001'
GO
EXEC ProcXoaKHMuc1 'KH002'
GO

SELECT * FROM Northwind.dbo.Customers
GO

-- Mức 2:
USE Northwind1
GO

CREATE PROC ProcXoaKHMuc2
@MaKH nchar(5)
AS
BEGIN
		IF EXISTS (SELECT CustomerID FROM Northwind1.dbo.KH1 WHERE CustomerID = @MaKH)
		DELETE FROM Northwind1.dbo.KH1 WHERE CustomerID = @MaKH
	ELSE
		DELETE FROM Northwind1.dbo.KH2 WHERE CustomerID = @MaKH
END
GO

EXEC ProcXoaKHMuc2 'KH001'
GO
EXEC ProcXoaKHMuc2 'KH002'
GO

SELECT * FROM Northwind1.dbo.KH1
UNION
SELECT * FROM Northwind1.dbo.KH2
GO

-- CÂU 8
-- Mức 1:
USE Northwind
GO

CREATE FUNCTION FuncSLDHMuc1(@QG nvarchar(50))
RETURNS int
AS
BEGIN
	DECLARE @SL int
	SELECT @SL = Count(o.OrderID)
	FROM Northwind.dbo.Customers c JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID
	WHERE c.Country = @QG
	RETURN @SL
END
GO

SELECT dbo.FuncSLDHMuc1('USA') AS SLDonHang
SELECT dbo.FuncSLDHMuc1('UK') AS SLDonHang
SELECT dbo.FuncSLDHMuc1('Vietnam') AS SLDonHang
SELECT dbo.FuncSLDHMuc1('Brazil') AS SLDonHang

-- Mức 2:
USE Northwind1
GO

CREATE FUNCTION FuncSLDHMuc2(@QG nvarchar(50))
RETURNS int
AS
BEGIN
	DECLARE @SL1 int, @SL2 int
	SELECT @SL1 = Count(o.OrderID)
	FROM Northwind1.dbo.KH1 c JOIN Northwind1.dbo.DH1 o ON c.CustomerID = o.CustomerID
	WHERE c.Country = @QG
	SELECT @SL2 = Count(o.OrderID)
	FROM Northwind1.dbo.KH2 c JOIN Northwind1.dbo.DH2 o ON c.CustomerID = o.CustomerID
	WHERE c.Country = @QG
	RETURN @SL1 + @SL2
END
GO

SELECT dbo.FuncSLDHMuc2('USA') AS SLDonHang
SELECT dbo.FuncSLDHMuc2('UK') AS SLDonHang
SELECT dbo.FuncSLDHMuc2('Vietnam') AS SLDonHang
SELECT dbo.FuncSLDHMuc2('Brazil') AS SLDonHang

-- CÂU 9
-- Mức 1:
USE Northwind
GO

CREATE FUNCTION FuncDSDHMuc1(@QG nvarchar(50))
RETURNS TABLE
AS RETURN
(
		SELECT o.*
		FROM Northwind.dbo.Customers c JOIN Northwind.dbo.Orders o ON c.CustomerID = o.CustomerID
		WHERE c.Country = @QG
)
GO

SELECT * FROM dbo.FuncDSDHMuc1('USA')
SELECT * FROM dbo.FuncDSDHMuc1('UK')
SELECT * FROM dbo.FuncDSDHMuc1('Vietnam')
SELECT * FROM dbo.FuncDSDHMuc1('Brazil')

-- Mức 2:
USE Northwind1
GO

CREATE FUNCTION FuncDSDHMuc2(@QG nvarchar(50))
RETURNS TABLE
AS RETURN
(
		SELECT o.*
		FROM Northwind1.dbo.KH1 c JOIN Northwind1.dbo.DH1 o ON c.CustomerID = o.CustomerID
		WHERE c.Country = @QG
		UNION
		SELECT o.*
		FROM Northwind1.dbo.KH2 c JOIN Northwind1.dbo.DH2 o ON c.CustomerID = o.CustomerID
		WHERE c.Country = @QG
)
GO

SELECT * FROM dbo.FuncDSDHMuc2('USA')
SELECT * FROM dbo.FuncDSDHMuc2('UK')
SELECT * FROM dbo.FuncDSDHMuc2('Vietnam')
SELECT * FROM dbo.FuncDSDHMuc2('Brazil')

-- CÂU 10

BACKUP DATABASE Northwind
TO DISK = N'D:\NorthwindBuoi5.bak'
GO

BACKUP DATABASE Northwind1
TO DISK = N'D:\Northwind1Buoi5.bak'
GO