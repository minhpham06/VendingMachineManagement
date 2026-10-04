<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.AppUser" %>
<%@ page import="util.WebUtil" %>
<%
    AppUser me = (AppUser) request.getAttribute("user");
    if (me == null) me = (AppUser) session.getAttribute("user");

    String passSuccess = (String) request.getAttribute("passSuccess");
    String passError = (String) request.getAttribute("passError");
    String infoSuccess = (String) request.getAttribute("infoSuccess");
    String infoError = (String) request.getAttribute("infoError");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin cá nhân | VendGuard PRJ301</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/nav.jsp"/>

    <main class="main-wrapper" style="max-width: 800px;">
        <div class="page-header">
            <div>
                <h1 class="page-title">👤 Thông tin tài khoản cá nhân</h1>
                <p class="page-subtitle">Xem thông tin định danh và thay đổi mật khẩu đăng nhập</p>
            </div>
            <div>
                <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-secondary">
                    ← Về Bảng điều khiển
                </a>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
            <!-- Form cap nhat thong tin -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">📝 Thông tin cơ bản</h2>
                </div>

                <% if (infoSuccess != null && !infoSuccess.isEmpty()) { %>
                    <div class="alert alert-success"><span>✅ <%= WebUtil.esc(infoSuccess) %></span></div>
                <% } %>
                <% if (infoError != null && !infoError.isEmpty()) { %>
                    <div class="alert alert-danger"><span>⚠️ <%= WebUtil.esc(infoError) %></span></div>
                <% } %>

                <form method="post" action="<%= request.getContextPath() %>/profile">
                    <input type="hidden" name="action" value="update_info">

                    <div class="form-group">
                        <label class="form-label">Tên đăng nhập (Username)</label>
                        <input type="text" class="form-control" value="<%= WebUtil.esc(me.getUsername()) %>" readonly 
                               style="background-color: #f1f5f9; cursor: not-allowed;">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Vai trò trong hệ thống</label>
                        <input type="text" class="form-control" value="<%= WebUtil.esc(me.getRoleName()) %> (<%= me.getRoleCode() %>)" readonly 
                               style="background-color: #f1f5f9; cursor: not-allowed; font-weight: 600;">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Họ và tên <span class="required">*</span></label>
                        <input type="text" name="fullName" class="form-control" value="<%= WebUtil.esc(me.getFullName()) %>" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control" value="<%= me.getEmail() != null ? WebUtil.esc(me.getEmail()) : "" %>">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Số điện thoại</label>
                        <input type="text" name="phone" class="form-control" value="<%= me.getPhone() != null ? WebUtil.esc(me.getPhone()) : "" %>">
                    </div>

                    <button type="submit" class="btn btn-primary" style="width: 100%;">
                        💾 Cập nhật thông tin
                    </button>
                </form>
            </div>

            <!-- Form doi mat khau -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">🔑 Đổi mật khẩu</h2>
                </div>

                <% if (passSuccess != null && !passSuccess.isEmpty()) { %>
                    <div class="alert alert-success"><span>✅ <%= WebUtil.esc(passSuccess) %></span></div>
                <% } %>
                <% if (passError != null && !passError.isEmpty()) { %>
                    <div class="alert alert-danger"><span>⚠️ <%= WebUtil.esc(passError) %></span></div>
                <% } %>

                <form method="post" action="<%= request.getContextPath() %>/profile">
                    <input type="hidden" name="action" value="change_password">

                    <div class="form-group">
                        <label class="form-label">Mật khẩu hiện tại <span class="required">*</span></label>
                        <input type="password" name="oldPassword" class="form-control" required placeholder="Nhập mật khẩu đang dùng...">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Mật khẩu mới <span class="required">*</span></label>
                        <input type="password" name="newPassword" class="form-control" required placeholder="Tối thiểu 6 ký tự...">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Xác nhận mật khẩu mới <span class="required">*</span></label>
                        <input type="password" name="confirmPassword" class="form-control" required placeholder="Nhập lại mật khẩu mới...">
                    </div>

                    <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 16px;">
                        🔒 Mật khẩu được mã hóa an toàn bằng thuật toán chuẩn <b>PBKDF2WithHmacSHA256</b> với muối ngẫu nhiên 16-byte.
                    </div>

                    <button type="submit" class="btn btn-warning" style="width: 100%;">
                        🔐 Đổi mật khẩu
                    </button>
                </form>
            </div>
        </div>
    </main>

    <footer class="footer">
        Đồ án PRJ301 - Đề số 01: Máy bán hàng thu nhỏ tự phát hiện kẹt hàng &copy; Fall 2026. Trường Đại học FPT.
    </footer>
</body>
</html>
