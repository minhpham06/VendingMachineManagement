-- =====================================================================
-- HE THONG MAY BAN HANG THU NHO TU DONG PHAT HIEN KET HANG
-- Project PRJ301 - De so 01 - Fall 2026
-- 02_sample_data_VN.sql: Du lieu khoi tao he thong va 240 phien mau
-- =====================================================================

USE VendDB;
GO

-- Xoa sach du lieu cu truoc khi nap lai (theo thu tu rang buoc khoa ngoai)
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

-- ===== 1. KHOI TAO VAI TRO NGUOI DUNG =====
INSERT INTO AppRole(role_code, role_name, description) VALUES
    (N'ADMIN',           N'Quản trị viên hệ thống', N'Toàn quyền quản trị tài khoản, phân quyền, cấu hình thiết bị và hệ thống'),
    (N'CATALOG_MANAGER', N'Quản lý danh mục',       N'Quản lý mặt hàng, khối lượng chuẩn, dung sai, gắn vào rãnh máy bán'),
    (N'OPERATOR',        N'Nhân viên vận hành',     N'Nạp hàng vào rãnh, lập phiếu nạp, xử lý sự cố kẹt hàng'),
    (N'REVIEWER',        N'Người kiểm duyệt nhãn',  N'Kiểm duyệt các phiên bị nghi ngờ, sửa nhãn kèm lý do xác nhận'),
    (N'VIEWER',          N'Người xem báo cáo',      N'Xem tổng quan Dashboard, biểu đồ kẹt hàng, chi tiết phiên và xuất CSV');
GO

-- ===== 2. KHOI TAO NGUOI DUNG MAU (Mật khẩu mặc định: 123456) =====
-- PBKDF2WithHmacSHA256: 20000 vòng băm + 16-byte salt
DECLARE @h VARCHAR(200) = '20000:a0dee5aba0d8cc258ed13fa22d6b729e:7cc4e6fd505db9217ae726189980404174314d771379ca4d98798889d015a124';

INSERT INTO AppUser(username, pass_hash, full_name, email, phone, role_id, is_locked)
SELECT v.u, @h, v.n, v.m, v.p, r.role_id, 0
FROM (VALUES
    ('admin',           N'Nguyễn Quản Trị (ADMIN)',           'admin@vending.local',    '0901000001', 'ADMIN'),
    ('catalog_manager', N'Trần Danh Mục (CATALOG_MANAGER)',   'catalog@vending.local',  '0901000002', 'CATALOG_MANAGER'),
    ('operator',        N'Lê Vận Hành (OPERATOR)',            'duongthethinhforwork@gmail.com', '0901000003', 'OPERATOR'),
    ('reviewer',        N'Phạm Kiểm Duyệt (REVIEWER)',        'reviewer@vending.local', '0901000004', 'REVIEWER'),
    ('viewer',          N'Hoàng Khách Xem (VIEWER)',          'viewer@vending.local',   '0901000005', 'VIEWER')
) AS v(u, n, m, p, rc)
JOIN AppRole r ON r.role_code = v.rc;
GO

-- ===== 3. KHOI TAO THIET BI (5 MAY BAN HANG: 1 MAY THAT + 4 MAY MO PHONG) =====
INSERT INTO Device(device_code, api_key, mac_address, status, machine_name, location_name, is_hardware_demo) VALUES
    ('Vend-01', 'demo-key-vend-0001', '24:6F:28:B1:C2:A0', 'ACTIVE', N'Máy Thí Nghiệm Lab / Căn Tin FPTU', N'Tầng 1 - Căn tin trung tâm FPTU', 1),
    ('Vend-02', 'demo-key-vend-0002', '24:6F:28:B1:C2:A1', 'ACTIVE', N'Máy Sảnh Tòa Alpha', N'Tầng 1 - Sảnh chính Tòa Alpha', 0),
    ('Vend-03', 'demo-key-vend-0003', '24:6F:28:B1:C2:A2', 'ACTIVE', N'Máy Ký Túc Xá Dom A', N'Tầng trệt - Khu sinh hoạt chung Dom A', 0),
    ('Vend-04', 'demo-key-vend-0004', '24:6F:28:B1:C2:A3', 'ACTIVE', N'Máy Thư Viện Tòa Beta', N'Tầng 3 - Phòng tự học Thư viện', 0),
    ('Vend-05', 'demo-key-vend-0005', '24:6F:28:B1:C2:A4', 'ACTIVE', N'Máy Nhà Thi Đấu Thể Thao', N'Khu phức hợp thể thao đa năng', 0);
