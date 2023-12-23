﻿-- Tạo CSDL
CREATE DATABASE QLCLBNK
GO

USE QLCLBNK
GO

-- Tạo các bảng
CREATE TABLE CauLacBo (
    MaCLB nchar(5) PRIMARY KEY NOT NULL,
    TenCLB nvarchar(50) NOT NULL,
    TenKhoa nvarchar(10)
);
GO

CREATE TABLE GiangVien (
    MaGV nchar(5) PRIMARY KEY,
    Ho nvarchar(20) NOT NULL,
	Ten nvarchar(50) NOT NULL,
    MaCLB nchar(5) NOT NULL,
	FOREIGN KEY (MaCLB) REFERENCES CauLacBo(MaCLB)
);
GO

CREATE TABLE SinhVien (
    MaSV nchar(5) PRIMARY KEY,
    Ho nvarchar(20) NOT NULL,
	Ten nvarchar(50) NOT NULL,
    MaCLB nchar(5) NOT NULL,
	FOREIGN KEY (MaCLB) REFERENCES CauLacBo(MaCLB)
);
GO

CREATE TABLE LopNangKhieu (
    MaLop nchar(5) PRIMARY KEY,
    NgayMo datetime NOT NULL,
    MaGV nchar(5) NOT NULL,
	HocPhi int NOT NULL,
    FOREIGN KEY (MaGV) REFERENCES GiangVien(MaGV)
);
GO

CREATE TABLE BienLai (
    SoBL int NOT NULL PRIMARY KEY,
    Thang int NOT NULL,
	Nam int NOT NULL,
	MaLop nchar(5) NOT NULL,
	MaSV nchar(5) NOT NULL,
	SoTien int NOT NULL,
    FOREIGN KEY (MaLop) REFERENCES LopNangKhieu(MaLop),
    FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV)
);
GO

-- Nhập liệu cho các bảng
-- Bảng người quản lý
INSERT INTO NguoiQuanLy VALUES
(101, 'Nguyen', 'Van A', 'P1'),
(102, 'Tran', 'Thuong', 'P2'),
(103, 'Nguyen', 'Hong An', 'P2'),
(104, 'Hoang', 'Ngoc Hai', 'P1'),
(105, 'Trieu', 'Minh', 'P1');
GO

-- Bảng dự án
INSERT INTO DuAn VALUES
('DA001', 'Lap trinh Web ban hang', 101),
('DA002', 'Thiet ke CSDL phan tan', 104),
('DA003', 'Thiet ke giao dien do hoa', 102),
('DA004', 'Thiet ke he thong nha hang', 104),
('DA005', 'Kiem thu phan mem moi', 105),
('DA006', 'Lap trinh ung dung di dong', 103);
GO

-- Bảng bộ phận
INSERT INTO BoPhan VALUES
('BP001', 'Bo phan 1', 104),
('BP002', 'Bo phan 2', 101),
('BP003', 'Bo phan 3', 105),
('BP004', 'Bo phan 4', 103),
('BP005', 'Bo phan 5', 102);
GO

-- Bảng nhân viên
INSERT INTO NhanVien VALUES
(1001, 'Tran Van', 'A', 'BP001'),
(1002, 'Nguyen Hoang', 'B', 'BP003'),
(1003, 'Le Thi', 'C', 'BP003'),
(1004, 'Nguyen Van', 'D', 'BP005'),
(1005, 'Hoang Minh', 'E', 'BP002'),
(1006, 'Nguyen Thi', 'F', 'BP001'),
(1007, 'Phan Trong', 'G', 'BP004'),
(1008, 'Pham Tien', 'H', 'BP005');
GO

-- Bảng phân công
INSERT INTO PhanCong VALUES
(1001, 'DA001'),
(1001, 'DA003'),
(1002, 'DA003'),
(1003, 'DA001'),
(1004, 'DA002'),
(1005, 'DA001'),
(1005, 'DA004'),
(1006, 'DA002'),
(1007, 'DA006'),
(1008, 'DA005');
GO