<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="util.WebUtil" %>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
    String usernameVal = (String) request.getAttribute("username");
    if (usernameVal == null) usernameVal = "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập | VendGuard PRJ301</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body class="login-body">
    <div class="login-card">
        <div class="login-header">
            <div class="login-logo">🥤</div>
            <h1 class="login-title">VendGuard System</h1>
            <p class="login-subtitle">Máy bán hàng thu nhỏ tự phát hiện kẹt hàng (Đề 01 - PRJ301)</p>
        </div>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger">
                <span>⚠️ <%= WebUtil.esc(errorMessage) %></span>
            </div>
        <% } %>

        <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success">
                <span>✅ <%= WebUtil.esc(successMessage) %></span>
            </div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/login">
            <div class="form-group">
                <label class="form-label" for="username">Tên đăng nhập <span class="required">*</span></label>
                <input type="text" id="username" name="username" class="form-control" 
                       value="<%= WebUtil.esc(usernameVal) %>" placeholder="Nhập tên tài khoản..." required autofocus>
            </div>

            <div class="form-group">
                <label class="form-label" for="password">Mật khẩu <span class="required">*</span></label>
                <input type="password" id="password" name="password" class="form-control" 
                       placeholder="Nhập mật khẩu..." required>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; padding: 11px; margin-top: 8px;">
                Đăng nhập hệ thống ➔
            </button>
        </form>

        <div class="quick-roles">
            <div class="quick-roles-title">⚡ Chọn nhanh tài khoản kiểm thử (Pass: 123456)</div>
            <div class="quick-roles-grid">
                <button type="button" class="btn-quick-role" onclick="fillAccount('admin', '123456')">
                    👑 ADMIN
                </button>
                <button type="button" class="btn-quick-role" onclick="fillAccount('catalog_manager', '123456')">
                    📦 CATALOG_MGR
                </button>
                <button type="button" class="btn-quick-role" onclick="fillAccount('operator', '123456')">
                    ⚙️ OPERATOR
                </button>
                <button type="button" class="btn-quick-role" onclick="fillAccount('reviewer', '123456')">
                    🔍 REVIEWER
                </button>
                <button type="button" class="btn-quick-role" style="grid-column: span 2;" onclick="fillAccount('viewer', '123456')">
                    👁️ VIEWER (Chỉ xem)
                </button>
            </div>
        </div>
    </div>

    <script>
        function fillAccount(user, pass) {
            document.getElementById('username').value = user;
            document.getElementById('password').value = pass;
        }
    </script>
</body>
</html>
