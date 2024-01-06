USE QLNhanVien
GO

-- Câu 1: Viết proc để phân mảnh ngang PB và proc để phân mảnh ngang dẫn xuất NV theo PB
-- Phân mảnh ngang bảng phòng ban
CREATE PROC TaoPM_Ngang_PB
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

EXEC TaoPM_Ngang_PB
GO

-- Phân mảnh ngang dẫn xuất bảng nhân viên theo phòng ban
CREATE PROC TaoPM_Ngang_NhanVien
AS
BEGIN
	SELECT * INTO NV1
	FROM dbo.NhanVien
	WHERE MaPB IN (SELECT MaPB FROM PB1)

	SELECT * INTO NV2
	FROM dbo.NhanVien
	WHERE MaPB IN (SELECT MaPB FROM PB2)
END
GO

EXEC TaoPM_Ngang_NhanVien
GO

-- Viết thêm để xem danh sách được lập từ các phân mảnh ngang
CREATE PROC XemPB_Ngang
AS
BEGIN
	SELECT * FROM PB1
	UNION
	SELECT * FROM PB2
END
GO

EXEC XemPB_Ngang
GO

-- Cau 2: Viết proc để thêm dữ liệu vào các phân mảnh ngang
CREATE PROC ThemPB
@MaPB nvarchar(10), @TenPB nvarchar(50), @ChiNhanh nvarchar(50)
AS
BEGIN
	IF(@MaPB IS NULL)
		PRINT N'Không thể thêm dữ liệu được vì thiếu giá trị Mã phòng ban'
	ELSE IF (@TenPB IS NULL)
		PRINT N'Không thể thêm dữ liệu được vì thiếu giá trị Tên phòng ban'
	ELSE IF (@ChiNhanh IS NULL)
		PRINT N'Không thể thêm dữ liệu được vì thiếu giá trị Chi nhánh'
	ELSE IF (@ChiNhanh NOT IN (N'Sài gòn', N'Hà nội'))
		PRINT N'Không thể thêm dữ liệu được dữ liệu Chi nhánh không hợp lệ (Chi nhánh phải là Sài gòn hoặc Hà nội)'
	ELSE IF EXISTS (SELECT * FROM PB1 WHERE MaPB = @MaPB) OR EXISTS (SELECT * FROM PB2 WHERE MaPB = @MaPB)
		PRINT N'Không thể thêm dữ liệu được vì Mã phòng ban muốn thêm đã tồn tại trong CSDL'
	ELSE IF (@ChiNhanh = 'Sài gòn')
		BEGIN
			INSERT INTO dbo.PB1 VALUES(@MaPB, @TenPB, @ChiNhanh)
			PRINT N'Đã thêm thành công dữ liệu vào phân mảnh PB1'
		END
	ELSE
		BEGIN
			INSERT INTO dbo.PB2 VALUES(@MaPB, @TenPB, @ChiNhanh)
			PRINT N'Đã thêm thành công dữ liệu vào phân mảnh PB2'
		END
END
GO

-- Các trường hợp thử
EXEC ThemPB null, N'Sui', N'Sài gòn' -- Lỗi thiếu mã pb
EXEC ThemPB N'Sui', null, N'Sài gòn' -- Lỗi thiếu tên pb
EXEC ThemPB N'Sui', N'Sui', null -- Lỗi thiếu chi nhánh
EXEC ThemPB N'Sui', N'Sui', N'Đà Nẵng' -- Lỗi chi nhánh không hợp lệ
EXEC ThemPB PB02, N'Sui', N'Sài gòn' -- Lỗi trùng mã pb
EXEC ThemPB PB05, N'Sui', N'Sài gòn' -- Lỗi trùng mã pb (2)
EXEC ThemPB PB07, N'Sui1', N'Sài gòn' -- Thêm thành công vào bảng PB1
EXEC ThemPB PB08, N'Sui2', N'Hà nội' -- Thêm thành công vào bảng PB2
GO

-- Xem kết quả sau khi thêm
EXEC XemPB_Ngang
GO

-- Xóa các hàng đã thêm
DELETE FROM PB1 WHERE MaPB = 'PB07'
DELETE FROM PB2 WHERE MaPB = 'PB08'
GO

-- Câu 3: Viết proc để sửa dữ liệu trên các phân mảnh ngang

