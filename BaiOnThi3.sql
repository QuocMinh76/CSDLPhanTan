USE QLSach
GO

-- Câu 1: Tạo phân mảnh ngang NXB theo loại hình và phân mảnh ngang dẫn xuất Sach theo NXB
-- Phân mảnh ngang NXB
CREATE PROC TaoPhanManhNXB
AS
BEGIN
	SELECT * INTO NXB1
	FROM dbo.NhaXuatBan
	WHERE LoaiHinh = N'Tư nhân'

	SELECT * INTO NXB2
	FROM dbo.NhaXuatBan
	WHERE LoaiHinh = N'Nhà nước'
END
GO

EXEC TaoPhanManhNXB
GO
-- Phân mảnh ngang dẫn xuất Sach theo NXB
CREATE PROC TaoPhanManhSach
AS
BEGIN
	SELECT * INTO Sach1
	FROM dbo.Sach
	WHERE MaNXB IN (SELECT MaNXB FROM dbo.NXB1)

	SELECT * INTO Sach2
	FROM dbo.Sach
	WHERE MaNXB IN (SELECT MaNXB FROM dbo.NXB2)
END
GO

EXEC TaoPhanManhSach
GO

-- Câu 2: Xem ds sách theo tên nxb
-- Mức 1:
CREATE PROC DSSachMuc1
@TenNXB nvarchar(50)
AS
BEGIN
	IF (@TenNXB IS NULL)
		PRINT N'Không nhập tên nhà xuất bản!'
	ELSE IF (@TenNXB NOT IN (SELECT TenNXB FROM dbo.NhaXuatBan))
		PRINT N'Không tìm thấy tên nhà xuất bản trong CSDL!'
	ELSE
		BEGIN
			SELECT s.*, n.TenNXB
			FROM dbo.NhaXuatBan n JOIN dbo.Sach s ON n.MaNXB = s.MaNXB
			WHERE TenNXB = @TenNXB
		END
END
GO

-- Test proc
EXEC DSSachMuc1 NULL -- null
EXEC DSSachMuc1 N'Tuổi hoa' -- k có
EXEC DSSachMuc1 N'Sự thật' -- có
EXEC DSSachMuc1 N'Mỹ thuật' -- có
GO

-- Mức 2:
CREATE PROC DSSachMuc2
@TenNXB nvarchar(50)
AS
BEGIN
	IF (@TenNXB IS NULL)
		PRINT N'Không nhập tên nhà xuất bản!'
	ELSE IF (@TenNXB NOT IN (SELECT TenNXB FROM dbo.NhaXuatBan))
		PRINT N'Không tìm thấy tên nhà xuất bản trong CSDL!'
	ELSE
		BEGIN
			SELECT s.*, n.TenNXB
			FROM dbo.NXB1 n JOIN dbo.Sach1 s ON n.MaNXB = s.MaNXB
			WHERE TenNXB = @TenNXB
			UNION
			SELECT s.*, n.TenNXB
			FROM dbo.NXB2 n JOIN dbo.Sach2 s ON n.MaNXB = s.MaNXB
			WHERE TenNXB = @TenNXB
		END
END
GO

-- Test proc
EXEC DSSachMuc2 NULL -- null
EXEC DSSachMuc2 N'Tuổi hoa' -- k có
EXEC DSSachMuc2 N'Sự thật' -- có
EXEC DSSachMuc2 N'Mỹ thuật' -- có
GO

-- Câu 3: Thêm nhà xuất bản
-- Mức 1:
CREATE PROC ThemNXBMuc1
@MaNXB nvarchar(10), @TenNXB nvarchar(50), @LoaiHinh nvarchar(50)
AS
BEGIN
	IF (@MaNXB IS NULL)
		PRINT N'Không thể thêm do không có giá trị mã nhà xuất bản!'
	ELSE IF (@TenNXB IS NULL)
		PRINT N'Không thể thêm do không có giá trị tên nhà xuất bản!'
	ELSE IF (@LoaiHinh IS NULL)
		PRINT N'Không thể thêm do không có giá trị loại hình!'
	ELSE IF (@LoaiHinh NOT IN (N'Tư nhân', N'Nhà nước'))
		PRINT N'Không thể thêm do giá trị loại hình không hợp lệ!'
	ELSE IF EXISTS (SELECT * FROM dbo.NhaXuatBan WHERE MaNXB = @MaNXB)
		PRINT N'Không thể thêm do bị trùng mã nhà xuất bản!'
	ELSE
		BEGIN
			INSERT INTO dbo.NhaXuatBan VALUES (@MaNXB, @TenNXB, @LoaiHinh)
			PRINT N'Thêm dữ liệu thành công!'
		END
END
GO

