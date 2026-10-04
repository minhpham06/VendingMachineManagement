-- =====================================================================
-- HE THONG MAY BAN HANG THU NHO TU DONG PHAT HIEN KET HANG
-- Project PRJ301 - De so 01 - Fall 2026
-- 01_schema.sql: Tao co so du lieu VendDB va toan bo cac bang
-- =====================================================================

IF DB_ID('VendDB') IS NULL
BEGIN
    CREATE DATABASE VendDB;
END
GO

USE VendDB;
GO

-- Drop tables if needed (theo thu tu khoa ngoai)
IF OBJECT_ID('Vend_Alert', 'U') IS NOT NULL DROP TABLE Vend_Alert;
IF OBJECT_ID('Vend_Label', 'U') IS NOT NULL DROP TABLE Vend_Label;
IF OBJECT_ID('Vend_Session', 'U') IS NOT NULL DROP TABLE Vend_Session;
IF OBJECT_ID('Vend_Restock', 'U') IS NOT NULL DROP TABLE Vend_Restock;
IF OBJECT_ID('Vend_Slot', 'U') IS NOT NULL DROP TABLE Vend_Slot;
IF OBJECT_ID('Vend_Product', 'U') IS NOT NULL DROP TABLE Vend_Product;
IF OBJECT_ID('RejectedPacket', 'U') IS NOT NULL DROP TABLE RejectedPacket;
IF OBJECT_ID('Device', 'U') IS NOT NULL DROP TABLE Device;
IF OBJECT_ID('AppUser', 'U') IS NOT NULL DROP TABLE AppUser;
IF OBJECT_ID('AppRole', 'U') IS NOT NULL DROP TABLE AppRole;
GO

-- ===== 1. NGUOI DUNG VA VAI TRO =====
CREATE TABLE AppRole (
    role_id   INT IDENTITY(1,1) PRIMARY KEY,
    role_code NVARCHAR(32)  NOT NULL UNIQUE, -- ADMIN, CATALOG_MANAGER, OPERATOR, REVIEWER, VIEWER
    role_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(255) NULL
);
GO

