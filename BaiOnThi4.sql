USE QLTruongDH
GO

-- Câu 1: Tạo phân mảnh dọc cho Khoa
CREATE PROC TaoPM_Doc_Khoa
AS
BEGIN
	SELECT [MaKhoa], [TenKhoa] INTO Khoa_Doc1
	FROM dbo.Khoa

	SELECT [MaKhoa], [CoSo] INTO Khoa_Doc2
	FROM dbo.Khoa
END
GO

EXEC TaoPM_Doc_Khoa
GO

-- Câu 2: Tạo proc xem từ 2 phân mảnh dọc
CREATE PROC XemKhoa_Doc
@CoSo nvarchar(50)
AS
BEGIN
	IF (@CoSo IS NULL)
		BEGIN
			SELECT k1.MaKhoa, k1.TenKhoa, k2.CoSo
			FROM dbo.Khoa_Doc1 k1 JOIN dbo.Khoa_Doc2 k2 ON k1.MaKhoa = k2.MaKhoa
		END
	ELSE IF (@CoSo NOT IN (N'Sài Gòn', N'Bình Dương'))
		PRINT N'Cơ sở không hợp lệ! (Cơ sở chỉ có thể là Sài Gòn hoặc Bình Dương)'
	ELSE
		BEGIN
			PRINT N'Danh sách các khoa có cơ sở ở ' + @CoSo + N' là:'
			SELECT k1.MaKhoa, k1.TenKhoa, k2.CoSo
			FROM dbo.Khoa_Doc1 k1 JOIN dbo.Khoa_Doc2 k2 ON k1.MaKhoa = k2.MaKhoa
			WHERE k2.CoSo = @CoSo
		END
END
GO

-- Test proc
EXEC XemKhoa_Doc NULL
EXEC XemKhoa_Doc N'Hà Nội'
EXEC XemKhoa_Doc N'Sài Gòn'
EXEC XemKhoa_Doc N'Bình Dương'
GO

-- Câu 3: Thêm khoa dọc
CREATE PROC ThemKhoa_Doc 
@MaKhoa nvarchar(10), @TenKhoa nvarchar(50), @CoSo nvarchar(50)
AS
BEGIN
	IF (@MaKhoa IS NULL)
		PRINT N'Không thể thêm do không có giá trị mã khoa!'
	ELSE IF (@TenKhoa IS NULL)
		PRINT N'Không thể thêm do không có giá trị tên khoa!'
	ELSE IF (@CoSo IS NULL)
		PRINT N'Không thể thêm do không có giá trị cơ sở!'
	ELSE IF (@CoSo NOT IN (N'Sài Gòn', N'Bình Dương'))
		PRINT N'Không thể thêm do giá trị cơ sở không hợp lệ! (Chỉ có thể là "Sài Gòn" và "Bình Dương")'
	ELSE IF EXISTS (SELECT * FROM dbo.Khoa_Doc1 WHERE MaKhoa = @MaKhoa)
		PRINT N'Không thể thêm do bị trùng mã khoa!'
	ELSE
		BEGIN
			INSERT INTO dbo.Khoa_Doc1 VALUES (@MaKhoa, @TenKhoa)
			INSERT INTO dbo.Khoa_Doc2 VALUES (@MaKhoa, @CoSo)
			PRINT N'Thêm dữ liệu thành công!'
		END
END
GO

-- Test proc
EXEC ThemKhoa_Doc NULL, N'Xã - Công - Đông', N'Sài Gòn' -- null mã
EXEC ThemKhoa_Doc N'XCD', NULL, N'Sài Gòn' -- null tên
EXEC ThemKhoa_Doc N'XCD', N'Xã - Công - Đông', NULL -- null cơ sở
EXEC ThemKhoa_Doc N'XCD', N'Xã - Công - Đông', N'Đà Nẵng' -- cơ sở k hợp lệ
EXEC ThemKhoa_Doc N'CNTT', N'Công nghệ thông tin', N'Sài Gòn' -- trùng mã
EXEC ThemKhoa_Doc N'XCD', N'Xã - Công - Đông', N'Sài Gòn' -- thêm được
EXEC ThemKhoa_Doc N'CNTP', N'Công nghệ thực phẩm', N'Bình Dương' -- thêm được