GO

-- ===== 4. KHOI TAO DANH MUC HANG & RANH LO XO =====
INSERT INTO Vend_Product(code, name, nominal_weight, tolerance, price, note, is_active) VALUES
    ('PRD-CANDY-01', N'Kẹo Alpenliebe Caramel (Gói 5 viên)', 25.00, 3.00, 5000, N'Gói kẹo nhỏ chuẩn đề tài, khối lượng danh định 25g', 1),
    ('PRD-CHOCO-02', N'Bánh Chocopie Orion 33g',             33.00, 3.50, 8000, N'Bánh Chocopie đóng gói 1 cái', 1),
    ('PRD-SNACK-03', N'Bim Bim Oishi Phồng Tôm 30g',          30.00, 4.00, 6000, N'Snack nhỏ túi mỏng', 1);
GO

DECLARE @dev1 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-01');
DECLARE @dev2 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-02');
DECLARE @dev3 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-03');
DECLARE @dev4 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-04');
DECLARE @dev5 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-05');

DECLARE @prd1 INT = (SELECT TOP 1 product_id FROM Vend_Product WHERE code = 'PRD-CANDY-01');
DECLARE @prd2 INT = (SELECT TOP 1 product_id FROM Vend_Product WHERE code = 'PRD-CHOCO-02');
DECLARE @prd3 INT = (SELECT TOP 1 product_id FROM Vend_Product WHERE code = 'PRD-SNACK-03');

INSERT INTO Vend_Slot(code, name, product_id, capacity, current_stock, is_suspended, note, is_active, device_id) VALUES
    ('SLOT-01',    N'Rãnh số 1 (Kẹo Alpenliebe)', @prd1, 10, 7, 0, N'Rãnh lò xo thép đơn quay bằng motor DC', 1, @dev1),
    ('SLOT-02',    N'Rãnh số 2 (Bánh Chocopie)',  @prd2,  8, 5, 0, N'Rãnh phụ kiểm thử', 1, @dev1),
    ('SLOT-M2-01', N'Rãnh M2-01 (Kẹo Alpenliebe)', @prd1, 10, 8, 0, N'Máy Sảnh Alpha', 1, @dev2),
    ('SLOT-M2-02', N'Rãnh M2-02 (Bánh Chocopie)',  @prd2, 10, 7, 0, N'Máy Sảnh Alpha', 1, @dev2),
    ('SLOT-M3-01', N'Rãnh M3-01 (Kẹo Alpenliebe)', @prd1, 10, 6, 0, N'Máy KTX Dom A', 1, @dev3),
    ('SLOT-M3-02', N'Rãnh M3-02 (Bánh Chocopie)',  @prd2, 10, 4, 1, N'Máy KTX Dom A - Bị kẹt', 1, @dev3),
    ('SLOT-M4-01', N'Rãnh M4-01 (Kẹo Alpenliebe)', @prd1, 10, 9, 0, N'Máy Thư Viện', 1, @dev4),
    ('SLOT-M5-01', N'Rãnh M5-01 (Bánh Chocopie)',  @prd2, 10, 10, 0, N'Máy Nhà Thi Đấu', 1, @dev5);
GO

-- ===== 5. SINH DU LIEU 240 PHIEN MAU THUC NGHIEM (IS_SAMPLE = 1) =====
DECLARE @dev INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-01');
DECLARE @slot INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = 'SLOT-01');
DECLARE @seq INT = ISNULL((SELECT MAX(device_seq) FROM Vend_Session WHERE device_id = @dev), 0);

-- A. SUCCESS: 120 phien mau (Nha hang thanh cong)
INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, ingested_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
SELECT
    @dev,
    @slot,
    @seq + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    DATEADD(SECOND, 0 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), GETDATE()),
    DATEADD(SECOND, 0 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), GETDATE()),
    CAST(120 + RAND(CHECKSUM(NEWID())) * 360 AS DECIMAL(8,2)) AS weight_before,
    CAST(145 + RAND(CHECKSUM(NEWID())) * 365 AS DECIMAL(8,2)) AS weight_after,
    CAST(23 + RAND(CHECKSUM(NEWID())) * 4 AS DECIMAL(8,2)) AS weight_delta, -- ~ 25g (+/- 2g)
    1 AS coil_turns,
    1800 + ABS(CHECKSUM(NEWID())) % 401 AS motor_ms,
    500 + ABS(CHECKSUM(NEWID())) % 401 AS settle_ms,
    CAST(35 + RAND(CHECKSUM(NEWID())) * 20 AS DECIMAL(8,2)) AS peak_delta,
    1
