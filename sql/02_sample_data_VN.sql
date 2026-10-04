-- =====================================================================
-- HE THONG MAY BAN HANG THU NHO TU DONG PHAT HIEN KET HANG
-- Project PRJ301 - De so 01 - Fall 2026
-- 02_sample_data.sql: Du lieu khoi tao he thong va 240 phien mau
-- =====================================================================

USE VendDB;
GO

-- Xoa sach du lieu cu truoc khi nap lai
DELETE FROM Vend_Alert;
DELETE FROM Vend_Label;
DELETE FROM Vend_Session;
DELETE FROM Vend_Restock;
DELETE FROM Vend_Slot;
DELETE FROM Vend_Product;
DELETE FROM RejectedPacket;
DELETE FROM Device;
DELETE FROM AppUser;
DELETE FROM AppRole;
GO

-- ===== 1. KHOI TAO VAI TRO =====
INSERT INTO AppRole(role_code, role_name, description) VALUES
    (N'ADMIN', N'Quản trị viên hệ thống', N'Toàn quyền quản trị tài khoản, phân quyền, cấu hình thiết bị và hệ thống'),
    (N'CATALOG_MANAGER', N'Quản lý danh mục', N'Quản lý mặt hàng, khối lượng chuẩn, dung sai, gán vào rãnh máy bán'),
    (N'OPERATOR', N'Nhân viên vận hành', N'Nạp hàng vào rãnh, lập phiếu nạp, chạy thử lượt nhả, xử lý sự cố rãnh'),
    (N'REVIEWER', N'Người kiểm duyệt nhãn', N'Kiểm duyệt các phiên bị nghi ngờ, sửa nhãn kèm lý do, xác nhận thống kê'),
    (N'VIEWER', N'Người xem báo cáo', N'Xem tổng quan Dashboard, biểu đồ kẹt hàng, chi tiết phiên và xuất file CSV');
GO

-- ===== 2. KHOI TAO NGUOI DUNG MAU (Password mac dinh: 123456) =====
-- PBKDF2 hash chuoi: iterations:saltHex:hashHex
DECLARE @h NVARCHAR(200) = N'20000:a0dee5aba0d8cc258ed13fa22d6b729e:7cc4e6fd505db9217ae726189980404174314d771379ca4d98798889d015a124';

INSERT INTO AppUser(username, pass_hash, full_name, email, phone, role_id, is_locked)
SELECT v.u, @h, v.n, v.m, v.p, r.role_id, 0
FROM (VALUES
    (N'admin',           N'Nguyễn Quản Trị (ADMIN)',           N'admin@vending.local',    N'0901000001', N'ADMIN'),
    (N'catalog_manager', N'Trần Danh Mục (CATALOG_MANAGER)',   N'catalog@vending.local',  N'0901000002', N'CATALOG_MANAGER'),
    (N'operator',        N'Lê Vận Hành (OPERATOR)',            N'operator@vending.local', N'0901000003', N'OPERATOR'),
    (N'reviewer',        N'Phạm Kiểm Duyệt (REVIEWER)',        N'reviewer@vending.local', N'0901000004', N'REVIEWER'),
    (N'viewer',          N'Hoàng Khách Xem (VIEWER)',          N'viewer@vending.local',   N'0901000005', N'VIEWER')
) AS v(u, n, m, p, rc)
JOIN AppRole r ON r.role_code = v.rc;
GO

-- ===== 3. KHOI TAO THIET BI =====
INSERT INTO Device(device_code, api_key, location, is_active) VALUES
    (N'Vend-01', N'demo-key-vend-0001', N'Bàn thực hành số 1 - Lab IoT', 1),
    (N'Vend-02', N'demo-key-vend-0002', N'Bàn thực hành số 2 - Sảnh tầng 2', 1);
GO

-- ===== 4. KHOI TAO DANH MUC HANG & RANH =====
INSERT INTO Vend_Product(code, name, nominal_weight, tolerance, price, note) VALUES
    (N'PRD-CANDY-01', N'Kẹo Alpenliebe Caramel (Gói 5 viên)', 25.00, 3.00, 5000, N'Gói kẹo nhỏ chuẩn đề tài, khối lượng danh định 25g'),
    (N'PRD-CHOCO-02', N'Bánh Chocopie Orion 33g',             33.00, 3.50, 8000, N'Bánh Chocopie đóng gói 1 cái'),
    (N'PRD-SNACK-03', N'Bim Bim Oishi Phồng Tôm 30g',          30.00, 4.00, 6000, N'Snack nhẹ túi mỏng');
