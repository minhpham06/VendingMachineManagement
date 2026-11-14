-- ============================================================
-- VendDB - PRJ301 Fall 2026 - Topic 01: Miniature Vending Machine
-- Run this script in SQL Server Management Studio to create VendDB and tables
-- Chuẩn hóa 100% theo các lớp DAO/Model Java trong dự án
-- ============================================================

IF DB_ID('VendDB') IS NULL
    CREATE DATABASE VendDB;
GO

USE VendDB;
GO

-- 1. AppRole (Bảng vai trò người dùng)
IF OBJECT_ID('AppRole', 'U') IS NULL
CREATE TABLE AppRole (
    role_id     INT IDENTITY(1,1) PRIMARY KEY,
    role_code   VARCHAR(32) NOT NULL UNIQUE,
    role_name   NVARCHAR(100) NOT NULL,
    description NVARCHAR(255) NULL
);
GO

-- 2. AppUser (Bảng tài khoản người dùng, mật khẩu băm PBKDF2)
IF OBJECT_ID('AppUser', 'U') IS NULL
CREATE TABLE AppUser (
    user_id     INT IDENTITY(1,1) PRIMARY KEY,
    username    VARCHAR(50) NOT NULL UNIQUE,
    pass_hash   VARCHAR(200) NOT NULL,
    full_name   NVARCHAR(100) NOT NULL,
    email       VARCHAR(100) NULL,
    phone       VARCHAR(20) NULL,
    role_id     INT NOT NULL FOREIGN KEY REFERENCES AppRole(role_id),
    is_locked   BIT NOT NULL DEFAULT 0,
    created_at  DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 3. Device (Bảng thiết bị vi điều khiển ESP32 / Máy bán hàng)
IF OBJECT_ID('Device', 'U') IS NULL
CREATE TABLE Device (
    device_id        INT IDENTITY(1,1) PRIMARY KEY,
    device_code      VARCHAR(32) NOT NULL UNIQUE,
    api_key          VARCHAR(64) NOT NULL,
    mac_address      VARCHAR(32) NULL,
    status           VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    machine_name     NVARCHAR(100) NULL,
    location_name    NVARCHAR(150) NULL,
    is_hardware_demo BIT NOT NULL DEFAULT 0, -- 1: Máy thật kết nối ESP32, 0: Máy mô phỏng
    created_at       DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 4. Vend_Product (Bảng mặt hàng bán tự động)
IF OBJECT_ID('Vend_Product', 'U') IS NULL
CREATE TABLE Vend_Product (
    product_id     INT IDENTITY(1,1) PRIMARY KEY,
    code           VARCHAR(32) NOT NULL UNIQUE,
    name           NVARCHAR(100) NOT NULL,
    nominal_weight DECIMAL(8,2) NOT NULL, -- Khối lượng danh định (g)
    tolerance      DECIMAL(8,2) NOT NULL DEFAULT 3.0, -- Dung sai cho phép (g)
    price          DECIMAL(10,2) NOT NULL DEFAULT 0.0, -- Đơn giá (VNĐ)
    note           NVARCHAR(255) NULL,
    is_active      BIT NOT NULL DEFAULT 1,
    created_at     DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 5. Vend_Slot (Bảng rãnh lò xo chứa hàng)
IF OBJECT_ID('Vend_Slot', 'U') IS NULL
CREATE TABLE Vend_Slot (
    slot_id       INT IDENTITY(1,1) PRIMARY KEY,
    device_id     INT NULL FOREIGN KEY REFERENCES Device(device_id),
    code          VARCHAR(16) NOT NULL, -- Mã rãnh: SLOT-01, SLOT-02...
    name          NVARCHAR(100) NOT NULL,
    product_id    INT NULL FOREIGN KEY REFERENCES Vend_Product(product_id),
    capacity      INT NOT NULL DEFAULT 10,
    current_stock INT NOT NULL DEFAULT 0,
    is_suspended  BIT NOT NULL DEFAULT 0, -- 1: Tạm ngưng (kẹt hàng), 0: Hoạt động
    note          NVARCHAR(255) NULL,
    is_active     BIT NOT NULL DEFAULT 1,
    created_at    DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 6. Vend_Restock (Bảng phiếu nạp hàng vào rãnh)
IF OBJECT_ID('Vend_Restock', 'U') IS NULL
CREATE TABLE Vend_Restock (
    restock_id   INT IDENTITY(1,1) PRIMARY KEY,
    code         VARCHAR(32) NOT NULL UNIQUE,
    slot_id      INT NOT NULL FOREIGN KEY REFERENCES Vend_Slot(slot_id),
    product_id   INT NULL FOREIGN KEY REFERENCES Vend_Product(product_id),
    quantity     INT NOT NULL,
    restocked_by INT NOT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    note         NVARCHAR(255) NULL,
    is_active    BIT NOT NULL DEFAULT 1,
    created_at   DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 7. Vend_Session (Bảng phiên đo nhả hàng thực nghiệm / thực tế)
IF OBJECT_ID('Vend_Session', 'U') IS NULL
CREATE TABLE Vend_Session (
    session_id    INT IDENTITY(1,1) PRIMARY KEY,
    device_id     INT NOT NULL FOREIGN KEY REFERENCES Device(device_id),
    slot_id       INT NOT NULL FOREIGN KEY REFERENCES Vend_Slot(slot_id),
    device_seq    INT NOT NULL, -- Số thứ tự gói tin từ ESP32
    measured_at   DATETIME NOT NULL DEFAULT GETDATE(),
    ingested_at   DATETIME NOT NULL DEFAULT GETDATE(),
    weight_before DECIMAL(8,2) NOT NULL, -- Khối lượng trước khi nhả (g)
    weight_after  DECIMAL(8,2) NOT NULL, -- Khối lượng sau khi nhả ổn định (g)
    weight_delta  DECIMAL(8,2) NOT NULL, -- Chênh lệch khối lượng thực nhận (g)
    coil_turns    INT NOT NULL DEFAULT 1, -- Số vòng quay lò xo
    motor_ms      INT NOT NULL DEFAULT 0, -- Thời gian motor quay (ms)
    settle_ms     INT NOT NULL DEFAULT 0, -- Thời gian cân ổn định (ms)
    peak_delta    DECIMAL(8,2) NOT NULL DEFAULT 0.0, -- Xung lực đỉnh lúc rơi (g)
    is_sample     BIT NOT NULL DEFAULT 1, -- 1: Dữ liệu mẫu thực nghiệm, 0: Khách mua thật
    CONSTRAINT UQ_Device_Seq UNIQUE (device_id, device_seq)
);
GO

-- 8. Vend_Label (Bảng gán nhãn kết quả phiên đo)
IF OBJECT_ID('Vend_Label', 'U') IS NULL
CREATE TABLE Vend_Label (
    label_id   INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL FOREIGN KEY REFERENCES Vend_Session(session_id),
    label_code VARCHAR(32) NOT NULL, -- 'SUCCESS', 'JAM', 'WRONG_ITEM', 'MOTOR_FAIL'
    source     VARCHAR(20) NOT NULL DEFAULT 'SYSTEM', -- 'SYSTEM', 'REVIEWER', 'RULE'
    labeled_by INT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    reason     NVARCHAR(255) NULL,
    labeled_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 9. Vend_Alert (Bảng cảnh báo thông minh hệ thống)
IF OBJECT_ID('Vend_Alert', 'U') IS NULL
CREATE TABLE Vend_Alert (
    alert_id     INT IDENTITY(1,1) PRIMARY KEY,
    session_id   INT NULL FOREIGN KEY REFERENCES Vend_Session(session_id),
    slot_id      INT NULL FOREIGN KEY REFERENCES Vend_Slot(slot_id),
    rule_code    VARCHAR(32) NOT NULL, -- 'JAM_STREAK', 'LOW_STOCK', 'WEIGHT_DRIFT', 'MOTOR_WEAR', 'JAM_DETECTED', 'MOTOR_TIMEOUT'
    severity     VARCHAR(16) NOT NULL DEFAULT 'WARNING', -- 'INFO', 'WARNING', 'CRITICAL'
    message      NVARCHAR(255) NOT NULL,
    status       VARCHAR(20) NOT NULL DEFAULT 'OPEN', -- 'OPEN', 'RESOLVED'
    handled_by   INT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    handled_note NVARCHAR(255) NULL,
    created_at   DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 10. RejectedPacket (Bảng lưu các gói tin lỗi / bất thường từ ESP32)
IF OBJECT_ID('RejectedPacket', 'U') IS NULL
CREATE TABLE RejectedPacket (
    reject_id   INT IDENTITY(1,1) PRIMARY KEY,
    device_id   INT NULL FOREIGN KEY REFERENCES Device(device_id),
    raw_payload NVARCHAR(1000) NULL,
    reason      NVARCHAR(255) NOT NULL,
    received_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 11. User_Device_Assignment (Bảng phân quyền quản lý máy cho nhân viên)
IF OBJECT_ID('User_Device_Assignment', 'U') IS NULL
CREATE TABLE User_Device_Assignment (
    assignment_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id       INT NOT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    device_id     INT NOT NULL FOREIGN KEY REFERENCES Device(device_id),
    assigned_by   INT NOT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    assigned_at   DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_User_Device UNIQUE (user_id, device_id)
);
GO