CREATE TABLE AppUser (
    user_id    INT IDENTITY(1,1) PRIMARY KEY,
    username   NVARCHAR(64)  NOT NULL UNIQUE,
    pass_hash  NVARCHAR(200) NOT NULL,   -- PBKDF2: iterations:saltHex:hashHex
    full_name  NVARCHAR(150) NOT NULL,
    email      NVARCHAR(150) NULL,
    phone      NVARCHAR(32)  NULL,
    role_id    INT NOT NULL FOREIGN KEY REFERENCES AppRole(role_id),
    is_locked  BIT NOT NULL DEFAULT 0,
    created_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_AppUser_role ON AppUser(role_id);
GO

-- ===== 2. THIET BI VA GOI TIN TU CHOI =====
CREATE TABLE Device (
    device_id   INT IDENTITY(1,1) PRIMARY KEY,
    device_code NVARCHAR(32)  NOT NULL UNIQUE,  -- vd: Vend-01
    api_key     NVARCHAR(64)  NOT NULL,         -- Gui boi ESP32 trong header X-API-Key
    location    NVARCHAR(150) NULL,
    last_seen   DATETIME2(0)  NULL,
    is_active   BIT NOT NULL DEFAULT 1,
    created_at  DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE RejectedPacket (
    reject_id   INT IDENTITY(1,1) PRIMARY KEY,
    raw_body    NVARCHAR(MAX) NULL,
    device_code NVARCHAR(32)  NULL,
    reason      NVARCHAR(200) NOT NULL,
    received_at DATETIME2(0)  NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ===== 3. MAT HANG VA RANH CHUA HANG (Mo rong theo de bai) =====
CREATE TABLE Vend_Product (
    product_id     INT IDENTITY(1,1) PRIMARY KEY,
    code           NVARCHAR(32)  NOT NULL UNIQUE,
    name           NVARCHAR(150) NOT NULL,
    nominal_weight DECIMAL(9,2)  NOT NULL,  -- Khoi luong danh dinh (gam) do bang can tieu ly
    tolerance      DECIMAL(9,2)  NOT NULL DEFAULT 3.00, -- Dung sai cho phep (+/- gam)
    price          DECIMAL(12,2) NOT NULL DEFAULT 0,    -- Gia ban (VND)
    note           NVARCHAR(400) NULL,
    is_active      BIT NOT NULL DEFAULT 1,
    created_at     DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE Vend_Slot (
    slot_id      INT IDENTITY(1,1) PRIMARY KEY,
    code         NVARCHAR(32)  NOT NULL UNIQUE, -- vd: SLOT-01
    name         NVARCHAR(150) NOT NULL,
    product_id   INT NULL FOREIGN KEY REFERENCES Vend_Product(product_id),
    capacity     INT NOT NULL DEFAULT 10,
    current_stock INT NOT NULL DEFAULT 0,
    is_suspended BIT NOT NULL DEFAULT 0,        -- 1 khi kẹt 3 phiên liên tiếp, rãnh tự tạm ngừng
    note         NVARCHAR(400) NULL,
    is_active    BIT NOT NULL DEFAULT 1,
    created_at   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE Vend_Restock (
    restock_id   INT IDENTITY(1,1) PRIMARY KEY,
    code         NVARCHAR(32)  NOT NULL UNIQUE, -- Ma phieu nap: RS-xxxx
    slot_id      INT NOT NULL FOREIGN KEY REFERENCES Vend_Slot(slot_id),
    product_id   INT NOT NULL FOREIGN KEY REFERENCES Vend_Product(product_id),
    quantity     INT NOT NULL,                  -- So luong nap
    restocked_by INT NOT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    note         NVARCHAR(400) NULL,
    is_active    BIT NOT NULL DEFAULT 1,
    created_at   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ===== 4. BANG PHIEN DU LIEU (BANG CHINH CUA DE TAI) =====
CREATE TABLE Vend_Session (
    session_id    INT IDENTITY(1,1) PRIMARY KEY,
    device_id     INT NOT NULL FOREIGN KEY REFERENCES Device(device_id),
    slot_id       INT NULL FOREIGN KEY REFERENCES Vend_Slot(slot_id),
    device_seq    INT NOT NULL,             -- Bo dem bo mach de loai bo goi tin trung
    measured_at   DATETIME2(0) NOT NULL,    -- Thoi diem bo mach do
    ingested_at   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(), -- Thoi diem server nhan
    weight_before DECIMAL(9,2) NULL,        -- Khay truoc nha (gam)
    weight_after  DECIMAL(9,2) NULL,        -- Khay sau nha (gam)
    weight_delta  DECIMAL(9,2) NULL,        -- Chenh lech khoi luong (gam)
    coil_turns    INT NULL,                 -- So vong quay (1 la du vong)
    motor_ms      INT NULL,                 -- Thoi gian dong co chay (ms)
    settle_ms     INT NULL,                 -- Thoi gian on dinh khay (ms)
    peak_delta    DECIMAL(9,2) NULL,        -- Bien do dao dong luc roi (gam)
    is_sample     BIT NOT NULL DEFAULT 0,   -- 1: du lieu mau, 0: tu thiet bi that
    CONSTRAINT UQ_Vend_Session_seq UNIQUE (device_id, device_seq)
);
GO

CREATE INDEX IX_Vend_Session_measured ON Vend_Session(measured_at DESC);
CREATE INDEX IX_Vend_Session_device ON Vend_Session(device_id);
GO

-- ===== 5. BANG NHAN CUA PHIEN (TACH RIENG CHO REVIEWER SUA) =====
CREATE TABLE Vend_Label (
    label_id   INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL FOREIGN KEY REFERENCES Vend_Session(session_id),
    label_code NVARCHAR(24) NOT NULL, -- SUCCESS, JAM, WRONG_ITEM, MOTOR_FAIL
    source     NVARCHAR(16) NOT NULL, -- RULE: may tu gan, REVIEWER: nguoi sua
    reason     NVARCHAR(400) NULL,
    labeled_by INT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    labeled_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_Vend_Label_session ON Vend_Label(session_id, label_id DESC);
GO

-- ===== 6. BANG CANH BAO =====
CREATE TABLE Vend_Alert (
    alert_id     INT IDENTITY(1,1) PRIMARY KEY,
    session_id   INT NULL FOREIGN KEY REFERENCES Vend_Session(session_id),
    slot_id      INT NULL FOREIGN KEY REFERENCES Vend_Slot(slot_id),
    rule_code    NVARCHAR(32)  NOT NULL, -- SLOT_JAM_3X, LOW_STOCK, WEIGHT_DRIFT, MOTOR_DEGRADE
    severity     NVARCHAR(16)  NOT NULL, -- INFO, WARN, CRITICAL
    message      NVARCHAR(400) NOT NULL,
    status       NVARCHAR(16)  NOT NULL DEFAULT 'OPEN',  -- OPEN, ACKED, REJECTED, RESOLVED
    handled_by   INT NULL FOREIGN KEY REFERENCES AppUser(user_id),
    handled_note NVARCHAR(400) NULL,
    created_at   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_Vend_Alert_status ON Vend_Alert(status, created_at DESC);
GO