CREATE PROC SuaPB
@MaPB nvarchar(10), @TenPB nvarchar(50), @ChiNhanh nvarchar(50)
AS
BEGIN
	IF(@MaPB IS NULL)
		PRINT N'Không thể sửa dữ liệu được vì thiếu giá trị Mã phòng ban'
	ELSE IF (@TenPB IS NULL)
		PRINT N'Không thể sửa dữ liệu được vì thiếu giá trị Tên phòng ban'
	ELSE IF (@ChiNhanh IS NULL)
		PRINT N'Không thể sửa dữ liệu được vì thiếu giá trị Chi nhánh'
	ELSE IF (@ChiNhanh NOT IN (N'Sài gòn', N'Hà nội'))
		PRINT N'Không thể sửa dữ liệu được dữ liệu Chi nhánh không hợp lệ (Chi nhánh phải là Sài gòn hoặc Hà nội)'
	ELSE IF NOT EXISTS (SELECT * FROM PB1 WHERE MaPB = @MaPB) AND NOT EXISTS (SELECT * FROM PB2 WHERE MaPB = @MaPB)
		PRINT N'Không thể sửa dữ liệu được vì Mã phòng ban muốn sửa không tồn tại trong CSDL'
	ELSE IF EXISTS (SELECT MaPB FROM dbo.PB1 WHERE MaPB = @MaPB)
		BEGIN
			UPDATE dbo.PB1
			SET TenPB = @TenPB, ChiNhanh = @ChiNhanh
			WHERE MaPB = @MaPB
			PRINT N'Đã sửa dữ liệu thành công ở bảng PB1'
			IF @ChiNhanh <> N'Sài gòn'
					BEGIN
						INSERT INTO dbo.PB2
						SELECT * FROM dbo.PB1 WHERE MaPB = @MaPB
						DELETE FROM dbo.PB1 WHERE MaPB = @MaPB

						INSERT INTO dbo.NV2
						SELECT * FROM dbo.NV1 WHERE MaPB = @MaPB
						DELETE FROM dbo.NV1 WHERE MaPB = @MaPB

						PRINT N'Đã chuyển phòng ban từ bảng PB1 (Sài gòn) sang bảng PB2 (Hà nội)'
					END
		END
	ELSE
		BEGIN
			UPDATE dbo.PB2
			SET TenPB = @TenPB, ChiNhanh = @ChiNhanh
			WHERE MaPB = @MaPB
			PRINT N'Đã sửa dữ liệu thành công ở bảng PB2'
			IF @ChiNhanh <> N'Hà nội'
					BEGIN
						INSERT INTO dbo.PB1
						SELECT * FROM dbo.PB2 WHERE MaPB = @MaPB
						DELETE FROM dbo.PB2 WHERE MaPB = @MaPB

						INSERT INTO dbo.NV1
						SELECT * FROM dbo.NV2 WHERE MaPB = @MaPB
						DELETE FROM dbo.NV2 WHERE MaPB = @MaPB

						PRINT N'Đã chuyển phòng ban từ bảng PB2 (Hà nội) sang bảng PB1 (Sài gòn)'
					END
		END
END
GO

-- Các trường hợp thử
EXEC SuaPB null, N'Sui', N'Sài gòn' -- Lỗi thiếu mã pb
EXEC SuaPB N'Sui', null, N'Sài gòn' -- Lỗi thiếu tên pb
EXEC SuaPB N'Sui', N'Sui', null -- Lỗi thiếu chi nhánh
EXEC SuaPB N'Sui', N'Sui', N'Đà Nẵng' -- Lỗi chi nhánh không hợp lệ
EXEC SuaPB PB07, N'Sui', N'Sài gòn' -- Lỗi mã pb không tồn tại
EXEC SuaPB PB01, N'Shion1', N'Sài gòn' -- Thành công sửa dữ liệu ở bảng PB1
EXEC SuaPB PB02, N'Shion2', N'Hà nội' -- Thành công sửa dữ liệu ở bảng PB1 và chuyển hàng dữ liệu đó qua bảng PB2
EXEC SuaPB PB04, N'Shion3', N'Hà nội' -- Thành công sửa dữ liệu ở bảng PB2
EXEC SuaPB PB05, N'Shion4', N'Sài gòn' -- Thành công sửa dữ liệu ở bảng PB2 và chuyển hàng dữ liệu đó qua bảng PB1
GO