GO

DECLARE @prd1 INT = (SELECT TOP 1 product_id FROM Vend_Product WHERE code = N'PRD-CANDY-01');
DECLARE @prd2 INT = (SELECT TOP 1 product_id FROM Vend_Product WHERE code = N'PRD-CHOCO-02');

INSERT INTO Vend_Slot(code, name, product_id, capacity, current_stock, is_suspended, note) VALUES
    (N'SLOT-01', N'Rãnh lò xo số 1 (Kẹo Alpenliebe)', @prd1, 10, 7, 0, N'Rãnh lò xo thép đơn quay bằng motor DC'),
    (N'SLOT-02', N'Rãnh lò xo số 2 (Bánh Chocopie)',  @prd2,  8, 5, 0, N'Rãnh phụ kiểm thử');
GO

-- ===== 5. SINH DU LIEU 240 PHIEN MAU (IS_SAMPLE = 1) =====
DECLARE @dev INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = N'Vend-01');
DECLARE @slot INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = N'SLOT-01');
DECLARE @seq INT = ISNULL((SELECT MAX(device_seq) FROM Vend_Session WHERE device_id = @dev), 0);

-- A. SUCCESS: 120 phien mau
INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
SELECT
    @dev,
    @slot,
    @seq + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    DATEADD(SECOND, 0 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), SYSDATETIME()),
    CAST(120 + RAND(CHECKSUM(NEWID())) * 360 AS DECIMAL(9,2)) AS weight_before,
    CAST(145 + RAND(CHECKSUM(NEWID())) * 365 AS DECIMAL(9,2)) AS weight_after,
    CAST(22 + RAND(CHECKSUM(NEWID())) * 6 AS DECIMAL(9,2)) AS weight_delta,
    1 AS coil_turns,
    900 + ABS(CHECKSUM(NEWID())) % 701 AS motor_ms,
    400 + ABS(CHECKSUM(NEWID())) % 801 AS settle_ms,
    CAST(30 + RAND(CHECKSUM(NEWID())) * 60 AS DECIMAL(9,2)) AS peak_delta,
    1
FROM (SELECT TOP (120) 1 AS x FROM sys.all_objects a CROSS JOIN sys.all_objects b) AS n;

SET @seq = @seq + 120;

INSERT INTO Vend_Label(session_id, label_code, source, reason)
SELECT s.session_id, N'SUCCESS', N'RULE', N'Nhãn gán tự động cho dữ liệu mẫu'
FROM Vend_Session s
LEFT JOIN Vend_Label l ON l.session_id = s.session_id
WHERE s.is_sample = 1 AND l.label_id IS NULL;

-- B. JAM: 40 phien mau
INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
SELECT
    @dev,
    @slot,
    @seq + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    DATEADD(SECOND, -90000 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), SYSDATETIME()),
    CAST(120 + RAND(CHECKSUM(NEWID())) * 360 AS DECIMAL(9,2)) AS weight_before,
    CAST(145 + RAND(CHECKSUM(NEWID())) * 365 AS DECIMAL(9,2)) AS weight_after,
    CAST(0 + RAND(CHECKSUM(NEWID())) * 2 AS DECIMAL(9,2)) AS weight_delta,
    1 AS coil_turns,
    900 + ABS(CHECKSUM(NEWID())) % 701 AS motor_ms,
    400 + ABS(CHECKSUM(NEWID())) % 801 AS settle_ms,
    CAST(0 + RAND(CHECKSUM(NEWID())) * 4 AS DECIMAL(9,2)) AS peak_delta,
    1
FROM (SELECT TOP (40) 1 AS x FROM sys.all_objects a CROSS JOIN sys.all_objects b) AS n;

SET @seq = @seq + 40;

INSERT INTO Vend_Label(session_id, label_code, source, reason)
SELECT s.session_id, N'JAM', N'RULE', N'Nhãn gán tự động cho dữ liệu mẫu'
FROM Vend_Session s
LEFT JOIN Vend_Label l ON l.session_id = s.session_id
WHERE s.is_sample = 1 AND l.label_id IS NULL;

