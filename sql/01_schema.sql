-- ============================================================
-- VendDB - PRJ301 Fall 2026 - Topic 01: Miniature Vending Machine
-- Run this script in SQL Server Management Studio to create VendDB and tables
-- ============================================================

IF DB_ID('VendDB') IS NULL
    CREATE DATABASE VendDB;
GO

USE VendDB;
GO

-- 1. AppRole
IF OBJECT_ID('AppRole', 'U') IS NULL
CREATE TABLE AppRole (
    role_id     INT IDENTITY(1,1) PRIMARY KEY,
    role_code   VARCHAR(32) NOT NULL UNIQUE,
    role_name   NVARCHAR(100) NOT NULL,
    description NVARCHAR(255) NULL
);
GO

-- 2. AppUser
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

-- 3. Device
IF OBJECT_ID('Device', 'U') IS NULL
CREATE TABLE Device (
    device_id   INT IDENTITY(1,1) PRIMARY KEY,
    device_code VARCHAR(32) NOT NULL UNIQUE,
    api_key     VARCHAR(64) NOT NULL,
    mac_address VARCHAR(32) NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at  DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 4. Vend_Product
IF OBJECT_ID('Vend_Product', 'U') IS NULL
CREATE TABLE Vend_Product (
    product_id          INT IDENTITY(1,1) PRIMARY KEY,
    product_name        NVARCHAR(100) NOT NULL,
    nominal_weight_g    DECIMAL(8,2) NOT NULL, -- Khoi luong danh dinh
    tolerance_g         DECIMAL(8,2) NOT NULL DEFAULT 3.0, -- Dung sai cho phep
    unit_price          DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    is_active           BIT NOT NULL DEFAULT 1,
    created_at          DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 5. Vend_Slot
IF OBJECT_ID('Vend_Slot', 'U') IS NULL
CREATE TABLE Vend_Slot (
    slot_id     INT IDENTITY(1,1) PRIMARY KEY,
    device_id   INT NOT NULL FOREIGN KEY REFERENCES Device(device_id),
    slot_code   VARCHAR(16) NOT NULL, -- 'SLOT-01'
    product_id  INT NULL FOREIGN KEY REFERENCES Vend_Product(product_id),
    capacity    INT NOT NULL DEFAULT 10,
    stock_qty   INT NOT NULL DEFAULT 0,
    status      VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- 'ACTIVE', 'SUSPENDED'
    CONSTRAINT UQ_Device_Slot UNIQUE (device_id, slot_code)
);
GO

-- 6. Vend_Restock
IF OBJECT_ID('Vend_Restock', 'U') IS NULL
CREATE TABLE Vend_Restock (
    restock_id   INT IDENTITY(1,1) PRIMARY KEY,
    slot_id      INT NOT NULL FOREIGN KEY REFERENCES Vend_Slot(slot_id),
    quantity     INT NOT NULL,
    operator_id  INT NOT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    note         NVARCHAR(255) NULL,
    restocked_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 7. Vend_Session
IF OBJECT_ID('Vend_Session', 'U') IS NULL
CREATE TABLE Vend_Session (
    session_id          INT IDENTITY(1,1) PRIMARY KEY,
    device_id           INT NOT NULL FOREIGN KEY REFERENCES Device(device_id),
    slot_id             INT NOT NULL FOREIGN KEY REFERENCES Vend_Slot(slot_id),
    seq_num             INT NOT NULL,
    motor_done          BIT NOT NULL, -- 1: Quay du 1 vong, 0: Khong quay duong
    rotation_time_ms    INT NOT NULL, -- Thoi gian dong co quay (ms)
    weight_before_g     DECIMAL(8,2) NOT NULL, -- Khoi luong truoc khi nha
    weight_peak_g       DECIMAL(8,2) NOT NULL, -- Khoi luong dinh luc roi
    weight_after_g      DECIMAL(8,2) NOT NULL, -- Khoi luong sau khi nha on dinh
    ambient_temp_c      DECIMAL(5,2) NULL, -- Nhiet do moi truong
    is_sample           BIT NOT NULL DEFAULT 1, -- 1: Mau, 0: Thuc nghiem that
    created_at          DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Device_Seq UNIQUE (device_id, seq_num)
);
GO

-- 8. Vend_Label
IF OBJECT_ID('Vend_Label', 'U') IS NULL
CREATE TABLE Vend_Label (
    label_id    INT IDENTITY(1,1) PRIMARY KEY,
    session_id  INT NOT NULL FOREIGN KEY REFERENCES Vend_Session(session_id),
    label_code  VARCHAR(32) NOT NULL, -- 'SUCCESS', 'JAM', 'WRONG_ITEM', 'MOTOR_FAIL'
    source      VARCHAR(20) NOT NULL, -- 'SYSTEM', 'REVIEWER'
    reviewer_id INT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    reason      NVARCHAR(255) NULL, -- Ly do sua (toi thieu 5 ky tu khi REVIEWER sua)
    labeled_at  DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 9. Vend_Alert
IF OBJECT_ID('Vend_Alert', 'U') IS NULL
CREATE TABLE Vend_Alert (
    alert_id     INT IDENTITY(1,1) PRIMARY KEY,
    device_id    INT NOT NULL FOREIGN KEY REFERENCES Device(device_id),
    slot_id      INT NULL FOREIGN KEY REFERENCES Vend_Slot(slot_id),
    session_id   INT NULL FOREIGN KEY REFERENCES Vend_Session(session_id),
    alert_type   VARCHAR(32) NOT NULL, -- 'JAM_STREAK', 'LOW_STOCK', 'WEIGHT_DRIFT', 'MOTOR_WEAR'
    severity     VARCHAR(16) NOT NULL DEFAULT 'WARNING', -- 'INFO', 'WARNING', 'CRITICAL'
    message      NVARCHAR(255) NOT NULL,
    is_resolved  BIT NOT NULL DEFAULT 0,
    resolved_by  INT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    resolved_at  DATETIME NULL,
    created_at   DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 10. RejectedPacket
IF OBJECT_ID('RejectedPacket', 'U') IS NULL
CREATE TABLE RejectedPacket (
    reject_id   INT IDENTITY(1,1) PRIMARY KEY,
    device_id   INT NULL FOREIGN KEY REFERENCES Device(device_id),
    raw_payload NVARCHAR(1000) NULL,
    reason      NVARCHAR(255) NOT NULL,
    received_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO
