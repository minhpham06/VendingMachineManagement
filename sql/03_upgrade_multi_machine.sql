-- =====================================================================
-- PRJ301 - Multi-Machine & Access Control Migration Script
-- Run this script if you already have an existing VendDB database
-- =====================================================================

USE VendDB;
GO

-- 1. Bổ sung cột cho bảng Device
IF COL_LENGTH('Device', 'machine_name') IS NULL
BEGIN
    ALTER TABLE Device ADD machine_name NVARCHAR(100) NULL;
END
GO

IF COL_LENGTH('Device', 'location_name') IS NULL
BEGIN
    ALTER TABLE Device ADD location_name NVARCHAR(150) NULL;
END
GO

IF COL_LENGTH('Device', 'is_hardware_demo') IS NULL
BEGIN
    ALTER TABLE Device ADD is_hardware_demo BIT NOT NULL DEFAULT 0;
END
GO

-- 2. Bổ sung cột device_id cho bảng Vend_Slot (nếu chưa có)
IF COL_LENGTH('Vend_Slot', 'device_id') IS NULL
BEGIN
    ALTER TABLE Vend_Slot ADD device_id INT NULL FOREIGN KEY REFERENCES Device(device_id);
END
GO

-- 3. Tạo bảng User_Device_Assignment (Phân công quyền quản lý máy)
IF OBJECT_ID('User_Device_Assignment', 'U') IS NULL
BEGIN
    CREATE TABLE User_Device_Assignment (
        assignment_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id       INT NOT NULL FOREIGN KEY REFERENCES AppUser(user_id),
        device_id     INT NOT NULL FOREIGN KEY REFERENCES Device(device_id),
        assigned_by   INT NOT NULL FOREIGN KEY REFERENCES AppUser(user_id),
        assigned_at   DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT UQ_User_Device UNIQUE (user_id, device_id)
    );
END
GO

-- 4. Cập nhật và khởi tạo 5 máy bán hàng (1 máy thật + 4 máy mô phỏng)
-- Cập nhật Vend-01 là máy thật
UPDATE Device 
SET machine_name = N'Máy Thí Nghiệm Lab / Căn Tin FPTU',
    location_name = N'Tầng 1 - Căn tin trung tâm FPTU',
    is_hardware_demo = 1
WHERE device_code = 'Vend-01';

-- Cập nhật Vend-02
UPDATE Device 
SET machine_name = N'Máy Sảnh Tòa Alpha',
    location_name = N'Tầng 1 - Sảnh chính Tòa Alpha',
    is_hardware_demo = 0
WHERE device_code = 'Vend-02';

-- Thêm Vend-03, Vend-04, Vend-05 nếu chưa có
IF NOT EXISTS (SELECT 1 FROM Device WHERE device_code = 'Vend-03')
BEGIN
    INSERT INTO Device(device_code, api_key, mac_address, status, machine_name, location_name, is_hardware_demo)
    VALUES ('Vend-03', 'demo-key-vend-0003', '24:6F:28:B1:C2:A2', 'ACTIVE', N'Máy Ký Túc Xá Dom A', N'Tầng trệt - Khu sinh hoạt chung Dom A', 0);
END
ELSE
BEGIN
    UPDATE Device 
    SET machine_name = N'Máy Ký Túc Xá Dom A',
        location_name = N'Tầng trệt - Khu sinh hoạt chung Dom A',
        is_hardware_demo = 0
    WHERE device_code = 'Vend-03';
END
GO

IF NOT EXISTS (SELECT 1 FROM Device WHERE device_code = 'Vend-04')
BEGIN
    INSERT INTO Device(device_code, api_key, mac_address, status, machine_name, location_name, is_hardware_demo)
    VALUES ('Vend-04', 'demo-key-vend-0004', '24:6F:28:B1:C2:A3', 'ACTIVE', N'Máy Thư Viện Tòa Beta', N'Tầng 3 - Phòng tự học Thư viện', 0);
END
ELSE
BEGIN
    UPDATE Device 
    SET machine_name = N'Máy Thư Viện Tòa Beta',
        location_name = N'Tầng 3 - Phòng tự học Thư viện',
        is_hardware_demo = 0
    WHERE device_code = 'Vend-04';
END
GO

