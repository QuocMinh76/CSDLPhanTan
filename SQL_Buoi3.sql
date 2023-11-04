-- Bài 2
USE Northwind
GO

CREATE FUNCTION TenNhanVienDayDu(@MaNV int)
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @ten nvarchar(50)
	SELECT @ten = FirstName + ' ' + LastName
	FROM Employees
	WHERE EmployeeID = @MaNV
	RETURN @ten
END
GO

SELECT dbo.TenNhanVienDayDu(2) AS TenNV
GO

-- Bai 3
CREATE FUNCTION  SLKhachHangCuaQuocGia(@TenQG nvarchar(20))
RETURNS int
AS
BEGIN
	DECLARE @SL int
	SELECT @SL = COUNT(CustomerID)
	FROM Customers
	WHERE Country = @TenQG
	RETURN @SL
END
GO

SELECT dbo.SLKhachHangCuaQuocGia('USA') AS SoLuongKH
GO

-- Bai 4

CREATE FUNCTION  SLDonHangCuaKhachHang1(@TenCTY nvarchar(50))
RETURNS int
AS
BEGIN
	DECLARE @SL int
	SELECT @SL = COUNT(o.OrderID)
	FROM Customers c, Orders o
	WHERE (c.CustomerID = o.CustomerID) AND c.CompanyName = @TenCTY
	RETURN @SL
END
GO

SELECT dbo.SLDonHangCuaKhachHang1('Cactus Comidas para llevar') AS SoLuongDH
GO

-- Bai 5

CREATE FUNCTION  SLDonHangCuaKhachHang2(@TenQG nvarchar(20), @TenTP nvarchar(50))
RETURNS int
AS
BEGIN
	DECLARE @SL int
	SELECT @SL = COUNT(o.OrderID)
	FROM Customers c, Orders o
	WHERE (c.CustomerID = o.CustomerID) AND c.Country = @TenQG AND c.City = @TenTP
	RETURN @SL
END
GO

SELECT dbo.SLDonHangCuaKhachHang2('UK', 'London') AS SoLuongDH
GO

-- Cau 6

CREATE FUNCTION  SLDonHangCuaKhachHang3(@TenQG nvarchar(20))
RETURNS int
AS

BEGIN
	DECLARE @SL int
	IF @TenQG is null or @TenQG = ''
		BEGIN
			SELECT @SL = COUNT(*)
			FROM Orders
		END
	ELSE
		BEGIN
			SELECT @SL = COUNT(o.OrderID)
			FROM Customers c, Orders o
			WHERE (c.CustomerID = o.CustomerID) AND c.Country = @TenQG
		END
	RETURN @SL
END
GO

SELECT dbo.SLDonHangCuaKhachHang3('Germany') AS SoLuongDH
GO

-- Bai 7

CREATE FUNCTION TongTienMuahangCuaKhachHang(@MaKH nchar(5))
RETURNS float
AS
BEGIN
	DECLARE @TongTien float
	SELECT @TongTien = SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))
	FROM Customers c, Orders o, [Order Details] od
	WHERE (c.CustomerID = o.CustomerID AND od.OrderID = o.OrderID) AND c.CustomerID = @MaKH
	RETURN @TongTien
END
GO

SELECT dbo.TongTienMuahangCuaKhachHang('QUICK') AS TongTienMuaHang
GO

-- Bai 9

CREATE FUNCTION DSDonHangCuaQuocGiaKhachHang1(@TenQG nvarchar(20))
RETURNS TABLE
AS RETURN
(
	SELECT o.*
	FROM Customers c, Orders o
	WHERE (c.CustomerID = o.CustomerID) AND c.Country = @TenQG
)
GO

SELECT * FROM dbo.DSDonHangCuaQuocGiaKhachHang1('USA')
GO

-- Bai 10

CREATE FUNCTION DSDonHangCuaQuocGiaKhachHang2(@TenQG nvarchar(20))
RETURNS TABLE
AS RETURN
(
	SELECT o.OrderID, FORMAT(o.OrderDate, 'dd/MM/yyyy') AS OrderDate, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TongTienDonHangPhaiTra
	FROM Customers c, Orders o, [Order Details] od
	WHERE (c.CustomerID = o.CustomerID AND o.OrderID = od.OrderID) AND c.Country = @TenQG
	GROUP BY o.OrderID, o.OrderDate
)
GO

SELECT * FROM dbo.DSDonHangCuaQuocGiaKhachHang2('UK')
GO

-- Bai 11

CREATE FUNCTION DSHangHoaCuaKhachHang1(@MaKH nchar(5))
RETURNS TABLE
AS RETURN
(
	SELECT p.ProductID, p.ProductName, SUM(od.Quantity) AS TongSoLuong
	FROM Customers c, Orders o, [Order Details] od, Products p
	WHERE (c.CustomerID = o.CustomerID 
		AND o.OrderID = od.OrderID
		AND od.ProductID = p.ProductID)
		AND c.CustomerID = @MaKH
	GROUP BY p.ProductID, p.ProductName
)
GO

SELECT * FROM dbo.DSHangHoaCuaKhachHang1('ALFKI')
GO

-- Bai 12

CREATE FUNCTION DSHangHoaCuaKhachHang2(@MaKH nchar(5) = null)
RETURNS TABLE
AS RETURN
(
	SELECT p.ProductID, p.ProductName, SUM(od.Quantity) AS TongSoLuong
	FROM Customers c
	JOIN Orders o ON c.CustomerID = o.CustomerID
	JOIN [Order Details] od on o.OrderID = od.OrderID
	JOIN Products p ON p.ProductID = od.ProductID
	WHERE @MaKH is null OR c.CustomerID = @MaKH
	GROUP BY p.ProductID, p.ProductName
)
GO

SELECT * FROM dbo.DSHangHoaCuaKhachHang2('ALFKI')
GO

-- Bai 14

CREATE TABLE R (A INT, B INT, C INT)
GO

CREATE TRIGGER Trigger2 ON R
FOR UPDATE, INSERT, DELETE
AS
IF EXISTS(SELECT * FROM inserted WHERE C is not null)
	Print N'Cột C vừa được thêm'
IF EXISTS(SELECT * FROM deleted WHERE C is not null)
	Print N'Cột C vừa bị xóa'
IF UPDATE(C)
	Print N'Cột C vừa được sửa'
GO

INSERT INTO R VALUES (1, 1, 1)
GO
UPDATE R SET C = 2 WHERE B=98
GO
DELETE FROM R WHERE B=98
GO
SELECT * FROM dbo.R
GO

-- Bai 15

CREATE TRIGGER Trigger3 ON R
FOR UPDATE 
AS
IF (UPDATE(A))
	BEGIN
		RAISERROR(N'Không được update cột A', 16, 10)
		ROLLBACK TRANSACTION
	END
GO

-- Bai 16

CREATE TRIGGER Trigger4 ON R
FOR UPDATE 
AS
IF (UPDATE(B))
	IF(EXISTS(SELECT * FROM inserted WHERE B>99)) 
		BEGIN
			RAISERROR(N'Không được update cột B lớn hơn 99', 16, 10)
			ROLLBACK TRANSACTION
		END
GO

-- Cau 17

CREATE TRIGGER Trigger5 ON R
FOR DELETE 
AS
IF(EXISTS(SELECT * FROM deleted))
	BEGIN
		RAISERROR(N'Không được delete trên bảng R', 16, 10)
		ROLLBACK TRANSACTION
	END
GO