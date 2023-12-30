USE QLNhanVien
GO

-- Câu 1: Tạo proc để tạo các phân mảnh

CREATE PROC TaoPhanManhPB
AS
BEGIN
	SELECT * INTO PB1
	FROM dbo.PhongBan
	WHERE ChiNhanh = N'Sài gòn'

	SELECT * INTO PB2
	FROM dbo.PhongBan
	WHERE ChiNhanh = N'Hà nội'
END
GO

EXEC TaoPhanManhPB
GO

CREATE PROC TaoPhanManhNV
AS
BEGIN
	SELECT * INTO NV1
	FROM dbo.NhanVien
	WHERE MaPB IN (SELECT MaPB FROM dbo.PB1)

	SELECT * INTO NV2
	FROM dbo.NhanVien
	WHERE MaPB IN (SELECT MaPB FROM dbo.PB2)
END
GO

EXEC TaoPhanManhNV
GO

-- Câu 2: Lập ds nhân viên phòng ban biết tên phòng ban (mức 1 và 2)
-- Mức 1:
CREATE PROC DSNhanVienMuc1
@TenPB nvarchar(50)
AS
BEGIN
	IF(@TenPB IS NULL)
		PRINT N'Không nhập tên phòng ban'
	ELSE IF NOT EXISTS (SELECT * FROM dbo.PhongBan WHERE TenPB = @TenPB)
		PRINT N'Không tìm thấy tên phòng ban!'
	ELSE
		BEGIN
			SELECT nv.*, pb.TenPB, pb.ChiNhanh
			FROM dbo.PhongBan pb, dbo.NhanVien nv
			WHERE pb.MaPB = nv.MaPB AND TenPB = @TenPB
		END
END
GO
-- Test mức 1
EXEC DSNhanVienMuc1 N'Thiết kế' -- tìm thấy
EXEC DSNhanVienMuc1 N'Kế toán' -- tìm thấy
EXEC DSNhanVienMuc1 N'Kỹ thuật' -- không tìm thấy
EXEC DSNhanVienMuc1 NULL -- null
GO

-- Mức 2:
CREATE PROC DSNhanVienMuc2
@TenPB nvarchar(50)
AS
BEGIN
	IF(@TenPB IS NULL)
		PRINT N'Không nhập tên phòng ban'
	ELSE IF NOT EXISTS (SELECT * FROM dbo.PB1 WHERE TenPB = @TenPB) AND NOT EXISTS (SELECT * FROM dbo.PB2 WHERE TenPB = @TenPB)
		PRINT N'Không tìm thấy tên phòng ban!'
	ELSE
		BEGIN
			SELECT nv.*, pb.TenPB, pb.ChiNhanh
			FROM dbo.PB1 pb, dbo.NV1 nv
			WHERE pb.MaPB = nv.MaPB AND TenPB = @TenPB
			UNION
			SELECT nv.*, pb.TenPB, pb.ChiNhanh
			FROM dbo.PB2 pb, dbo.NV2 nv
			WHERE pb.MaPB = nv.MaPB AND TenPB = @TenPB
		END
END
GO
-- Test mức 2
EXEC DSNhanVienMuc2 N'Thiết kế' -- tìm thấy
EXEC DSNhanVienMuc2 N'Kế toán' -- tìm thấy
EXEC DSNhanVienMuc2 N'Kỹ thuật' -- không tìm thấy
EXEC DSNhanVienMuc2 NULL -- null
GO

-- Câu 3: Thêm phòng ban mức 1 và 2
-- Mức 1:
CREATE PROC ThemPhongBanMuc1
@MaPB nvarchar(10), @TenPB nvarchar(50), @ChiNhanh nvarchar(50)
AS
BEGIN
	IF(@MaPB IS NULL)
		PRINT N'Không thêm dữ liệu được vì không có giá trị mã PB!'
	ELSE IF (@TenPB IS NULL)
		PRINT N'Không thêm dữ liệu được vì không có giá trị tên PB!'
	ELSE IF (@ChiNhanh IS NULL)
		PRINT N'Không thêm dữ liệu được vì không có giá trị chi nhánh!'
	ELSE IF (@ChiNhanh NOT IN (N'Sài gòn', N'Hà nội'))
		PRINT N'Không thêm được PB vì chi nhánh không hợp lệ!'
	ELSE IF EXISTS (SELECT * FROM dbo.PhongBan WHERE MaPB = @MaPB)
		PRINT N'Không thêm dữ liệu được vì trùng mã phòng ban!'
	ELSE
		BEGIN
			INSERT INTO dbo.PhongBan VALUES (@MaPB, @TenPB, @ChiNhanh)
			PRINT N'Thêm dữ liệu thành công!'
		END