IF NOT EXISTS (SELECT 1 FROM Device WHERE device_code = 'Vend-05')
BEGIN
    INSERT INTO Device(device_code, api_key, mac_address, status, machine_name, location_name, is_hardware_demo)
    VALUES ('Vend-05', 'demo-key-vend-0005', '24:6F:28:B1:C2:A4', 'ACTIVE', N'Máy Nhà Thi Đấu Thể Thao', N'Khu phức hợp thể thao đa năng', 0);
END
ELSE
BEGIN
    UPDATE Device 
    SET machine_name = N'Máy Nhà Thi Đấu Thể Thao',
        location_name = N'Khu phức hợp thể thao đa năng',
        is_hardware_demo = 0
    WHERE device_code = 'Vend-05';
END
GO

-- 5. Gán toàn bộ rãnh hàng cũ về cho máy thật (Vend-01)
DECLARE @demoDeviceId INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-01');
UPDATE Vend_Slot SET device_id = @demoDeviceId WHERE device_id IS NULL;
GO

-- 6. Khởi tạo rãnh hàng mẫu cho các máy ảo nếu chưa có
DECLARE @d2 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-02');
DECLARE @d3 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-03');
DECLARE @d4 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-04');
DECLARE @d5 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-05');

DECLARE @p1 INT = (SELECT TOP 1 product_id FROM Vend_Product WHERE code = 'PRD-CANDY-01');
DECLARE @p2 INT = (SELECT TOP 1 product_id FROM Vend_Product WHERE code = 'PRD-CHOCO-02');
DECLARE @p3 INT = (SELECT TOP 1 product_id FROM Vend_Product WHERE code = 'PRD-SNACK-03');

IF NOT EXISTS (SELECT 1 FROM Vend_Slot WHERE device_id = @d2)
BEGIN
    INSERT INTO Vend_Slot(code, name, product_id, capacity, current_stock, is_suspended, note, is_active, device_id) VALUES
    ('SLOT-M2-01', N'Rãnh M2-01 (Kẹo Alpenliebe)', @p1, 10, 8, 0, N'Máy Sảnh Alpha', 1, @d2),
    ('SLOT-M2-02', N'Rãnh M2-02 (Bánh Chocopie)',  @p2, 10, 7, 0, N'Máy Sảnh Alpha', 1, @d2),
    ('SLOT-M2-03', N'Rãnh M2-03 (Bim Bim Oishi)',   @p3,  8, 5, 0, N'Máy Sảnh Alpha', 1, @d2);
END

IF NOT EXISTS (SELECT 1 FROM Vend_Slot WHERE device_id = @d3)
BEGIN
    INSERT INTO Vend_Slot(code, name, product_id, capacity, current_stock, is_suspended, note, is_active, device_id) VALUES
    ('SLOT-M3-01', N'Rãnh M3-01 (Kẹo Alpenliebe)', @p1, 10, 6, 0, N'Máy KTX Dom A', 1, @d3),
    ('SLOT-M3-02', N'Rãnh M3-02 (Bánh Chocopie)',  @p2, 10, 4, 1, N'Máy KTX Dom A - Bị kẹt', 1, @d3),
    ('SLOT-M3-03', N'Rãnh M3-03 (Bim Bim Oishi)',   @p3,  8, 3, 0, N'Máy KTX Dom A', 1, @d3);
END

IF NOT EXISTS (SELECT 1 FROM Vend_Slot WHERE device_id = @d4)
BEGIN
    INSERT INTO Vend_Slot(code, name, product_id, capacity, current_stock, is_suspended, note, is_active, device_id) VALUES
    ('SLOT-M4-01', N'Rãnh M4-01 (Kẹo Alpenliebe)', @p1, 10, 9, 0, N'Máy Thư Viện', 1, @d4),
    ('SLOT-M4-02', N'Rãnh M4-02 (Bánh Chocopie)',  @p2, 10, 9, 0, N'Máy Thư Viện', 1, @d4);
END

IF NOT EXISTS (SELECT 1 FROM Vend_Slot WHERE device_id = @d5)
BEGIN
    INSERT INTO Vend_Slot(code, name, product_id, capacity, current_stock, is_suspended, note, is_active, device_id) VALUES
    ('SLOT-M5-01', N'Rãnh M5-01 (Bánh Chocopie)',  @p2, 10, 10, 0, N'Máy Nhà Thi Đấu', 1, @d5),
    ('SLOT-M5-02', N'Rãnh M5-02 (Bim Bim Oishi)',   @p3,  8,  7, 0, N'Máy Nhà Thi Đấu', 1, @d5);
END
GO

-- 7. Thêm tài khoản Operator2 và Reviewer2 để test phân quyền nhiều tài khoản
DECLARE @h VARCHAR(200) = '20000:a0dee5aba0d8cc258ed13fa22d6b729e:7cc4e6fd505db9217ae726189980404174314d771379ca4d98798889d015a124';
DECLARE @roleOp INT = (SELECT role_id FROM AppRole WHERE role_code = 'OPERATOR');
DECLARE @roleRev INT = (SELECT role_id FROM AppRole WHERE role_code = 'REVIEWER');

IF NOT EXISTS (SELECT 1 FROM AppUser WHERE username = 'operator2')
BEGIN
    INSERT INTO AppUser(username, pass_hash, full_name, email, phone, role_id, is_locked)
    VALUES ('operator2', @h, N'Đỗ Vận Hành 2 (OPERATOR-2)', 'operator2@vending.local', '0901000006', @roleOp, 0);
END

IF NOT EXISTS (SELECT 1 FROM AppUser WHERE username = 'reviewer2')
BEGIN
    INSERT INTO AppUser(username, pass_hash, full_name, email, phone, role_id, is_locked)
    VALUES ('reviewer2', @h, N'Hoàng Kiểm Duyệt 2 (REVIEWER-2)', 'reviewer2@vending.local', '0901000007', @roleRev, 0);
END
GO

-- 8. Gán quyền mặc định (Sample Assignments)
DECLARE @adminId INT = (SELECT TOP 1 user_id FROM AppUser WHERE username = 'admin');
DECLARE @op1 INT = (SELECT TOP 1 user_id FROM AppUser WHERE username = 'operator');
DECLARE @op2 INT = (SELECT TOP 1 user_id FROM AppUser WHERE username = 'operator2');
DECLARE @rev1 INT = (SELECT TOP 1 user_id FROM AppUser WHERE username = 'reviewer');
DECLARE @rev2 INT = (SELECT TOP 1 user_id FROM AppUser WHERE username = 'reviewer2');

DECLARE @dev1 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-01');
DECLARE @dev2 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-02');
DECLARE @dev3 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-03');
DECLARE @dev4 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-04');
DECLARE @dev5 INT = (SELECT TOP 1 device_id FROM Device WHERE device_code = 'Vend-05');

-- Operator 1: Quản lý Vend-01 (Máy thật) và Vend-02
IF @op1 IS NOT NULL AND @dev1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM User_Device_Assignment WHERE user_id = @op1 AND device_id = @dev1)
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@op1, @dev1, @adminId);

IF @op1 IS NOT NULL AND @dev2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM User_Device_Assignment WHERE user_id = @op1 AND device_id = @dev2)
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@op1, @dev2, @adminId);

-- Operator 2: Quản lý Vend-03 (KTX), Vend-04 (Thư viện), Vend-05 (Nhà thi đấu)
IF @op2 IS NOT NULL AND @dev3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM User_Device_Assignment WHERE user_id = @op2 AND device_id = @dev3)
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@op2, @dev3, @adminId);

IF @op2 IS NOT NULL AND @dev4 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM User_Device_Assignment WHERE user_id = @op2 AND device_id = @dev4)
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@op2, @dev4, @adminId);

IF @op2 IS NOT NULL AND @dev5 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM User_Device_Assignment WHERE user_id = @op2 AND device_id = @dev5)
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@op2, @dev5, @adminId);

-- Reviewer 1: Kiểm duyệt cho Vend-01
IF @rev1 IS NOT NULL AND @dev1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM User_Device_Assignment WHERE user_id = @rev1 AND device_id = @dev1)
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@rev1, @dev1, @adminId);

-- Reviewer 2: Kiểm duyệt cho Vend-02 và Vend-03
IF @rev2 IS NOT NULL AND @dev2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM User_Device_Assignment WHERE user_id = @rev2 AND device_id = @dev2)
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@rev2, @dev2, @adminId);

IF @rev2 IS NOT NULL AND @dev3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM User_Device_Assignment WHERE user_id = @rev2 AND device_id = @dev3)
    INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (@rev2, @dev3, @adminId);

-- 9. Sinh dữ liệu phiên mẫu cho các máy ảo (Vend-02 đến Vend-05)
IF NOT EXISTS (SELECT 1 FROM Vend_Session WHERE device_id = @dev2)
BEGIN
    DECLARE @s2_1 INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = 'SLOT-M2-01');
    DECLARE @s2_2 INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = 'SLOT-M2-02');
    
    -- Vend-02 (Sảnh Alpha): 12 phiên SUCCESS, 2 phiên JAM, 1 phiên WRONG_ITEM
    INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, ingested_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
    VALUES
    (@dev2, @s2_1, 1, DATEADD(MINUTE, -120, GETDATE()), DATEADD(MINUTE, -120, GETDATE()), 150.0, 175.2, 25.2, 1, 1850, 520, 38.5, 1),
    (@dev2, @s2_1, 2, DATEADD(MINUTE, -100, GETDATE()), DATEADD(MINUTE, -100, GETDATE()), 175.2, 200.1, 24.9, 1, 1820, 510, 39.0, 1),
    (@dev2, @s2_1, 3, DATEADD(MINUTE,  -85, GETDATE()), DATEADD(MINUTE,  -85, GETDATE()), 200.1, 225.5, 25.4, 1, 1860, 530, 40.2, 1),
    (@dev2, @s2_2, 4, DATEADD(MINUTE,  -70, GETDATE()), DATEADD(MINUTE,  -70, GETDATE()), 225.5, 258.8, 33.3, 1, 1900, 540, 45.0, 1),
    (@dev2, @s2_2, 5, DATEADD(MINUTE,  -55, GETDATE()), DATEADD(MINUTE,  -55, GETDATE()), 258.8, 259.0,  0.2, 1, 2200, 560, 12.0, 1), -- JAM
    (@dev2, @s2_1, 6, DATEADD(MINUTE,  -40, GETDATE()), DATEADD(MINUTE,  -40, GETDATE()), 259.0, 284.1, 25.1, 1, 1830, 515, 37.8, 1),
    (@dev2, @s2_2, 7, DATEADD(MINUTE,  -25, GETDATE()), DATEADD(MINUTE,  -25, GETDATE()), 284.1, 317.0, 32.9, 1, 1890, 535, 44.5, 1),
    (@dev2, @s2_1, 8, DATEADD(MINUTE,  -10, GETDATE()), DATEADD(MINUTE,  -10, GETDATE()), 317.0, 332.0, 15.0, 1, 1840, 520, 25.0, 1); -- WRONG_ITEM
END

IF NOT EXISTS (SELECT 1 FROM Vend_Session WHERE device_id = @dev3)
BEGIN
    DECLARE @s3_1 INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = 'SLOT-M3-01');
    DECLARE @s3_2 INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = 'SLOT-M3-02');
    
    -- Vend-03 (KTX Dom A): 4 phiên SUCCESS, 4 phiên JAM liên tiếp (rãnh kẹt), 1 phiên MOTOR_FAIL
    INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, ingested_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
    VALUES
    (@dev3, @s3_1, 1, DATEADD(MINUTE, -180, GETDATE()), DATEADD(MINUTE, -180, GETDATE()), 100.0, 125.1, 25.1, 1, 1810, 510, 38.0, 1),
    (@dev3, @s3_1, 2, DATEADD(MINUTE, -150, GETDATE()), DATEADD(MINUTE, -150, GETDATE()), 125.1, 150.3, 25.2, 1, 1830, 515, 39.2, 1),
    (@dev3, @s3_2, 3, DATEADD(MINUTE, -120, GETDATE()), DATEADD(MINUTE, -120, GETDATE()), 150.3, 150.5,  0.2, 1, 2400, 600, 10.5, 1), -- JAM 1
    (@dev3, @s3_2, 4, DATEADD(MINUTE,  -90, GETDATE()), DATEADD(MINUTE,  -90, GETDATE()), 150.5, 150.6,  0.1, 1, 2600, 620,  8.0, 1), -- JAM 2
    (@dev3, @s3_2, 5, DATEADD(MINUTE,  -60, GETDATE()), DATEADD(MINUTE,  -60, GETDATE()), 150.6, 150.8,  0.2, 1, 4500, 700,  5.0, 1), -- JAM 3 + MOTOR_WEAR
    (@dev3, @s3_1, 6, DATEADD(MINUTE,  -30, GETDATE()), DATEADD(MINUTE,  -30, GETDATE()), 150.8, 175.7, 24.9, 1, 1820, 510, 38.5, 1),
    (@dev3, @s3_1, 7, DATEADD(MINUTE,  -15, GETDATE()), DATEADD(MINUTE,  -15, GETDATE()), 175.7, 201.0, 25.3, 1, 1840, 520, 39.0, 1);