-- C. WRONG_ITEM: 50 phien mau
INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
SELECT
    @dev,
    @slot,
    @seq + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    DATEADD(SECOND, -180000 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), SYSDATETIME()),
    CAST(120 + RAND(CHECKSUM(NEWID())) * 360 AS DECIMAL(9,2)) AS weight_before,
    CAST(145 + RAND(CHECKSUM(NEWID())) * 365 AS DECIMAL(9,2)) AS weight_after,
    CAST(44 + RAND(CHECKSUM(NEWID())) * 14 AS DECIMAL(9,2)) AS weight_delta,
    1 AS coil_turns,
    900 + ABS(CHECKSUM(NEWID())) % 701 AS motor_ms,
    400 + ABS(CHECKSUM(NEWID())) % 801 AS settle_ms,
    CAST(60 + RAND(CHECKSUM(NEWID())) * 80 AS DECIMAL(9,2)) AS peak_delta,
    1
FROM (SELECT TOP (50) 1 AS x FROM sys.all_objects a CROSS JOIN sys.all_objects b) AS n;

SET @seq = @seq + 50;

INSERT INTO Vend_Label(session_id, label_code, source, reason)
SELECT s.session_id, N'WRONG_ITEM', N'RULE', N'Nhãn gán tự động cho dữ liệu mẫu'
FROM Vend_Session s
LEFT JOIN Vend_Label l ON l.session_id = s.session_id
WHERE s.is_sample = 1 AND l.label_id IS NULL;

-- D. MOTOR_FAIL: 30 phien mau
INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
SELECT
    @dev,
    @slot,
    @seq + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    DATEADD(SECOND, -270000 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), SYSDATETIME()),
    CAST(120 + RAND(CHECKSUM(NEWID())) * 360 AS DECIMAL(9,2)) AS weight_before,
    CAST(145 + RAND(CHECKSUM(NEWID())) * 365 AS DECIMAL(9,2)) AS weight_after,
    CAST(0 + RAND(CHECKSUM(NEWID())) * 1 AS DECIMAL(9,2)) AS weight_delta,
    0 AS coil_turns,
    4000 + ABS(CHECKSUM(NEWID())) % 101 AS motor_ms,
    400 + ABS(CHECKSUM(NEWID())) % 801 AS settle_ms,
    CAST(30 + RAND(CHECKSUM(NEWID())) * 60 AS DECIMAL(9,2)) AS peak_delta,
    1
FROM (SELECT TOP (30) 1 AS x FROM sys.all_objects a CROSS JOIN sys.all_objects b) AS n;

SET @seq = @seq + 30;

INSERT INTO Vend_Label(session_id, label_code, source, reason)
SELECT s.session_id, N'MOTOR_FAIL', N'RULE', N'Nhãn gán tự động cho dữ liệu mẫu'
FROM Vend_Session s
LEFT JOIN Vend_Label l ON l.session_id = s.session_id
WHERE s.is_sample = 1 AND l.label_id IS NULL;

-- Ghi nhan mot vai canh bao mau tuong ung cac phien loi
INSERT INTO Vend_Alert(session_id, slot_id, rule_code, severity, message, status)
SELECT TOP 5 session_id, @slot, N'JAM_DETECTED', N'CRITICAL', N'Lò xo quay đủ vòng nhưng khay không tăng khối lượng (kẹt hàng)', N'OPEN'
FROM Vend_Session WHERE weight_delta <= 2 AND coil_turns = 1;

INSERT INTO Vend_Alert(session_id, slot_id, rule_code, severity, message, status)
SELECT TOP 3 session_id, @slot, N'MOTOR_TIMEOUT', N'CRITICAL', N'Trục không quay đủ một vòng trong thời gian 4000ms', N'OPEN'
FROM Vend_Session WHERE coil_turns = 0;
GO

-- Kiem tra tong so phien da sinh
SELECT l.label_code, COUNT(*) AS so_phien
FROM Vend_Session s 
JOIN Vend_Label l ON l.session_id = s.session_id
WHERE s.is_sample = 1
GROUP BY l.label_code
ORDER BY so_phien DESC;
GO