FROM (SELECT TOP (120) 1 AS x FROM sys.all_objects a CROSS JOIN sys.all_objects b) AS n;

SET @seq = @seq + 120;

INSERT INTO Vend_Label(session_id, label_code, source, labeled_by, reason)
SELECT s.session_id, 'SUCCESS', 'SYSTEM', NULL, N'Tự động phân loại: Nhả hàng thành công'
FROM Vend_Session s
LEFT JOIN Vend_Label l ON l.session_id = s.session_id
WHERE s.is_sample = 1 AND l.label_id IS NULL;

-- B. JAM: 40 phien mau (Ket hang, motor quay nhung khong roi hang)
INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, ingested_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
SELECT
    @dev,
    @slot,
    @seq + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    DATEADD(SECOND, -90000 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), GETDATE()),
    DATEADD(SECOND, -90000 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), GETDATE()),
    CAST(120 + RAND(CHECKSUM(NEWID())) * 360 AS DECIMAL(8,2)) AS weight_before,
    CAST(120 + RAND(CHECKSUM(NEWID())) * 360 AS DECIMAL(8,2)) AS weight_after,
    CAST(0.0 + RAND(CHECKSUM(NEWID())) * 0.5 AS DECIMAL(8,2)) AS weight_delta, -- ~ 0g (không rơi)
    1 AS coil_turns,
    1900 + ABS(CHECKSUM(NEWID())) % 401 AS motor_ms,
    500 + ABS(CHECKSUM(NEWID())) % 401 AS settle_ms,
    CAST(0.5 + RAND(CHECKSUM(NEWID())) * 1.5 AS DECIMAL(8,2)) AS peak_delta,
    1
FROM (SELECT TOP (40) 1 AS x FROM sys.all_objects a CROSS JOIN sys.all_objects b) AS n;

SET @seq = @seq + 40;

INSERT INTO Vend_Label(session_id, label_code, source, labeled_by, reason)
SELECT s.session_id, 'JAM', 'SYSTEM', NULL, N'Tự động phân loại: Kẹt hàng (Delta ~ 0g)'
FROM Vend_Session s
LEFT JOIN Vend_Label l ON l.session_id = s.session_id
WHERE s.is_sample = 1 AND l.label_id IS NULL;

-- C. WRONG_ITEM: 50 phien mau (Roi nhieu hon 1 goi hoac sai trong luong)
INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, ingested_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
SELECT
    @dev,
    @slot,
    @seq + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    DATEADD(SECOND, -180000 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), GETDATE()),
    DATEADD(SECOND, -180000 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), GETDATE()),
    CAST(120 + RAND(CHECKSUM(NEWID())) * 360 AS DECIMAL(8,2)) AS weight_before,
    CAST(170 + RAND(CHECKSUM(NEWID())) * 365 AS DECIMAL(8,2)) AS weight_after,
    CAST(48 + RAND(CHECKSUM(NEWID())) * 6 AS DECIMAL(8,2)) AS weight_delta, -- ~ 50g (rơi đúp 2 gói)
    1 AS coil_turns,
    2000 + ABS(CHECKSUM(NEWID())) % 401 AS motor_ms,
    500 + ABS(CHECKSUM(NEWID())) % 401 AS settle_ms,
    CAST(60 + RAND(CHECKSUM(NEWID())) * 30 AS DECIMAL(8,2)) AS peak_delta,
    1
FROM (SELECT TOP (50) 1 AS x FROM sys.all_objects a CROSS JOIN sys.all_objects b) AS n;

SET @seq = @seq + 50;

INSERT INTO Vend_Label(session_id, label_code, source, labeled_by, reason)
SELECT s.session_id, 'WRONG_ITEM', 'SYSTEM', NULL, N'Tự động phân loại: Sai khối lượng / Rơi đúp'
FROM Vend_Session s
LEFT JOIN Vend_Label l ON l.session_id = s.session_id
WHERE s.is_sample = 1 AND l.label_id IS NULL;