-- Xóa các hàng vừa thêm
DELETE FROM dbo.Khoa_Doc1 WHERE MaKhoa = N'XCD'
DELETE FROM dbo.Khoa_Doc2 WHERE MaKhoa = N'XCD'
DELETE FROM dbo.Khoa_Doc1 WHERE MaKhoa = N'CNTP'
DELETE FROM dbo.Khoa_Doc2 WHERE MaKhoa = N'CNTP'
GO

-- Câu 4:
-- Phân mảnh ngang chính Khoa
CREATE PROC TaoPM_Ngang_Khoa
AS
BEGIN
	SELECT * INTO Khoa_Ngang1
	FROM dbo.Khoa
	WHERE CoSo = N'Sài Gòn'

	SELECT * INTO Khoa_Ngang2
	FROM dbo.Khoa
	WHERE CoSo = N'Bình Dương'
END
GO

EXEC TaoPM_Ngang_Khoa
GO

-- Phân mảnh ngang dẫn xuất Lớp theo Khoa
CREATE PROC TaoPM_Ngang_Lop
AS
BEGIN
	SELECT * INTO Lop_Ngang1
	FROM dbo.Lop
	WHERE MaKhoa IN (SELECT MaKhoa FROM dbo.Khoa_Ngang1)

	SELECT * INTO Lop_Ngang2
	FROM dbo.Lop
	WHERE MaKhoa IN (SELECT MaKhoa FROM dbo.Khoa_Ngang2)
END
GO

EXEC TaoPM_Ngang_Lop
GO

-- Câu 5: Xem khoa ngang
CREATE PROC XemKhoa_Ngang
@CoSo nvarchar(50)
AS
BEGIN
	IF (@CoSo IS NULL)
		BEGIN
			SELECT * FROM dbo.Khoa_Ngang1
			UNION
			SELECT * FROM dbo.Khoa_Ngang2
		END
	ELSE IF (@CoSo NOT IN (N'Sài Gòn', N'Bình Dương'))
		PRINT N'Cơ sở không hợp lệ! (Cơ sở chỉ có thể là Sài Gòn hoặc Bình Dương)'
	ELSE
		BEGIN
			PRINT N'Danh sách các khoa có cơ sở ở ' + @CoSo + N' là:'
			SELECT * FROM dbo.Khoa_Ngang1 WHERE CoSo = @CoSo
			UNION
			SELECT * FROM dbo.Khoa_Ngang2 WHERE CoSo = @CoSo
		END
END
GO

-- Test proc
EXEC XemKhoa_Ngang NULL
EXEC XemKhoa_Ngang N'Hà Nội'
EXEC XemKhoa_Ngang N'Sài Gòn'
EXEC XemKhoa_Ngang N'Bình Dương'
GO

