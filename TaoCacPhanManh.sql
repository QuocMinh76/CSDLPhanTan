USE QLDA
GO

-- Phân mảnh ngang NguoiQuanLy
SELECT * INTO NQL1
FROM dbo.NguoiQuanLy
WHERE TenPhong = 'P1'
GO

SELECT * INTO NQL2
FROM dbo.NguoiQuanLy
WHERE TenPhong = 'P2'
GO

-- Phân mảnh ngang dẫn xuất DuAn theo MaNQL
SELECT * INTO DA1
FROM dbo.DuAn
WHERE MaNQL IN
		(SELECT MaNQL FROM dbo.NQL1)
GO

SELECT * INTO DA2
FROM dbo.DuAn
WHERE MaNQL IN
		(SELECT MaNQL FROM dbo.NQL2)
GO

-- Phân mảnh ngang dẫn xuất BoPhan theo MaNQL
SELECT * INTO BP1
FROM dbo.BoPhan
WHERE MaNQL IN
		(SELECT MaNQL FROM dbo.NQL1)
GO

SELECT * INTO BP2
FROM dbo.BoPhan
WHERE MaNQL IN
		(SELECT MaNQL FROM dbo.NQL2)
GO

-- Phân mảnh ngang dẫn xuất NhanVien theo MaBP
SELECT * INTO NV1
FROM dbo.NhanVien
WHERE MaBP IN
		(SELECT MaBP FROM dbo.BP1)
GO

SELECT * INTO NV2
FROM dbo.NhanVien
WHERE MaBP IN
		(SELECT MaBP FROM dbo.BP2)
GO

-- Phân mảnh ngang dân xuất PhanCong theo bảng NhanVien dựa vào MaNV
SELECT * INTO PC1
FROM dbo.PhanCong
WHERE MaNV IN
		(SELECT MaNV FROM dbo.NV1)
GO

SELECT * INTO PC2
FROM dbo.PhanCong
WHERE MaNV IN
		(SELECT MaNV FROM dbo.NV2)
GO