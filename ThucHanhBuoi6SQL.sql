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
	WHERE MaDA NOT IN (SELECT MaDA FROM dbo.PC1 UNION SELECT MaDA FROM dbo.PC2)
	UNION
	SELECT *
	FROM dbo.DA2
	WHERE MaDA NOT IN (SELECT MaDA FROM dbo.PC1 UNION SELECT MaDA FROM dbo.PC2)
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
	IF @MaDA IN (SELECT MaDA FROM dbo.DA1)
	BEGIN
		SELECT (Ho + ' ' + Ten) AS HoTenNQL
		FROM dbo.DA1 d JOIN dbo.NQL1 ql ON d.MaNQL = ql.MaNQL
		WHERE MaDA = @MaDA
	END
	ELSE
	BEGIN
		SELECT (Ho + ' ' + Ten) AS HoTenNQL
		FROM dbo.DA2 d JOIN dbo.NQL2 ql ON d.MaNQL = ql.MaNQL
		WHERE MaDA = @MaDA
	END	
END
GO

EXEC HienThiTenNQLDuAnMuc2 'DA006'
GO

-- Câu 6
-- Mức 1:
CREATE PROC SLNhanVienThamGiaDuAnMuc1
AS
BEGIN
	SELECT d.TenDA, COUNT(p.MaNV) AS SLNhanVien
	FROM dbo.DuAn d JOIN dbo.PhanCong p ON d.MaDA = p.MaDA
	GROUP BY d.TenDA
END
GO

EXEC SLNhanVienThamGiaDuAnMuc1
GO

-- Mức 2:
CREATE PROC SLNhanVienThamGiaDuAnMuc2
AS
BEGIN
	IF EXISTS(
			SELECT *
			FROM sys.tables
			JOIN sys.schemas
			ON sys.tables.schema_id = sys.schemas.schema_id
			WHERE sys.schemas.name = 'dbo' AND sys.tables.name = 'TAM1')
		DROP TABLE QLDA.dbo.TAM1

	IF EXISTS(
			SELECT *
			FROM sys.tables
			JOIN sys.schemas
			ON sys.tables.schema_id = sys.schemas.schema_id
			WHERE sys.schemas.name = 'dbo' AND sys.tables.name = 'TAM2')
		DROP TABLE QLDA.dbo.TAM2
	
	SELECT * INTO QLDA.dbo.TAM1 FROM QLDA.dbo.PC1
	INSERT INTO QLDA.dbo.TAM1 SELECT * FROM QLDA.dbo.PC2

	SELECT * INTO QLDA.dbo.TAM2 FROM QLDA.dbo.DA1
	INSERT INTO QLDA.dbo.TAM2 SELECT * FROM QLDA.dbo.DA2

	SELECT d.TenDA, COUNT(p.MaNV) AS SLNhanVien
	FROM dbo.TAM2 d JOIN dbo.TAM1 p ON d.MaDA = p.MaDA
	GROUP BY d.TenDA

	DROP TABLE QLDA.dbo.TAM1
	DROP TABLE QLDA.dbo.TAM2
END
GO

EXEC SLNhanVienThamGiaDuAnMuc2
GO

-- Câu 7
-- Mức 1:
CREATE PROC ThemNguoiQuanLyMuc1
@MaNQL int, @Ho nvarchar(20), @Ten nvarchar(50), @TenPhong nvarchar(10)
AS
BEGIN
	INSERT INTO dbo.NguoiQuanLy VALUES (@MaNQL, @Ho, @Ten, @TenPhong)
END
GO

EXEC ThemNguoiQuanLyMuc1 100, 'Tran Van', 'Hung', 'P1'
GO
EXEC ThemNguoiQuanLyMuc1 200, 'Le Thi', 'Hong', 'P2'
GO

-- Mức 2:
CREATE PROC ThemNguoiQuanLyMuc2
@MaNQL int, @Ho nvarchar(20), @Ten nvarchar(50), @TenPhong nvarchar(10)
AS
BEGIN
	IF @TenPhong = 'P1'
		INSERT INTO dbo.NQL1 VALUES (@MaNQL, @Ho, @Ten, @TenPhong)
	ELSE
		INSERT INTO dbo.NQL2 VALUES (@MaNQL, @Ho, @Ten, @TenPhong)
END
GO

EXEC ThemNguoiQuanLyMuc2 100, 'Tran Van', 'Hung', 'P1'
GO
EXEC ThemNguoiQuanLyMuc2 200, 'Le Thi', 'Hong', 'P2'
GO

-- Câu 8
-- Mức 1:
CREATE PROC SuaNguoiQuanLyMuc1
@MaNQL int, @Ho nvarchar(20), @Ten nvarchar(50), @TenPhong nvarchar(10)
AS
BEGIN
	UPDATE dbo.NguoiQuanLy
	SET Ho = @Ho, Ten = @Ten, TenPhong = @TenPhong
	WHERE MaNQL = @MaNQL
END
GO

EXEC SuaNguoiQuanLyMuc1 100, 'Ho Thanh', 'Tung', 'P2'
GO
EXEC SuaNguoiQuanLyMuc1 200, 'Tran Thi', 'Diep', 'P1'
GO