-- Câu 6: Sửa khoa ngang
CREATE PROC SuaKhoa_Ngang
@MaKhoa nvarchar(10), @TenKhoa nvarchar(50), @CoSo nvarchar(50)
AS
BEGIN
	IF (@MaKhoa IS NULL)
		PRINT N'Không thể sửa do không có giá trị mã khoa!'
	ELSE IF (@TenKhoa IS NULL)
		PRINT N'Không thể sửa do không có giá trị tên khoa!'
	ELSE IF (@CoSo IS NULL)
		PRINT N'Không thể sửa do không có giá trị cơ sở!'
	ELSE IF (@CoSo NOT IN (N'Sài Gòn', N'Bình Dương'))
		PRINT N'Không thể sửa do giá trị cơ sở không hợp lệ! (Chỉ có thể là "Sài Gòn" và "Bình Dương")'
	ELSE IF NOT EXISTS (SELECT * FROM dbo.Khoa_Ngang1 WHERE MaKhoa = @MaKhoa) AND NOT EXISTS (SELECT * FROM dbo.Khoa_Ngang2 WHERE MaKhoa = @MaKhoa)
		PRINT N'Không thể sửa do không tìm thấy mã khoa!'
	ELSE IF EXISTS (SELECT * FROM dbo.Khoa_Ngang1 WHERE MaKhoa = @MaKhoa)
		BEGIN
			UPDATE dbo.Khoa_Ngang1
			SET TenKhoa = @TenKhoa, CoSo = @CoSo
			WHERE MaKhoa = @MaKhoa
			PRINT N'Thành công sửa dữ liệu của khoa có mã ' + @MaKhoa + N' sang ' + @TenKhoa + N' và ' + @CoSo + N'!'
			IF (@CoSo = N'Bình Dương')
				BEGIN
					INSERT INTO Khoa_Ngang2
					SELECT * FROM dbo.Khoa_Ngang1 WHERE MaKhoa = @MaKhoa
					DELETE FROM dbo.Khoa_Ngang1 WHERE MaKhoa = @MaKhoa

					INSERT INTO Lop_Ngang2
					SELECT * FROM dbo.Lop_Ngang1 WHERE MaKhoa = @MaKhoa
					DELETE FROM dbo.Lop_Ngang1 WHERE MaKhoa = @MaKhoa

					PRINT N'Thành công sửa dữ liệu của khoa có mã ' + @MaKhoa + N' từ phân mảnh Sài Gòn sang phân mảnh Bình Dương!'
				END
			ELSE
				PRINT N'Không có sự thay đổi phân mảnh!'
		END
	ELSE
		BEGIN
			UPDATE dbo.Khoa_Ngang2
			SET TenKhoa = @TenKhoa, CoSo = @CoSo
			WHERE MaKhoa = @MaKhoa
			PRINT N'Thành công sửa dữ liệu của khoa có mã ' + @MaKhoa + N' sang ' + @TenKhoa + N' và ' + @CoSo + N'!'
			IF (@CoSo = N'Sài Gòn')
				BEGIN
					INSERT INTO Khoa_Ngang1
					SELECT * FROM dbo.Khoa_Ngang2 WHERE MaKhoa = @MaKhoa
					DELETE FROM dbo.Khoa_Ngang2 WHERE MaKhoa = @MaKhoa

					INSERT INTO Lop_Ngang1
					SELECT * FROM dbo.Lop_Ngang2 WHERE MaKhoa = @MaKhoa
					DELETE FROM dbo.Lop_Ngang2 WHERE MaKhoa = @MaKhoa

					PRINT N'Thành công sửa dữ liệu của khoa có mã ' + @MaKhoa + N' từ phân mảnh Bình Dương sang phân mảnh Sài Gòn!'
				END
			ELSE
				PRINT N'Không có sự thay đổi phân mảnh!'
		END
END
GO

-- Test proc
EXEC SuaKhoa_Ngang NULL, N'Xã - Công - Đông', N'Sài Gòn' -- null mã
EXEC SuaKhoa_Ngang N'XCD', NULL, N'Sài Gòn' -- null tên
EXEC SuaKhoa_Ngang N'XCD', N'Xã - Công - Đông', NULL -- null cơ sở
EXEC SuaKhoa_Ngang N'XCD', N'Xã - Công - Đông', N'Đà Nẵng' -- cơ sở k hợp lệ
EXEC SuaKhoa_Ngang N'XCD', N'Xã - Công - Đông', N'Sài Gòn' -- k tìm thấy mã
EXEC SuaKhoa_Ngang N'CNTT', N'Khoa học máy tính', N'Sài Gòn' -- sửa không đổi cơ sở
EXEC SuaKhoa_Ngang N'KTXD', N'Kiến trúc xây dựng', N'Bình Dương' -- sửa có đổi cơ sở SG -> BD
EXEC SuaKhoa_Ngang N'QTKD', N'Logistics', N'Sài Gòn' -- sửa có đổi cơ sở BD -> SG

-- Sửa lại các hàng vừa sửa
EXEC SuaKhoa_Ngang N'CNTT', N'Công nghệ thông tin', N'Sài Gòn'
EXEC SuaKhoa_Ngang N'KTXD', N'Kỹ thuật xây dựng', N'Sài Gòn'
EXEC SuaKhoa_Ngang N'QTKD', N'Quản trị kinh doanh', N'Bình Dương'
GO