-- D. MOTOR_FAIL: 30 phien mau (Motor loi, quay qua cham hoac khong du vong)
INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, ingested_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
SELECT
    @dev,
    @slot,
    @seq + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
    DATEADD(SECOND, -270000 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), GETDATE()),
    DATEADD(SECOND, -270000 - 60 * (ROW_NUMBER() OVER (ORDER BY (SELECT NULL))), GETDATE()),
    CAST(120 + RAND(CHECKSUM(NEWID())) * 360 AS DECIMAL(8,2)) AS weight_before,
    CAST(120 + RAND(CHECKSUM(NEWID())) * 360 AS DECIMAL(8,2)) AS weight_after,
    CAST(0.0 AS DECIMAL(8,2)) AS weight_delta,
    0 AS coil_turns, -- Không quay đủ 1 vòng
    4200 + ABS(CHECKSUM(NEWID())) % 601 AS motor_ms, -- Quá thời gian 4000ms
    500 + ABS(CHECKSUM(NEWID())) % 401 AS settle_ms,
    CAST(0.0 AS DECIMAL(8,2)) AS peak_delta,
    1
FROM (SELECT TOP (30) 1 AS x FROM sys.all_objects a CROSS JOIN sys.all_objects b) AS n;

SET @seq = @seq + 30;

INSERT INTO Vend_Label(session_id, label_code, source, labeled_by, reason)
SELECT s.session_id, 'MOTOR_FAIL', 'SYSTEM', NULL, N'Tự động phân loại: Lỗi động cơ không quay đủ vòng'
FROM Vend_Session s
LEFT JOIN Vend_Label l ON l.session_id = s.session_id
WHERE s.is_sample = 1 AND l.label_id IS NULL;

-- ===== 6. GHI NHAN CANH BAO MAU HE THONG =====
INSERT INTO Vend_Alert(session_id, slot_id, rule_code, severity, message, status)
SELECT TOP 2 session_id, @slot, 'JAM_STREAK', 'CRITICAL', N'Rãnh SLOT-01 phát hiện kẹt hàng liên tiếp. Cần kiểm tra khay nhả.', 'OPEN'
FROM Vend_Session WHERE weight_delta <= 1.0 AND coil_turns = 1;

INSERT INTO Vend_Alert(session_id, slot_id, rule_code, severity, message, status)
SELECT TOP 1 session_id, @slot, 'MOTOR_WEAR', 'WARNING', N'Thời gian quay của động cơ rãnh SLOT-01 tăng bất thường (>4000ms). Cần bảo trì.', 'OPEN'
FROM Vend_Session WHERE motor_ms > 4000;

INSERT INTO Vend_Alert(session_id, slot_id, rule_code, severity, message, status)
VALUES (NULL, @slot, 'LOW_STOCK', 'WARNING', N'Rãnh SLOT-02 sắp hết hàng (còn dưới 3 gói). Cần nạp bổ sung.', 'OPEN');
GO

-- ===== 7. PHAN CONG QUYEN QUAN LY MAY BAN HANG (USER_DEVICE_ASSIGNMENT) =====
DECLARE @adminId INT = (SELECT TOP 1 user_id FROM AppUser WHERE username = 'admin');
DECLARE @op1 INT = (SELECT TOP 1 user_id FROM AppUser WHERE username = 'operator');
DECLARE @rev1 INT = (SELECT TOP 1 user_id FROM AppUser WHERE username = 'reviewer');

DECLARE @m1 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-01');
DECLARE @m2 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-02');
DECLARE @m3 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-03');

-- Operator quan ly Vend-01 (May that Lab) va Vend-02 (Sanh Alpha)
IF @op1 IS NOT NULL AND @m1 IS NOT NULL
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@op1, @m1, @adminId);

IF @op1 IS NOT NULL AND @m2 IS NOT NULL
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@op1, @m2, @adminId);

-- Reviewer kiem duyet nhan cho Vend-01 (May that Lab)
IF @rev1 IS NOT NULL AND @m1 IS NOT NULL
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@rev1, @m1, @adminId);
GO

-- Kiem tra tong so phien da sinh
SELECT l.label_code, COUNT(*) AS so_phien
FROM Vend_Session s 
JOIN Vend_Label l ON l.session_id = s.session_id
WHERE s.is_sample = 1
GROUP BY l.label_code
ORDER BY so_phien DESC;
GO
