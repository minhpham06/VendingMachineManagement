<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập hệ thống - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .login-wrapper {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 1.5rem;
        }
        .login-card {
            width: 100%;
            max-width: 440px;
            background: var(--glass-bg);
            border: var(--glass-border);
            border-radius: 16px;
            padding: 2.25rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.5), 0 8px 10px -6px rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(20px);
        }
        .login-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        .login-header h1 {
            font-size: 1.6rem;
            background: linear-gradient(135deg, #60a5fa, #c084fc);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 0.4rem;
        }
        .login-header p {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }
        .quick-roles {
            margin-top: 1.75rem;
            padding-top: 1.25rem;
            border-top: var(--glass-border);
        }
        .quick-roles h4 {
            font-size: 0.78rem;
            text-transform: uppercase;
            color: var(--text-muted);
            margin-bottom: 0.75rem;
            letter-spacing: 0.5px;
        }
        .role-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 0.45rem;
        }
        .role-chip {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            padding: 0.3rem 0.65rem;
            border-radius: 6px;
            font-size: 0.75rem;
            color: var(--text-secondary);
            cursor: pointer;
            transition: all 0.2s;
        }
        .role-chip:hover {
            background: rgba(59, 130, 246, 0.2);
            color: #93c5fd;
            border-color: rgba(59, 130, 246, 0.4);
        }
    </style>
</head>
<body>
    <div class="login-wrapper">
        <div class="login-card">
            <div class="login-header">
                <h1>⚡ VendDB Vending Machine</h1>
                <p>Hệ thống tự động phát hiện kẹt hàng qua đối chiếu lò xo & khối lượng khay</p>
            </div>

            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger">
                    <span>⚠️ <%=request.getAttribute("errorMessage")%></span>
                </div>
            <% } %>

            <% if (request.getAttribute("successMessage") != null) { %>
                <div class="alert alert-success">
                    <span>✅ <%=request.getAttribute("successMessage")%></span>
                </div>
            <% } %>

            <form action="<%=request.getContextPath()%>/login" method="POST">
                <div class="form-group">
                    <label for="username">Tên đăng nhập</label>
                    <input type="text" id="username" name="username" value="<%=request.getAttribute("username") != null ? request.getAttribute("username") : ""%>" placeholder="Nhập username..." required autofocus>
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <input type="password" id="password" name="password" placeholder="Nhập mật khẩu..." required>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%; padding:0.75rem; font-size:0.95rem; margin-top:0.5rem;">
                    🚀 Đăng nhập hệ thống
                </button>
            </form>

            <div class="quick-roles">
                <h4>⚡ Chọn nhanh tài khoản kiểm thử (Pass: 123456):</h4>
                <div class="role-chips">
                    <button type="button" class="role-chip" onclick="fillLogin('admin')">ADMIN</button>
                    <button type="button" class="role-chip" onclick="fillLogin('catalog_manager')">CATALOG_MGR</button>
                    <button type="button" class="role-chip" onclick="fillLogin('operator')">OPERATOR</button>
                    <button type="button" class="role-chip" onclick="fillLogin('reviewer')">REVIEWER</button>
                    <button type="button" class="role-chip" onclick="fillLogin('viewer')">VIEWER</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function fillLogin(u) {
            document.getElementById('username').value = u;
            document.getElementById('password').value = '123456';
        }
    </script>
</body>
</html>
