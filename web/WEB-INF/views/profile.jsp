<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser user = (AppUser) request.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Hồ sơ cá nhân - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container" style="max-width: 750px;">
        <!-- THONG TIN CA NHAN -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title"> Thông tin cá nhân</h2>
                <span class="user-badge"><%=user.getRoleCode()%></span>
            </div>

            <% if (request.getAttribute("infoSuccess") != null) { %>
                <div class="alert alert-success"><span> <%=request.getAttribute("infoSuccess")%></span></div>
            <% } %>
            <% if (request.getAttribute("infoError") != null) { %>
                <div class="alert alert-danger"><span> <%=request.getAttribute("infoError")%></span></div>
            <% } %>

            <form action="<%=request.getContextPath()%>/profile" method="POST">
                <input type="hidden" name="action" value="update_info">

                <div class="form-group">
                    <label>Tên đăng nhập</label>
                    <input type="text" value="<%=WebUtil.esc(user.getUsername())%>" disabled style="opacity:0.7; cursor:not-allowed;">
                </div>

                <div class="form-group">
                    <label for="fullName">Họ và tên (*)</label>
                    <input type="text" id="fullName" name="fullName" value="<%=WebUtil.esc(user.getFullName())%>" required>
                </div>

                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" value="<%=user.getEmail() != null ? WebUtil.esc(user.getEmail()) : ""%>">
                </div>

                <div class="form-group">
                    <label for="phone">Số điện thoại</label>
                    <input type="text" id="phone" name="phone" value="<%=user.getPhone() != null ? WebUtil.esc(user.getPhone()) : ""%>">
                </div>

                <div style="text-align:right;">
                    <button type="submit" class="btn btn-primary"> Cập nhật thông tin</button>
                </div>
            </form>
        </div>

        <!-- DOI MAT KHAU -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title"> Đổi mật khẩu</h2>
            </div>

            <% if (request.getAttribute("passSuccess") != null) { %>
                <div class="alert alert-success"><span> <%=request.getAttribute("passSuccess")%></span></div>
            <% } %>
            <% if (request.getAttribute("passError") != null) { %>
                <div class="alert alert-danger"><span> <%=request.getAttribute("passError")%></span></div>
            <% } %>

            <form action="<%=request.getContextPath()%>/profile" method="POST">
                <input type="hidden" name="action" value="change_password">

                <div class="form-group">
                    <label for="oldPassword">Mật khẩu hiện tại (*)</label>
                    <input type="password" id="oldPassword" name="oldPassword" placeholder="Nhập mật khẩu hiện tại..." required>
                </div>

                <div class="form-group">
                    <label for="newPassword">Mật khẩu mới (*)</label>
                    <input type="password" id="newPassword" name="newPassword" placeholder="Tối thiểu 6 ký tự..." required>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu mới (*)</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu mới..." required>
                </div>

                <div style="text-align:right;">
                    <button type="submit" class="btn btn-warning"> Cập nhật mật khẩu</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