-- Mức 2:
-- Hiện đang bị lỗi chỗ chuyển dữ liệu bảng Nhân viên và Phân công, xem lại sau
-- Lỗi từ đây...
CREATE PROC SuaNguoiQuanLyMuc2
@MaNQL int, @Ho nvarchar(20), @Ten nvarchar(50), @TenPhong nvarchar(10)
AS
BEGIN
	IF EXISTS (SELECT MaNQL FROM dbo.NQL1 WHERE MaNQL = @MaNQL)
		BEGIN
		UPDATE dbo.NQL1
		SET Ho = @Ho, Ten = @Ten, TenPhong = @TenPhong
		WHERE MaNQL = @MaNQL
		IF @TenPhong <> 'P1'
			BEGIN
				INSERT INTO dbo.NQL2
				SELECT * FROM dbo.NQL1 WHERE MaNQL = @MaNQL
				DELETE FROM dbo.NQL1 WHERE MaNQL = @MaNQL

				INSERT INTO dbo.DA2
				SELECT * FROM dbo.DA1 WHERE MaNQL = @MaNQL
				DELETE FROM dbo.DA1 WHERE MaNQL = @MaNQL

				INSERT INTO dbo.BP2
				SELECT * FROM dbo.BP1 WHERE MaNQL = @MaNQL
				DELETE FROM dbo.BP1 WHERE MaNQL = @MaNQL

				INSERT INTO dbo.NV2
				SELECT * FROM dbo.NV1 WHERE MaBP IN (SELECT MaBP FROM dbo.BP1 WHERE MaNQL = @MaNQL)
				DELETE FROM dbo.NV1 WHERE MaBP IN (SELECT MaBP FROM dbo.BP1 WHERE MaNQL = @MaNQL)

				INSERT INTO dbo.PC2
				SELECT * FROM dbo.PC1 WHERE MaNV IN (SELECT MaNV FROM dbo.NV1)
				DELETE FROM dbo.PC1 WHERE MaNV IN (SELECT MaNV FROM dbo.NV1)
			END
		END
	ELSE
		BEGIN
		UPDATE dbo.NQL2
		SET Ho = @Ho, Ten = @Ten, TenPhong = @TenPhong
		WHERE MaNQL = @MaNQL
		IF @TenPhong = 'P1'
			BEGIN
				INSERT INTO dbo.NQL1
				SELECT * FROM dbo.NQL2 WHERE MaNQL = @MaNQL
				DELETE FROM dbo.NQL2 WHERE MaNQL = @MaNQL

				INSERT INTO dbo.DA1
				SELECT * FROM dbo.DA2 WHERE MaNQL = @MaNQL
				DELETE FROM dbo.DA2 WHERE MaNQL = @MaNQL

				INSERT INTO dbo.BP1
				SELECT * FROM dbo.BP2 WHERE MaNQL = @MaNQL
				DELETE FROM dbo.BP2 WHERE MaNQL = @MaNQL

				INSERT INTO dbo.NV1
				SELECT * FROM dbo.NV2 WHERE MaBP IN (SELECT MaBP FROM dbo.BP2 WHERE MaNQL = @MaNQL)
				DELETE FROM dbo.NV2 WHERE MaBP IN (SELECT MaBP FROM dbo.BP2 WHERE MaNQL = @MaNQL)

				INSERT INTO dbo.PC1
				SELECT * FROM dbo.PC2 WHERE MaNV IN (SELECT MaNV FROM dbo.NV2)
				DELETE FROM dbo.PC2 WHERE MaNV IN (SELECT MaNV FROM dbo.NV2)
			END
		END
END
GO

SELECT * FROM NQL1
SELECT * FROM DA1
SELECT * FROM BP1
SELECT * FROM NV1
SELECT * FROM PC1

SELECT * FROM NQL2
SELECT * FROM DA2
SELECT * FROM BP2
SELECT * FROM NV2
SELECT * FROM PC2

EXEC SuaNguoiQuanLyMuc2 100, 'Ho Thanh', 'Tung', 'P2'
GO
EXEC SuaNguoiQuanLyMuc2 200, 'Tran Thi', 'Diep', 'P1'
GO
EXEC SuaNguoiQuanLyMuc2 105, 'Ho Thanh', 'Tung', 'P1'
GO
-- ...đến đây, đừng copy

-- Câu 9
-- Mức 1:
CREATE PROC XoaNguoiQuanLyMuc1
@MaNQL int
AS
BEGIN
	DELETE FROM dbo.NguoiQuanLy WHERE MaNQL = @MaNQL
END
GO

EXEC XoaNguoiQuanLyMuc1 100
GO
EXEC XoaNguoiQuanLyMuc1 200
GO

-- Mức 2:
CREATE PROC XoaNguoiQuanLyMuc2
@MaNQL int
AS
BEGIN
	IF EXISTS (SELECT MaNQL FROM dbo.NQL1 WHERE MaNQL = @MaNQL)
		DELETE FROM dbo.NQL1 WHERE MaNQL = @MaNQL
	ELSE
		DELETE FROM dbo.NQL2 WHERE MaNQL = @MaNQL
	
END
GO

EXEC XoaNguoiQuanLyMuc2 100
GO
EXEC XoaNguoiQuanLyMuc2 200
GO

-- Câu 10
BACKUP DATABASE QLDA
TO DISK = N'D:\QLDA.bak'