END

IF NOT EXISTS (SELECT 1 FROM Vend_Session WHERE device_id = @dev4)
BEGIN
    DECLARE @s4_1 INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = 'SLOT-M4-01');
    DECLARE @s4_2 INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = 'SLOT-M4-02');
    
    -- Vend-04 (Thư Viện Beta): Hoạt động ổn định
    INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, ingested_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
    VALUES
    (@dev4, @s4_1, 1, DATEADD(MINUTE, -90, GETDATE()), DATEADD(MINUTE, -90, GETDATE()), 110.0, 135.2, 25.2, 1, 1820, 510, 38.0, 1),
    (@dev4, @s4_2, 2, DATEADD(MINUTE, -60, GETDATE()), DATEADD(MINUTE, -60, GETDATE()), 135.2, 168.1, 32.9, 1, 1890, 530, 44.0, 1),
    (@dev4, @s4_1, 3, DATEADD(MINUTE, -30, GETDATE()), DATEADD(MINUTE, -30, GETDATE()), 168.1, 193.0, 24.9, 1, 1810, 505, 37.5, 1);
END

IF NOT EXISTS (SELECT 1 FROM Vend_Session WHERE device_id = @dev5)
BEGIN
    DECLARE @s5_1 INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = 'SLOT-M5-01');
    DECLARE @s5_2 INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = 'SLOT-M5-02');
    
    -- Vend-05 (Nhà Thi Đấu): Bánh Chocopie & Bim Bim Oishi
    INSERT INTO Vend_Session(device_id, slot_id, device_seq, measured_at, ingested_at, weight_before, weight_after, weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample)
    VALUES
    (@dev5, @s5_1, 1, DATEADD(MINUTE, -80, GETDATE()), DATEADD(MINUTE, -80, GETDATE()), 200.0, 233.1, 33.1, 1, 1880, 530, 44.5, 1),
    (@dev5, @s5_2, 2, DATEADD(MINUTE, -45, GETDATE()), DATEADD(MINUTE, -45, GETDATE()), 233.1, 263.2, 30.1, 1, 1850, 520, 42.0, 1),
    (@dev5, @s5_1, 3, DATEADD(MINUTE, -10, GETDATE()), DATEADD(MINUTE, -10, GETDATE()), 263.2, 296.3, 33.1, 1, 1890, 535, 45.2, 1);
END

-- 10. Gán nhãn tương ứng cho các session mới chưa có nhãn
INSERT INTO Vend_Label(session_id, label_code, source, reason)
SELECT 
    s.session_id,
    CASE 
        WHEN s.motor_ms > 4000 THEN 'MOTOR_FAIL'
        WHEN s.weight_delta <= 1.0 THEN 'JAM'
        WHEN s.weight_delta < 20.0 THEN 'WRONG_ITEM'
        ELSE 'SUCCESS'
    END,
    'SYSTEM',
    N'Tự động phân loại dựa trên trọng lượng loadcell và cảm biến dòng motor'
FROM Vend_Session s
LEFT JOIN Vend_Label l ON l.session_id = s.session_id
WHERE l.label_id IS NULL;

-- 11. Cảnh báo mẫu cho Máy KTX Dom A (Vend-03)
DECLARE @slotJam3 INT = (SELECT TOP 1 slot_id FROM Vend_Slot WHERE code = 'SLOT-M3-02');
IF @slotJam3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Vend_Alert WHERE slot_id = @slotJam3)
BEGIN
    INSERT INTO Vend_Alert(session_id, slot_id, rule_code, severity, message, status) VALUES
    (NULL, @slotJam3, 'JAM_STREAK', 'CRITICAL', N'Máy KTX Dom A: Rãnh SLOT-M3-02 kẹt hàng 3 phiên liên tiếp. Đã tự động tạm ngưng rãnh.', 'OPEN'),
    (NULL, @slotJam3, 'MOTOR_WEAR', 'WARNING', N'Máy KTX Dom A: Động cơ quay quá 4000ms. Cần kiểm tra lò xo.', 'OPEN');
END
GO

-- 12. Cập nhật email nhận cảnh báo thực tế cho nhân viên vận hành (Lê Vận Hành)
UPDATE AppUser 
SET email = 'duongthethinhforwork@gmail.com' 
WHERE username = 'operator';
GO

PRINT 'SUCCESS: Multi-machine database schema, sample sessions and assignments updated successfully!';
GO

