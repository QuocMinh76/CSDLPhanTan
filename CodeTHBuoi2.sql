USE Northwind
Go
--Cau 2
CREATE VIEW DSDonHangCuaKhachHangMyAnh
AS
SELECT o.*
FROM dbo.Customers c, dbo.Orders o
WHERE (Country like 'USA' or Country like 'UK') and c.CustomerID = o.CustomerID
go

SELECT * FROM dbo.DSDonHangCuaKhachHangMyAnh
go

--Cau 3
CREATE VIEW DSKhachHangLaVIP
AS
SELECT *
FROM Customers
WHERE ContactTitle like '%Manager%' or ContactTitle like 'Owner'
go

SELECT * FROM dbo.DSKhachHangLaVIP
go

-- Cau 4

CREATE VIEW DSDonHang
AS
SELECT o.OrderID, o.OrderDate, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) as TongTienDonHang
FROM [Order Details] od, Orders o
WHERE od.OrderID = o.OrderID
GROUP BY o.OrderID, o.OrderDate
go

SELECT * FROM dbo.DSDonHang
go

-- Cau 5

CREATE VIEW DSThongKeTheoQGKhachHang
AS
SELECT c.Country, 
	COUNT(DISTINCT c.CustomerID) as SLKhachHang, --Them distinct vi bi trung makh
	COUNT(DISTINCT o.OrderID) as SLDonHang,
	SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) as TongTienMuaHang
FROM Customers c, [Order Details] od, Orders o
WHERE (c.CustomerID = o.CustomerID) and (o.OrderID = od.OrderID)
GROUP BY c.Country
go

--Cau 7
CREATE PROC DSDonHangTungQuocGia 
@TenQuocGia nvarchar(20)
AS
Begin
	SELECT o.*, c.Country
	FROM Customers c, Orders o
	WHERE c.CustomerID = o.CustomerID and c.Country = @TenQuocGia
End
go

EXEC DSDonHangTungQuocGia N'Germany'
go

-- Cau 11
CREATE PROC SLKhachHangTungQuocGia4
@TenQG nvarchar(20), @SLKH int out
AS
Begin
	if @TenQG is null
		SELECT @SLKH = Count(*)
		FROM Customers c
		WHERE c.Country = 'France'
	else
		SELECT @SLKH = Count(*)
		FROM Customers c
		WHERE c.Country = @TenQG
End
go

DECLARE @KQ int
EXEC SLKhachHangTungQuocGia4 'USA', @KQ out
Print @KQ
go

-- Cau 12

CREATE PROC DSDonHangTungNhanVien
@MaNV int
AS
Begin
	SELECT o.OrderID, OrderDate, e.EmployeeID,
		SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) as TongTienDonHang
	FROM [Order Details] od, Orders o, Employees e
	WHERE (o.EmployeeID = e.EmployeeID and o.OrderID = od.OrderID) and e.EmployeeID = @MaNV
	GROUP BY o.OrderID, OrderDate, e.EmployeeID
End
go

EXEC DSDonHangTungNhanVien 1 -- Ma nhan vien la so nguyen
go

-- Cau 13

CREATE PROC DSDonHangTungNhanVien2
@MaNV int
AS
Begin
	if @MaNV is null
		SELECT o.OrderID, OrderDate, e.EmployeeID,
			SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) as TongTienDonHang
		FROM [Order Details] od, Orders o, Employees e
		WHERE (o.EmployeeID = e.EmployeeID and o.OrderID = od.OrderID)
		GROUP BY o.OrderID, OrderDate, e.EmployeeID
	else
		SELECT o.OrderID, OrderDate, e.EmployeeID,
			SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) as TongTienDonHang
		FROM [Order Details] od, Orders o, Employees e
		WHERE (o.EmployeeID = e.EmployeeID and o.OrderID = od.OrderID) and e.EmployeeID = @MaNV
		GROUP BY o.OrderID, OrderDate, e.EmployeeID
End
go

EXEC DSDonHangTungNhanVien2 null -- Ma nhan vien la so nguyen / Neu khong truyen thi go null
go

-- Cau 14. Giai phuong trinh bac nhat Ax + B = 0

ALTER PROC GiaiPhuongTrinhBacNhat
@A FLOAT, @B FLOAT, @KetQua NVARCHAR(100) OUT
AS
BEGIN
	DECLARE @x FLOAT
	IF @A = 0
		BEGIN
			IF @B = 0
				SELECT N'Phương trình có vô số nghiệm' AS KetQua
			ELSE
				SELECT N'Phương trình vô nghiệm' AS KetQua
		END
	ELSE
		BEGIN
			SET @x = -@B / @A
			SELECT N'Nghiệm của phương trình là x = ' + CAST(@x AS NVARCHAR(50)) AS KetQua
		END
END
go

declare @KQ nvarchar(100)
EXEC GiaiPhuongTrinhBacNhat -3, 6, @KQ out
print @KQ
go