-- Xem kết quả sau khi sửa
SELECT * FROM PB1 -- Xem bảng PB1
SELECT * FROM PB2 -- Xem bảng PB2
EXEC XemPB_Ngang -- Xem cả hai bảng
GO

-- Sửa lại các cột đã sửa ở trên
EXEC SuaPB PB01, N'Thiết kế', N'Sài gòn'
EXEC SuaPB PB02, N'Bán hàng', N'Sài gòn'
EXEC SuaPB PB04, N'Sản xuất', N'Hà nội'
EXEC SuaPB PB05, N'Kinh doanh', N'Hà nội'
GO

-- Câu 4: Viết proc để tạo phân mảnh dọc
CREATE PROC TaoPM_Doc_PB
AS
BEGIN
	SELECT [MaPB], [TenPB] INTO PBD1 -- Phòng Ban Dọc 1
	FROM dbo.PhongBan

	SELECT [MaPB], [ChiNhanh] INTO PBD2 -- Phòng Ban Dọc 2
	FROM dbo.PhongBan
END
GO

EXEC TaoPM_Doc_PB
GO

-- Câu 5: Viết proc để lập danh sách từ các phân mảnh dọc
CREATE PROC XemPB_Doc
AS
BEGIN
	SELECT d1.MaPB, d1.TenPB, d2.ChiNhanh
	FROM dbo.PBD1 d1 JOIN dbo.PBD2 d2 ON d1.MaPB = d2.MaPB
END
GO

EXEC XemPB_Doc
GO

-- Câu 6: Viết proc để sửa dữ liệu trên các phân mảnh dọc

CREATE PROC SuaPB_Doc
@MaPB nvarchar(10), @TenPB nvarchar(50), @ChiNhanh nvarchar(50)
AS
BEGIN
	IF(@MaPB IS NULL)
		PRINT N'Không thể sửa dữ liệu được vì thiếu giá trị Mã phòng ban'
	ELSE IF (@TenPB IS NULL)
		PRINT N'Không thể sửa dữ liệu được vì thiếu giá trị Tên phòng ban'
	ELSE IF (@ChiNhanh IS NULL)
		PRINT N'Không thể sửa dữ liệu được vì thiếu giá trị Chi nhánh'
	ELSE IF (@ChiNhanh NOT IN (N'Sài gòn', N'Hà nội'))
		PRINT N'Không thể sửa dữ liệu được dữ liệu Chi nhánh không hợp lệ (Chi nhánh phải là Sài gòn hoặc Hà nội)'
	ELSE IF NOT EXISTS (SELECT * FROM PBD1 WHERE MaPB = @MaPB)
		PRINT N'Không thể sửa dữ liệu được vì Mã phòng ban muốn sửa không tồn tại trong CSDL'
	ELSE
		BEGIN
			UPDATE dbo.PBD1
			SET TenPB = @TenPB
			WHERE MaPB = @MaPB

			UPDATE dbo.PBD2
			SET ChiNhanh = @ChiNhanh
			WHERE MaPB = @MaPB

			PRINT N'Đã sửa dữ liệu thành công'
		END
END
GO

-- Các trường hợp thử
EXEC SuaPB_Doc null, N'Sui', N'Sài gòn' -- Lỗi thiếu mã pb
EXEC SuaPB_Doc N'Sui', null, N'Sài gòn' -- Lỗi thiếu tên pb
EXEC SuaPB_Doc N'Sui', N'Sui', null -- Lỗi thiếu chi nhánh
EXEC SuaPB_Doc N'Sui', N'Sui', N'Đà Nẵng' -- Lỗi chi nhánh không hợp lệ
EXEC SuaPB_Doc PB07, N'Sui', N'Sài gòn' -- Lỗi mã pb không tồn tại
EXEC SuaPB_Doc PB01, N'La+1', N'Hà nội' -- Thành công sửa dữ liệu
EXEC SuaPB_Doc PB04, N'La+2', N'Sài gòn' -- Thành công sửa dữ liệu (2)
GO

-- Xem kết quả sau khi sửa
SELECT * FROM PBD1 -- Xem bảng PBD1
SELECT * FROM PBD2 -- Xem bảng PBD2
EXEC XemXemPB_Doc-- Xem cả hai bảng
GO

-- Sửa lại các cột đã sửa ở trên
EXEC SuaPB_Doc PB01, N'Thiết kế', N'Sài gòn'
EXEC SuaPB_Doc PB04, N'Sản xuất', N'Hà nội'
GO
