<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.AppRole" %>
<%@ page import="model.AppUser" %>
<%@ page import="util.WebUtil" %>
<%
    boolean isEdit = Boolean.TRUE.equals(request.getAttribute("isEdit"));
    AppUser userItem = (AppUser) request.getAttribute("userItem");
    List<AppRole> roles = (List<AppRole>) request.getAttribute("roles");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Chỉnh sửa người dùng" : "Thêm người dùng mới" %> | VendGuard PRJ301</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/nav.jsp"/>

    <main class="main-wrapper" style="max-width: 680px;">
        <div class="page-header">
            <div>
                <h1 class="page-title">
                    <%= isEdit ? "✏️ Chỉnh sửa thông tin người dùng" : "➕ Thêm tài khoản người dùng mới" %>
                </h1>
                <p class="page-subtitle">
                    <%= isEdit ? "Cập nhật họ tên, liên hệ và thay đổi vai trò hệ thống" : "Tạo tài khoản mới và gán 1 trong 5 vai trò theo quy chuẩn PRJ301" %>
                </p>
            </div>
            <div>
                <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-secondary">
                    ← Quay lại danh sách
                </a>
            </div>
        </div>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger">
                <span>⚠️ <%= WebUtil.esc(errorMessage) %></span>
            </div>
        <% } %>

        <div class="card">
            <form method="post" action="<%= request.getContextPath() %>/admin/user/<%= isEdit ? "edit" : "create" %>">
                <% if (isEdit && userItem != null) { %>
                    <input type="hidden" name="id" value="<%= userItem.getUserId() %>">
                <% } %>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="username">
                            Tên đăng nhập (Username) <span class="required">*</span>
                        </label>
                        <input type="text" id="username" name="username" class="form-control" 
                               value="<%= userItem != null ? WebUtil.esc(userItem.getUsername()) : "" %>"
                               <%= isEdit ? "readonly style='background-color: #f1f5f9; cursor: not-allowed;'" : "required" %>
                               placeholder="vd: nhanvien01">
                        <% if (isEdit) { %>
                            <small style="color: var(--text-muted); font-size: 11.5px;">Tên đăng nhập không thể thay đổi sau khi tạo.</small>
                        <% } %>
                    </div>

                    <% if (!isEdit) { %>
                    <div class="form-group">
                        <label class="form-label" for="password">
                            Mật khẩu khởi tạo <span class="required">*</span>
                        </label>
                        <input type="password" id="password" name="password" class="form-control" 
                               value="123456" required placeholder="Nhập mật khẩu ban đầu...">
                        <small style="color: var(--text-muted); font-size: 11.5px;">Mặc định: 123456 (được băm bằng PBKDF2).</small>
                    </div>
                    <% } %>
                </div>

                <div class="form-group">
                    <label class="form-label" for="fullName">
                        Họ và tên đầy đủ <span class="required">*</span>
                    </label>
                    <input type="text" id="fullName" name="fullName" class="form-control" 
                           value="<%= userItem != null ? WebUtil.esc(userItem.getFullName()) : "" %>" 
                           required placeholder="vd: Nguyễn Văn A">
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="email">Địa chỉ Email</label>
                        <input type="email" id="email" name="email" class="form-control" 
                               value="<%= userItem != null && userItem.getEmail() != null ? WebUtil.esc(userItem.getEmail()) : "" %>"
                               placeholder="vd: nva@vending.local">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="phone">Số điện thoại</label>
                        <input type="text" id="phone" name="phone" class="form-control" 
                               value="<%= userItem != null && userItem.getPhone() != null ? WebUtil.esc(userItem.getPhone()) : "" %>"
                               placeholder="vd: 0901234567">
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="roleId">
                        Vai trò hệ thống <span class="required">*</span>
                    </label>
                    <select id="roleId" name="roleId" class="form-control" required>
                        <option value="">-- Chọn vai trò --</option>
                        <% if (roles != null) {
                            for (AppRole r : roles) {
                                boolean selected = (userItem != null && userItem.getRoleId() == r.getRoleId());
                        %>
                            <option value="<%= r.getRoleId() %>" <%= selected ? "selected" : "" %>>
                                <%= r.getRoleName() %> (<%= r.getRoleCode() %>) - <%= r.getDescription() %>
                            </option>
                        <%  }
                        } %>
                    </select>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border);">
                    <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-secondary">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary">
                        <%= isEdit ? "💾 Lưu thay đổi" : "➕ Thêm người dùng" %>
                    </button>
                </div>
            </form>
        </div>
    </main>

    <footer class="footer">
        Đồ án PRJ301 - Đề số 01: Máy bán hàng thu nhỏ tự phát hiện kẹt hàng &copy; Fall 2026. Trường Đại học FPT.
    </footer>
</body>
</html>