-- Test proc
EXEC ThemNXBMuc1 NULL, N'Tương lai', N'Tư nhân' -- null mã
EXEC ThemNXBMuc1 N'NXB20', NULL, N'Tư nhân' -- null tên
EXEC ThemNXBMuc1 N'NXB20', N'Tương lai', NULL -- null loại
EXEC ThemNXBMuc1 N'NXB10', N'Tương lai', N'Tư nhân' -- thêm được
EXEC ThemNXBMuc1 N'NXB11', N'Giáo dục', N'Nhà nước' -- thêm được
EXEC ThemNXBMuc1 N'NXB5', N'Thiếu niên', N'Nhà nước' -- trùng mã
EXEC ThemNXBMuc1 N'NXB6', N'Thanh niên', N'Nhà nước' -- trùng mã
GO

-- Xóa các hàng đã thêm
DELETE FROM dbo.NhaXuatBan WHERE MaNXB = 'NXB10'
DELETE FROM dbo.NhaXuatBan WHERE MaNXB = 'NXB11'
GO

-- Mức 2:
CREATE PROC ThemNXBMuc2
@MaNXB nvarchar(10), @TenNXB nvarchar(50), @LoaiHinh nvarchar(50)
AS
BEGIN
	IF (@MaNXB IS NULL)
		PRINT N'Không thể thêm do không có giá trị mã nhà xuất bản!'
	ELSE IF (@TenNXB IS NULL)
		PRINT N'Không thể thêm do không có giá trị tên nhà xuất bản!'
	ELSE IF (@LoaiHinh IS NULL)
		PRINT N'Không thể thêm do không có giá trị loại hình!'
	ELSE IF (@LoaiHinh NOT IN (N'Tư nhân', N'Nhà nước'))
		PRINT N'Không thể thêm do giá trị loại hình không hợp lệ!'
	ELSE IF EXISTS (SELECT * FROM dbo.NXB1 WHERE MaNXB = @MaNXB) OR EXISTS (SELECT * FROM dbo.NXB2 WHERE MaNXB = @MaNXB)
		PRINT N'Không thể thêm do bị trùng mã nhà xuất bản!'
	ELSE IF (@LoaiHinh = N'Tư nhân')
		BEGIN
			INSERT INTO dbo.NXB1 VALUES (@MaNXB, @TenNXB, @LoaiHinh)
			PRINT N'Thêm dữ liệu thành công!'
		END
	ELSE
		BEGIN
			INSERT INTO dbo.NXB2 VALUES (@MaNXB, @TenNXB, @LoaiHinh)
			PRINT N'Thêm dữ liệu thành công!'
		END
END
GO

-- Test proc
EXEC ThemNXBMuc2 NULL, N'Tương lai', N'Tư nhân' -- null mã
EXEC ThemNXBMuc2 N'NXB20', NULL, N'Tư nhân' -- null tên
EXEC ThemNXBMuc2 N'NXB20', N'Tương lai', NULL -- null loại
EXEC ThemNXBMuc2 N'NXB10', N'Tương lai', N'Tư nhân' -- thêm được
EXEC ThemNXBMuc2 N'NXB11', N'Giáo dục', N'Nhà nước' -- thêm được
EXEC ThemNXBMuc2 N'NXB5', N'Thiếu niên', N'Nhà nước' -- trùng mã
EXEC ThemNXBMuc2 N'NXB6', N'Thanh niên', N'Nhà nước' -- trùng mã
GO

-- Xóa các hàng đã thêm
DELETE FROM dbo.NXB1 WHERE MaNXB = 'NXB10'
DELETE FROM dbo.NXB2 WHERE MaNXB = 'NXB11'
GO

-- Câu 4: Sửa nhà xuất bản
-- Mức 1:
CREATE PROC SuaNXBMuc1
@MaNXB nvarchar(10), @TenNXB nvarchar(50), @LoaiHinh nvarchar(50)
AS
BEGIN
	IF (@MaNXB IS NULL)
		PRINT N'Không thể sửa do không có giá trị mã nhà xuất bản!'
	ELSE IF (@TenNXB IS NULL)
		PRINT N'Không thể sửa do không có giá trị tên nhà xuất bản!'
	ELSE IF (@LoaiHinh IS NULL)
		PRINT N'Không thể sửa do không có giá trị loại hình!'
	ELSE IF (@LoaiHinh NOT IN (N'Tư nhân', N'Nhà nước'))
		PRINT N'Không thể sửa do giá trị loại hình không hợp lệ!'
	ELSE IF NOT EXISTS (SELECT * FROM dbo.NhaXuatBan WHERE MaNXB = @MaNXB)
		PRINT N'Không thể sửa do không tìm thấy mã nhà xuất bản trong CSDL!'
	ELSE
		BEGIN
			UPDATE dbo.NhaXuatBan
			SET TenNXB = @TenNXB, LoaiHinh = @LoaiHinh
			WHERE MaNXB = @MaNXB
			PRINT N'Thành công sửa dữ liệu của nhà xuất bản có mã ' + @MaNXB + N' sang ' + @TenNXB + N' và ' + @LoaiHinh + N'!'
		END
END
GO

-- Test proc
EXEC SuaNXBMuc1 NULL, N'Sáng tạo mới', N'Tư nhân' -- null mã
EXEC SuaNXBMuc1 N'NXB123', N'Kỹ thuật', N'Tư nhân' -- k tìm thấy mã
EXEC SuaNXBMuc1 N'NXB1', N'Kỹ thuật', NULL -- null loại
EXEC SuaNXBMuc1 N'NXB1', N'Kỹ thuật', N'Nhập khẩu' -- loại k đúng
EXEC SuaNXBMuc1 N'NXB1', N'Sáng tạo mới', N'Tư nhân' -- sửa k đổi loại
EXEC SuaNXBMuc1 N'NXB3', N'Thành công', N'Nhà nước' -- sửa có đổi loại TN -> NN
EXEC SuaNXBMuc1 N'NXB6', N'Đất Việt', N'Tư nhân' -- sửa có đổi loại NN -> TN
GO

-- Sửa lại các hàng đã sửa ở trên
EXEC SuaNXBMuc1 N'NXB1', N'Sáng tạo', N'Tư nhân'
EXEC SuaNXBMuc1 N'NXB3', N'Tinh tế', N'Tư nhân'
EXEC SuaNXBMuc1 N'NXB6', N'Dân tộc', N'Nhà nước'
GO

-- Mức 2:
CREATE PROC SuaNXBMuc2
@MaNXB nvarchar(10), @TenNXB nvarchar(50), @LoaiHinh nvarchar(50)
AS
BEGIN
	IF (@MaNXB IS NULL)
		PRINT N'Không thể sửa do không có giá trị mã nhà xuất bản!'
	ELSE IF (@TenNXB IS NULL)
		PRINT N'Không thể sửa do không có giá trị tên nhà xuất bản!'
	ELSE IF (@LoaiHinh IS NULL)
		PRINT N'Không thể sửa do không có giá trị loại hình!'
	ELSE IF (@LoaiHinh NOT IN (N'Tư nhân', N'Nhà nước'))
		PRINT N'Không thể sửa do giá trị loại hình không hợp lệ!'
	ELSE IF NOT EXISTS (SELECT * FROM dbo.NXB1 WHERE MaNXB = @MaNXB) AND NOT EXISTS (SELECT * FROM dbo.NXB2 WHERE MaNXB = @MaNXB)
		PRINT N'Không thể sửa do không tìm thấy mã nhà xuất bản trong CSDL!'
	ELSE IF EXISTS (SELECT * FROM dbo.NXB1 WHERE MaNXB = @MaNXB)
		BEGIN
			UPDATE dbo.NXB1
			SET TenNXB = @TenNXB, LoaiHinh = @LoaiHinh
			WHERE MaNXB = @MaNXB
			PRINT N'Thành công sửa dữ liệu của nhà xuất bản có mã ' + @MaNXB + N' sang ' + @TenNXB + N' và ' + @LoaiHinh + N'!'
			IF (@LoaiHinh = N'Nhà nước')
				BEGIN
					INSERT INTO dbo.NXB2
					SELECT * FROM dbo.NXB1 WHERE MaNXB = @MaNXB
					DELETE FROM dbo.NXB1 WHERE MaNXB = @MaNXB

					INSERT INTO dbo.Sach2
					SELECT * FROM dbo.Sach1 WHERE MaNXB = @MaNXB
					DELETE FROM dbo.Sach1 WHERE MaNXB = @MaNXB

					PRINT N'Thành công sửa dữ liệu của nhà xuất bản có mã ' + @MaNXB + N' từ phân mảnh Tư nhân sang phân mảnh Nhà nước!'
				END
			ELSE
				PRINT N'Không có sự thay đổi phân mảnh!'
		END
	ELSE
		BEGIN
			UPDATE dbo.NXB2
			SET TenNXB = @TenNXB, LoaiHinh = @LoaiHinh
			WHERE MaNXB = @MaNXB
			PRINT N'Thành công sửa dữ liệu của nhà xuất bản có mã ' + @MaNXB + N' sang ' + @TenNXB + N' và ' + @LoaiHinh + N'!'
			IF (@LoaiHinh = N'Tư nhân')
				BEGIN
					INSERT INTO dbo.NXB1
					SELECT * FROM dbo.NXB2 WHERE MaNXB = @MaNXB
					DELETE FROM dbo.NXB2 WHERE MaNXB = @MaNXB

					INSERT INTO dbo.Sach1
					SELECT * FROM dbo.Sach2 WHERE MaNXB = @MaNXB
					DELETE FROM dbo.Sach2 WHERE MaNXB = @MaNXB

					PRINT N'Thành công sửa dữ liệu của nhà xuất bản có mã ' + @MaNXB + N' từ phân mảnh Nhà nước sang phân mảnh Tư nhân!'
				END
			ELSE
				PRINT N'Không có sự thay đổi phân mảnh!'
		END
