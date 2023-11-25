-- Câu 4
-- Mức 1:
CREATE PROC DuAnChuaCoNVThamGiaMuc1
AS
BEGIN
	SELECT *
	FROM dbo.DuAn
	WHERE MaDA NOT IN (SELECT MaDA FROM dbo.PhanCong)
END
GO

EXEC DuAnChuaCoNVThamGiaMuc1
GO
-- Mức 2:
CREATE PROC DuAnChuaCoNVThamGiaMuc2
AS
BEGIN
	SELECT *
	FROM dbo.DA1
	WHERE MaDA NOT IN (SELECT MaDA FROM dbo.PhanCong)
	UNION
	SELECT *
	FROM dbo.DA2
	WHERE MaDA NOT IN (SELECT MaDA FROM dbo.PhanCong)
END
GO

EXEC DuAnChuaCoNVThamGiaMuc2
GO

-- Câu 5
-- Mức 1:
CREATE PROC HienThiTenNQLDuAnMuc1
@MaDA nchar(5)
AS
BEGIN
	SELECT (Ho + ' ' + Ten) AS HoTenNQL
	FROM dbo.DuAn d JOIN dbo.NguoiQuanLy ql ON d.MaNQL = ql.MaNQL
	WHERE d.MaDA = @MaDA
END
GO

EXEC HienThiTenNQLDuAnMuc1 'DA002'
GO
-- Mức 2:
CREATE PROC HienThiTenNQLDuAnMuc2
@MaDA nchar(5)
AS
BEGIN
	IF (@MaDA IN (SELECT MaDA FROM dbo.DA1)
		SELECT (Ho + ' ' + Ten) AS HoTenNQL
		FROM dbo.NQL1
		WHERE d.MaDA = @MaDA
END
GO

EXEC HienThiTenNQLDuAnMuc2 'DA002'
GO

-- Câu 6
-- Mức 1:

-- Mức 2:


-- Câu 7
-- Mức 1:

-- Mức 2:


-- Câu 8
-- Mức 1:

-- Mức 2:


-- Câu 9
-- Mức 1:

-- Mức 2:


-- Câu 10
BACKUP DATABASE QLDA
TO DISK = N'D:\QLDA.bak'

SELECT * FROM PC1
UNION
SELECT * FROM PC2

SELECT * FROM PhanCong