<%@page import="java.util.List"%>
<%@page import="model.AppUser"%>
<%@page import="model.AppRole"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser editUser = (AppUser) request.getAttribute("editUser");
    boolean isEdit = (editUser != null);
    List<AppRole> roles = (List<AppRole>) request.getAttribute("roles");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title><%=(isEdit ? "Chỉnh sửa người dùng" : "Thêm người dùng mới")%> - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container" style="max-width: 600px;">
        <div class="card">
            <div class="card-header">
                <h2 class="card-title"><%=(isEdit ? " Chỉnh sửa thông tin tài khoản" : " Thêm tài khoản người dùng mới")%></h2>
                <a href="<%=request.getContextPath()%>/admin/users" class="btn btn-outline btn-sm">⬅ Quay lại</a>
            </div>

            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger">
                    <span> <%=request.getAttribute("errorMessage")%></span>
                </div>
            <% } %>

            <form action="<%=request.getContextPath()%><%=isEdit ? "/admin/user/edit?id=" + editUser.getUserId() : "/admin/user/create"%>" method="POST">
                <% if (!isEdit) { %>
                    <div class="form-group">
                        <label for="username">Tên đăng nhập (*)</label>
                        <input type="text" id="username" name="username" placeholder="vd: reviewer_01" required>
                    </div>

                    <div class="form-group">
                        <label for="password">Mật khẩu khởi tạo (*)</label>
                        <input type="password" id="password" name="password" placeholder="Mật khẩu tối thiểu 6 ký tự..." required>
                    </div>
                <% } else { %>
                    <div class="form-group">
                        <label>Tên đăng nhập</label>
                        <input type="text" value="<%=WebUtil.esc(editUser.getUsername())%>" disabled style="opacity:0.7; cursor:not-allowed;">
                    </div>
                <% } %>

                <div class="form-group">
                    <label for="fullName">Họ và tên (*)</label>
                    <input type="text" id="fullName" name="fullName" value="<%=isEdit ? WebUtil.esc(editUser.getFullName()) : ""%>" placeholder="vd: Nguyễn Văn A" required>
                </div>

                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" value="<%=isEdit && editUser.getEmail() != null ? WebUtil.esc(editUser.getEmail()) : ""%>" placeholder="vd: user@fpt.edu.vn">
                </div>

                <div class="form-group">
                    <label for="phone">Số điện thoại</label>
                    <input type="text" id="phone" name="phone" value="<%=isEdit && editUser.getPhone() != null ? WebUtil.esc(editUser.getPhone()) : ""%>" placeholder="vd: 0912345678">
                </div>

                <div class="form-group">
                    <label for="roleId">Vai trò phân quyền (*)</label>
                    <select id="roleId" name="roleId" required>
                        <option value="">-- Chọn vai trò --</option>
                        <% if (roles != null) {
                            for (AppRole r : roles) {
                        %>
                            <option value="<%=r.getRoleId()%>" <%=(isEdit && editUser.getRoleId() == r.getRoleId()) ? "selected" : ""%>><%=r.getRoleName()%> (<%=r.getRoleCode()%>)</option>
                        <% } } %>
                    </select>
                </div>

                <% if (isEdit) { %>
                    <div class="form-group">
                        <label>Trạng thái khóa tài khoản</label>
                        <select name="isLocked">
                            <option value="0" <%=!editUser.isLocked() ? "selected" : ""%>>Đang hoạt động</option>
                            <option value="1" <%=editUser.isLocked() ? "selected" : ""%>>Đã bị khóa</option>
                        </select>
                    </div>
                <% } %>

                <div style="display:flex; justify-content:flex-end; gap:0.75rem; margin-top:1.5rem;">
                    <a href="<%=request.getContextPath()%>/admin/users" class="btn btn-outline">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary"><%=(isEdit ? " Lưu thay đổi" : " Tạo người dùng")%></button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
