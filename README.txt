================================================================
DỰ ÁN CUỐI MÔN PRJ301 - HỌC KỲ FALL 2026 - ĐỀ SỐ 01
Đề tài: Máy bán hàng thu nhỏ tự phát hiện kẹt hàng bằng đối chiếu
        vòng quay lò xo và khối lượng khay
(Miniature Vending Machine with Jam Detection by Cross-Checking
 Coil Rotation Against Tray Weight)
================================================================

1. MÔI TRƯỜNG CHUẨN THI
---------------------------------------------------------------
- NetBeans 13 / IntelliJ IDEA / Eclipse / VS Code
- JDK 8 (1.8)
- Apache Tomcat 9
- Microsoft SQL Server 2012+ (CSDL: VendDB)
- Thư viện JDBC duy nhất: sqljdbc4.jar (đã nằm sẵn trong web/WEB-INF/lib)
- Kiến trúc: Chuẩn MVC2 thuần Servlet & JSP, không dùng thư viện ngoài
- Đồ thị & Biểu đồ: Vẽ trực tiếp bằng HTML5 Canvas thuần (chạy Offline 100%)

2. CÁC BƯỚC KHỞI CHẠY HỆ THỐNG
---------------------------------------------------------------
Bước 1. Mở SQL Server Management Studio (SSMS), chạy 2 script trong thư mục sql/:
        - sql/01_schema.sql      (Khởi tạo CSDL VendDB và các bảng)
        - sql/02_sample_data.sql (Nạp 5 vai trò, 5 user mẫu và 240 phiên thực nghiệm)

Bước 2. Cấu hình chuỗi kết nối (nếu cần thay đổi sa/password):
        - File: src/java/util/DBContext.java
        - URL : jdbc:sqlserver://localhost:1433;databaseName=VendDB;encrypt=false
        - USER: sa
        - PASS: 123456

Bước 3. Mở NetBeans 13:
        - File -> Open Project -> Trỏ vào thư mục UserManagement
        - Chọn máy chủ Apache Tomcat 9 đã cài trên máy

Bước 4. Nhấn Run (F6):
        - Trình duyệt tự động mở: http://localhost:8080/UserManagement/login
        - Tại màn hình đăng nhập có 5 nút bấm nhanh để đăng nhập theo từng vai trò.

3. DANH SÁCH TÀI KHOẢN MẪU & VAI TRÒ (MẬT KHẨU: 123456)
---------------------------------------------------------------
Mọi mật khẩu đều được băm bảo mật bằng thuật toán PBKDF2WithHmacSHA256
(20,000 vòng băm + muối 16-byte ngẫu nhiên).

1. admin           / 123456 -> ADMIN: Quản trị viên hệ thống (Toàn quyền CRUD)
2. catalog_manager / 123456 -> CATALOG_MANAGER: Quản lý danh mục mặt hàng, dung sai, rãnh lò xo
3. operator        / 123456 -> OPERATOR: Lập phiếu nạp hàng, mở/khóa rãnh bị kẹt, xử lý cảnh báo
4. reviewer        / 123456 -> REVIEWER: Kiểm duyệt các phiên nghi ngờ, sửa nhãn kèm lý do (>= 5 ký tự)
5. viewer          / 123456 -> VIEWER: Chỉ xem Dashboard, biểu đồ Canvas, danh sách phiên và xuất file CSV

4. CÁC CHỨC NĂNG NỔI BẬT ĐÃ HOÀN THIỆN
---------------------------------------------------------------
1. [Dashboard & Canvas Charts]: Biểu đồ Donut cơ cấu phân loại, Biểu đồ cột Bar Chart tỷ lệ kẹt theo mặt hàng, Bảng rủi ro.
2. [Quản lý Danh mục (Product & Slot)]: Cấu hình khối lượng danh định, dung sai, đơn giá, tự khóa rãnh (SUSPENDED).
3. [Lập phiếu Nạp hàng (Restock)]: Quản lý số lượng tồn, lưu vết người nạp và cập nhật tồn kho an toàn bằng Transaction.
4. [Danh sách & Chi tiết Phiên (Session Detail)]:
   - Phân trang server-side bằng OFFSET/FETCH NEXT.
   - Vẽ đồ thị dạng sóng 3 pha của khối lượng khay trên thẻ HTML5 Canvas (W_trước -> W_đỉnh -> W_sau).
   - Chức năng sửa nhãn cho Reviewer có lưu vết Audit Trail.
5. [Động cơ Cảnh báo Thông minh (Smart Alert Engine)]: 4 luật tự động (Kẹt liên tiếp, Sắp hết hàng, Trôi dạt cảm biến, Mòn động cơ).
6. [API ESP32 & Xuất CSV]:
   - Endpoint: POST /api/ingest có kiểm tra X-API-Key, chống gói trùng.
   - Xuất dữ liệu thực nghiệm ra file CSV chuẩn UTF-8 có BOM.
