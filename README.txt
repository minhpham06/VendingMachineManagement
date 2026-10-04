================================================================
DỰ ÁN CUỐI MÔN PRJ301 - HỌC KỲ FALL 2026 - ĐỀ SỐ 01
Đề tài: Máy bán hàng thu nhỏ tự phát hiện kẹt hàng bằng đối chiếu
        vòng quay lò xo và khối lượng khay
(Miniature Vending Machine with Jam Detection by Cross-Checking Coil Rotation Against Tray Weight)
================================================================

1. MÔI TRƯỜNG CHUẨN THI
---------------------------------------------------------------
- NetBeans 13 / IntelliJ IDEA / VS Code
- JDK 8 (1.8)
- Apache Tomcat 9
- Microsoft SQL Server 2012+ (Database: VendDB)
- Thư viện JDBC duy nhất: sqljdbc4.jar (đã có sẵn trong web/WEB-INF/lib)
- Mã nguồn viết theo mô hình chuẩn MVC2 thuần Servlet & JSP, không cần kết nối mạng.

2. CÁC BƯỚC KHỞI ĐỘNG HỆ THỐNG
---------------------------------------------------------------
Bước 1: Chạy 2 file script SQL trong thư mục sql/ bằng SQL Server Management Studio hoặc sqlcmd:
        1. sql/01_schema.sql      (Khởi tạo CSDL VendDB và toàn bộ các bảng)
        2. sql/02_sample_data.sql (Nạp 5 vai trò, 5 tài khoản mẫu và 240 phiên dữ liệu mẫu)

Bước 2: Cấu hình kết nối tại: src/java/util/DBContext.java
        - URL: jdbc:sqlserver://localhost:1433;databaseName=VendDB;encrypt=false
        - USER: sa
        - PASS: 123456

Bước 3: Mở dự án trong NetBeans 13 (Open Project), chọn máy chủ Apache Tomcat 9.

Bước 4: Nhấn Run (F6). Trình duyệt tự động mở trang đăng nhập tại:
        http://localhost:8080/UserManagement/login

3. DANH SÁCH TÀI KHOẢN MẪU KIỂM THỬ (MẬT KHẨU: 123456)
---------------------------------------------------------------
Mọi mật khẩu đều được băm bảo mật bằng thuật toán PBKDF2WithHmacSHA256 (20,000 vòng băm, muối 16-byte ngẫu nhiên).
Tại trang đăng nhập đã tích hợp sẵn 5 nút chọn nhanh (Quick-Login) để giảng viên/sinh viên kiểm thử ngay lập tức:

1. admin            - Vai trò: ADMIN (Toàn quyền quản trị tài khoản, vai trò, cấu hình hệ thống)
2. catalog_manager  - Vai trò: CATALOG_MANAGER (Quản lý mặt hàng, khối lượng chuẩn, dung sai, rãnh chứa)
3. operator         - Vai trò: OPERATOR (Vận hành, nạp hàng vào rãnh, lập phiếu nạp, chạy thử lượt nhả)
4. reviewer         - Vai trò: REVIEWER (Kiểm duyệt các phiên bị nghi ngờ, sửa nhãn kèm lý do)
5. viewer           - Vai trò: VIEWER (Chỉ xem tổng quan Dashboard, xem chi tiết phiên và xuất file CSV)

4. CƠ CHẾ BẢO MẬT & PHÂN QUYỀN PHÍA SERVER
---------------------------------------------------------------
- Phân quyền chặt chẽ thông qua filter/AuthFilter.java:
  + /admin/*   : Chỉ ADMIN được phép truy cập.
  + /master/*  : ADMIN, CATALOG_MANAGER, OPERATOR.
  + /label/*   : ADMIN, REVIEWER.
  + /sessions  : Tất cả 5 vai trò.
  + /dashboard : Tất cả 5 vai trò.
- Nếu người dùng đăng nhập bằng vai trò không có quyền (ví dụ viewer) cố tình dán trực tiếp đường dẫn
  vào trình duyệt (URL bypass), Server sẽ chặn ngay lập tức và chuyển tiếp về trang 403 Forbidden.
- Ngăn chặn người dùng tự khóa hoặc tự xóa chính tài khoản đang đăng nhập của mình.

5. DỮ LIỆU THỰC NGHIỆM BAN ĐẦU
---------------------------------------------------------------
Cơ sở dữ liệu VendDB đã được nạp sẵn 240 phiên mẫu chuẩn (is_sample = 1) theo đúng quy định đề bài:
- SUCCESS: 120 phiên (Trục quay đủ 1 vòng & khay tăng đúng dải khối lượng đăng ký)
- JAM: 40 phiên (Trục quay đủ 1 vòng nhưng hàng kẹt trong rãnh, khay không tăng khối lượng)
- WRONG_ITEM: 50 phiên (Khay tăng khối lượng nhưng rơi sai món hoặc rơi 2 món cùng lúc)
- MOTOR_FAIL: 30 phiên (Trục kẹt không quay hết 1 vòng trong thời gian tối đa 4 giây)