END
GO

-- Test proc
EXEC SuaNXBMuc2 NULL, N'Sáng tạo mới', N'Tư nhân' -- null mã
EXEC SuaNXBMuc2 N'NXB123', N'Kỹ thuật', N'Tư nhân' -- k tìm thấy mã
EXEC SuaNXBMuc2 N'NXB1', N'Kỹ thuật', NULL -- null loại
EXEC SuaNXBMuc2 N'NXB1', N'Kỹ thuật', N'Nhập khẩu' -- loại k đúng
EXEC SuaNXBMuc2 N'NXB1', N'Sáng tạo mới', N'Tư nhân' -- sửa k đổi loại
EXEC SuaNXBMuc2 N'NXB3', N'Thành công', N'Nhà nước' -- sửa có đổi loại TN -> NN
EXEC SuaNXBMuc2 N'NXB6', N'Đất Việt', N'Tư nhân' -- sửa có đổi loại NN -> TN
GO

-- Sửa lại các hàng đã sửa ở trên
EXEC SuaNXBMuc2 N'NXB1', N'Sáng tạo', N'Tư nhân'
EXEC SuaNXBMuc2 N'NXB3', N'Tinh tế', N'Tư nhân'
EXEC SuaNXBMuc2 N'NXB6', N'Dân tộc', N'Nhà nước'
GO

-- Câu 5: Xóa sách
-- Mức 1:
CREATE PROC XoaSachMuc1
@MaSach nvarchar(10)
AS
BEGIN
	IF (@MaSach IS NULL)
		PRINT N'Không thể xóa do không có giá trị mã sách!'
	ELSE IF (@MaSach NOT IN (SELECT MaSach FROM dbo.Sach))
		PRINT N'Không thể xóa do không tìm thấy mã sách ' + @MaSach + N' trong CSDL!'
	ELSE
		BEGIN
			DELETE FROM dbo.Sach WHERE MaSach = @MaSach
			PRINT N'Thành công xóa sách có mã sách là ' + @MaSach + N'!'
		END
END
GO

-- Test proc
EXEC XoaSachMuc1 NULL -- mã null
EXEC XoaSachMuc1 N'S123' -- k tìm thấy mã
EXEC XoaSachMuc1 N'S004' -- xóa được
EXEC XoaSachMuc1 N'S005' -- xóa được
GO

-- Thêm lại các dòng vừa xóa
INSERT INTO dbo.Sach VALUES (N'S004', N'Ai làm được', N'NXB6')
INSERT INTO dbo.Sach VALUES (N'S005', N'Chúa tàu Kim quy', N'NXB5')
GO

-- Mức 2:
CREATE PROC XoaSachMuc2
@MaSach nvarchar(10)
AS
BEGIN
	IF (@MaSach IS NULL)
		PRINT N'Không thể xóa do không có giá trị mã sách!'
	ELSE IF (@MaSach NOT IN (SELECT MaSach FROM dbo.Sach))
		PRINT N'Không thể xóa do không tìm thấy mã sách ' + @MaSach + N' trong CSDL!'
	ELSE IF EXISTS (SELECT * FROM dbo.Sach1 WHERE MaSach = @MaSach)
		BEGIN
			DELETE FROM dbo.Sach1 WHERE MaSach = @MaSach
			PRINT N'Thành công xóa sách có mã sách là ' + @MaSach + N'!'
		END
	ELSE
		BEGIN
			DELETE FROM dbo.Sach2 WHERE MaSach = @MaSach
			PRINT N'Thành công xóa sách có mã sách là ' + @MaSach + N'!'
		END
END
GO

-- Test proc
EXEC XoaSachMuc2 NULL -- mã null
EXEC XoaSachMuc2 N'S123' -- k tìm thấy mã
EXEC XoaSachMuc2 N'S004' -- xóa được
EXEC XoaSachMuc2 N'S005' -- xóa được
GO

-- Thêm lại các dòng vừa xóa
INSERT INTO dbo.Sach2 VALUES (N'S004', N'Ai làm được', N'NXB6')
INSERT INTO dbo.Sach1 VALUES (N'S005', N'Chúa tàu Kim quy', N'NXB5')
