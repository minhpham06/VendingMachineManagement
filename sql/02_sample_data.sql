-- ============================================================
-- VendDB - Sample Data for Defense & Simulation (PRJ301 Fall 2026)
-- Mật khẩu mặc định cho toàn bộ 5 tài khoản mẫu là: 123456
-- Chuỗi băm chuẩn PBKDF2WithHmacSHA256 (20000 iterations)
-- ============================================================

USE VendDB;
GO

-- 1. Nạp 5 Vai trò chuẩn hệ thống
SET IDENTITY_INSERT AppRole ON;
INSERT INTO AppRole (role_id, role_code, role_name, description) VALUES
(1, 'ADMIN', N'Quản trị viên hệ thống', N'Toàn quyền quản trị tài khoản, phân quyền, cấu hình thiết bị và hệ thống'),
(2, 'CATALOG_MANAGER', N'Quản lý danh mục', N'Quản lý mặt hàng, khối lượng chuẩn, dung sai, gán vào rãnh máy bán'),
(3, 'OPERATOR', N'Nhân viên vận hành', N'Nạp hàng vào rãnh, lập phiếu nạp, chạy thử lượt nhả, xử lý sự cố rãnh'),
(4, 'REVIEWER', N'Người kiểm duyệt nhãn', N'Kiểm duyệt các phiên bị nghi ngờ, sửa nhãn kèm lý do, xác nhận thống kê'),
(5, 'VIEWER', N'Người xem báo cáo', N'Xem tổng quan Dashboard, biểu đồ kẹt hàng, chi tiết phiên và xuất file CSV');
SET IDENTITY_INSERT AppRole OFF;
GO

-- 2. Nạp 5 Người dùng mẫu (Mật khẩu: 123456)
-- PBKDF2 Hash: 20000:c2FsdHNhbHRzYWx0MTIzNA==:x6lX17tKvhc8gH9sXhHhZ7L8V4Y= (Tạo tương thích)
INSERT INTO AppUser (username, pass_hash, full_name, email, phone, role_id, is_locked) VALUES
('admin', '20000:73616c7473616c7473616c7431323334:73867c4613ff1d53347fb05342d10cff9ca9802d338be29d10c71a39626e8ad9', N'Nguyễn Quản Trị (ADMIN)', 'admin@vending.local', '0901234567', 1, 0),
('catalog_manager', '20000:73616c7473616c7473616c7431323334:73867c4613ff1d53347fb05342d10cff9ca9802d338be29d10c71a39626e8ad9', N'Trần Danh Mục (CATALOG_MANAGER)', 'catalog@vending.local', '0912345678', 2, 0),
('operator', '20000:73616c7473616c7473616c7431323334:73867c4613ff1d53347fb05342d10cff9ca9802d338be29d10c71a39626e8ad9', N'Lê Vận Hành (OPERATOR)', 'operator@vending.local', '0923456789', 3, 0),
('reviewer', '20000:73616c7473616c7473616c7431323334:73867c4613ff1d53347fb05342d10cff9ca9802d338be29d10c71a39626e8ad9', N'Phạm Kiểm Duyệt (REVIEWER)', 'reviewer@vending.local', '0934567890', 4, 0),
('viewer', '20000:73616c7473616c7473616c7431323334:73867c4613ff1d53347fb05342d10cff9ca9802d338be29d10c71a39626e8ad9', N'Hoàng Khách Xem (VIEWER)', 'viewer@vending.local', '0945678901', 5, 0);
GO

-- 3. Nạp Thiết bị mô hình ESP32
SET IDENTITY_INSERT Device ON;
INSERT INTO Device (device_id, device_code, api_key, mac_address, status) VALUES
(1, 'Vend-01', 'KEY-VEND-FPT2026-ABCXYZ', '24:6F:28:B4:7A:1A', 'ACTIVE');
SET IDENTITY_INSERT Device OFF;
GO

-- 4. Nạp Mặt hàng mẫu
SET IDENTITY_INSERT Vend_Product ON;
INSERT INTO Vend_Product (product_id, product_name, nominal_weight_g, tolerance_g, unit_price, is_active) VALUES
(1, N'Bánh que Pocky Socola', 25.0, 3.0, 12000, 1),
(2, N'Kẹo Marshmallow Choco', 18.0, 2.5, 8000, 1),
(3, N'Bánh Chocopie Lotte', 33.0, 4.0, 15000, 1);
SET IDENTITY_INSERT Vend_Product OFF;
GO

-- 5. Nạp Rãnh lò xo
SET IDENTITY_INSERT Vend_Slot ON;
INSERT INTO Vend_Slot (slot_id, device_id, slot_code, product_id, capacity, stock_qty, status) VALUES
(1, 1, 'SLOT-01', 1, 10, 8, 'ACTIVE'),
(2, 1, 'SLOT-02', 2, 10, 6, 'ACTIVE');
SET IDENTITY_INSERT Vend_Slot OFF;
GO

-- 6. Nạp Phiếu nạp hàng ban đầu
INSERT INTO Vend_Restock (slot_id, quantity, operator_id, note) VALUES
(1, 10, 3, N'Nạp đầy rãnh 1 đầu học kỳ'),
(2, 10, 3, N'Nạp đầy rãnh 2 đầu học kỳ');
GO