END
GO
-- Test mức 1
EXEC ThemPhongBanMuc1 NULL, N'Bảo hành', N'Sài gòn' -- null mã
EXEC ThemPhongBanMuc1 N'PB07', N'Bảo hành', N'Sài gòn' -- thêm được
EXEC ThemPhongBanMuc1 N'PB08', N'Tư vấn', N'Hà nội' -- thêm được
EXEC ThemPhongBanMuc1 N'PB01', N'Kho vận', N'Hà nội' -- trùng mã
EXEC ThemPhongBanMuc1 N'PB09', N'Nghiên cứu', N'Cần thơ' -- chi nhánh không hợp lệ
-- Xóa các dòng đã thêm
DELETE FROM dbo.PhongBan WHERE MaPB = 'PB07'
DELETE FROM dbo.PhongBan WHERE MaPB = 'PB08'

-- Mức 2:
CREATE PROC ThemPhongBanMuc2
@MaPB nvarchar(10), @TenPB nvarchar(50), @ChiNhanh nvarchar(50)
AS
BEGIN
	IF(@MaPB IS NULL)
		PRINT N'Không thêm dữ liệu được vì không có giá trị mã PB!'
	ELSE IF (@TenPB IS NULL)
		PRINT N'Không thêm dữ liệu được vì không có giá trị tên PB!'
	ELSE IF (@ChiNhanh IS NULL)
		PRINT N'Không thêm dữ liệu được vì không có giá trị chi nhánh!'
	ELSE IF (@ChiNhanh NOT IN (N'Sài gòn', N'Hà nội'))
		PRINT N'Không thêm được PB vì chi nhánh không hợp lệ!'
	ELSE IF EXISTS (SELECT * FROM dbo.PB1 WHERE MaPB = @MaPB) OR EXISTS (SELECT * FROM dbo.PB2 WHERE MaPB = @MaPB)
		PRINT N'Không thêm dữ liệu được vì trùng mã phòng ban!'
	ELSE IF (@ChiNhanh = N'Sài gòn')
		BEGIN
			INSERT INTO dbo.PB1 VALUES (@MaPB, @TenPB, @ChiNhanh)
			PRINT N'Thêm dữ liệu thành công!'
		END
	ELSE
		BEGIN
			INSERT INTO dbo.PB2 VALUES (@MaPB, @TenPB, @ChiNhanh)
			PRINT N'Thêm dữ liệu thành công!'
		END
END
GO
-- Test mức 2
EXEC ThemPhongBanMuc2 NULL, N'Bảo hành', N'Sài gòn' -- null mã
EXEC ThemPhongBanMuc2 N'PB07', N'Bảo hành', N'Sài gòn' -- thêm được
EXEC ThemPhongBanMuc2 N'PB08', N'Tư vấn', N'Hà nội' -- thêm được
EXEC ThemPhongBanMuc2 N'PB01', N'Kho vận', N'Hà nội' -- trùng mã
EXEC ThemPhongBanMuc2 N'PB09', N'Nghiên cứu', N'Cần thơ' -- chi nhánh không hợp lệ
GO
-- Xóa các dòng đã thêm
DELETE FROM dbo.PB1 WHERE MaPB = 'PB07'
DELETE FROM dbo.PB2 WHERE MaPB = 'PB08'
GO

-- Câu 4: Sửa phòng ban mức 1 và 2
-- Mức 1:
CREATE PROC SuaPhongBanMuc1
@MaPB nvarchar(10), @TenPB nvarchar(50), @ChiNhanh nvarchar(50)
AS
BEGIN
	IF(@MaPB IS NULL)
		PRINT N'Không sửa dữ liệu được vì không có giá trị mã phòng ban!'
	ELSE IF (@TenPB IS NULL)
		PRINT N'Không sửa dữ liệu được vì không có giá trị tên phòng ban!'
	ELSE IF (@ChiNhanh IS NULL)
		PRINT N'Không sửa dữ liệu được vì không có giá trị chi nhánh!'
	ELSE IF (@ChiNhanh NOT IN (N'Sài gòn', N'Hà nội'))
		PRINT N'Không thêm được PB vì chi nhánh không hợp lệ!'
	ELSE IF NOT EXISTS (SELECT * FROM dbo.PhongBan WHERE MaPB = @MaPB)
		PRINT N'Không sửa dữ liệu được vì không tìm thấy có giá trị mã phòng ban!'
	ELSE
		BEGIN
			UPDATE dbo.PhongBan
			SET TenPB = @TenPB, ChiNhanh = @ChiNhanh
			WHERE MaPB = @MaPB
			PRINT N'Thành công sửa dữ liệu của ' + @MaPB + N' sang ' + @TenPB + N' và ' + @ChiNhanh + N'!'
		END
END
GO
-- Test mức 1
EXEC SuaPhongBanMuc1 NULL, N'Thiết kế',N'Sài gòn' -- null mã
EXEC SuaPhongBanMuc1 N'PB01', N'Nghiên cứu', NULL -- null chi nhánh
EXEC SuaPhongBanMuc1 N'PB01', N'Nghiên cứu', N'Cần thơ' -- chi nhánh không hợp lệ
EXEC SuaPhongBanMuc1 N'PB01', N'Nghiên cứu', N'Sài gòn' -- sửa được
EXEC SuaPhongBanMuc1 N'PB02', N'Phát triển', N'Hà nội' -- sửa được
EXEC SuaPhongBanMuc1 N'PB06', N'Tài chánh', N'Sài gòn' -- sửa được
EXEC SuaPhongBanMuc1 N'PB09', N'Kỹ thuật', N'Sài gòn' -- không tìm thấy mã
GO
-- Reset lại các dòng đã sửa
EXEC SuaPhongBanMuc1 N'PB01', N'Thiết kế', N'Sài gòn'
EXEC SuaPhongBanMuc1 N'PB02', N'Bán hàng', N'Sài gòn'
EXEC SuaPhongBanMuc1 N'PB06', N'Kế toán', N'Hà nội'
GO

-- Mức 2:
CREATE PROC SuaPhongBanMuc2
@MaPB nvarchar(10), @TenPB nvarchar(50), @ChiNhanh nvarchar(50)
AS
BEGIN
	IF(@MaPB IS NULL)
		PRINT N'Không sửa dữ liệu được vì không có giá trị mã phòng ban!'
	ELSE IF (@TenPB IS NULL)
		PRINT N'Không sửa dữ liệu được vì không có giá trị tên phòng ban!'
	ELSE IF (@ChiNhanh IS NULL)
		PRINT N'Không sửa dữ liệu được vì không có giá trị chi nhánh!'
	ELSE IF (@ChiNhanh NOT IN (N'Sài gòn', N'Hà nội'))
		PRINT N'Không thêm được PB vì chi nhánh không hợp lệ!'
	ELSE IF NOT EXISTS (SELECT * FROM dbo.PhongBan WHERE MaPB = @MaPB)
		PRINT N'Không sửa dữ liệu được vì không tìm thấy có giá trị mã phòng ban!'
	ELSE IF EXISTS (SELECT * FROM dbo.PB1 WHERE MaPB = @MaPB)
		BEGIN
			UPDATE dbo.PB1
			SET TenPB = @TenPB, ChiNhanh = @ChiNhanh
			WHERE MaPB = @MaPB
			PRINT N'Thành công sửa dữ liệu của ' + @MaPB + N' sang ' + @TenPB + N' và ' + @ChiNhanh + N'!'
			IF (@ChiNhanh = N'Hà nội')
				BEGIN
					INSERT INTO dbo.PB2
					SELECT * FROM dbo.PB1 WHERE MaPB = @MaPB
					DELETE FROM PB1 WHERE MaPB = @MaPB
					PRINT N'Thành công chuyển dữ liệu của ' + @MaPB + N' từ phân mảnh Sài gòn sang Hà nội!'
				END
		END
	ELSE
		BEGIN
			UPDATE dbo.PB2
			SET TenPB = @TenPB, ChiNhanh = @ChiNhanh
			WHERE MaPB = @MaPB
			PRINT N'Thành công sửa dữ liệu của ' + @MaPB + N' sang ' + @TenPB + N' và ' + @ChiNhanh + N'!'
			IF (@ChiNhanh = 'Sài gòn')
				BEGIN
					INSERT INTO dbo.PB1
					SELECT * FROM dbo.PB2 WHERE MaPB = @MaPB
					DELETE FROM PB2 WHERE MaPB = @MaPB
					PRINT N'Thành công chuyển dữ liệu của ' + @MaPB + N' từ phân mảnh Hà nội sang Sài gòn!'
				END
		END
END
GO
-- Test mức 2
EXEC SuaPhongBanMuc2 NULL, N'Thiết kế',N'Sài gòn' -- null mã
EXEC SuaPhongBanMuc2 N'PB01', N'Nghiên cứu', NULL -- null chi nhánh
EXEC SuaPhongBanMuc2 N'PB01', N'Nghiên cứu', N'Cần thơ' -- chi nhánh không hợp lệ
EXEC SuaPhongBanMuc2 N'PB01', N'Nghiên cứu', N'Sài gòn' -- sửa được
EXEC SuaPhongBanMuc2 N'PB02', N'Phát triển', N'Hà nội' -- sửa được
EXEC SuaPhongBanMuc2 N'PB06', N'Tài chánh', N'Sài gòn' -- sửa được
EXEC SuaPhongBanMuc2 N'PB09', N'Kỹ thuật', N'Sài gòn' -- không tìm thấy mã
GO
-- Reset lại các dòng đã sửa
EXEC SuaPhongBanMuc2 N'PB01', N'Thiết kế', N'Sài gòn'
EXEC SuaPhongBanMuc2 N'PB02', N'Bán hàng', N'Sài gòn'
EXEC SuaPhongBanMuc2 N'PB06', N'Kế toán', N'Hà nội'
GO