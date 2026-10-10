<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>403 - Không có quyền truy cập</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <div style="display:flex; justify-content:center; align-items:center; min-height:100vh; padding:1.5rem;">
        <div class="card" style="max-width:480px; text-align:center; padding:2.5rem;">
            <div style="font-size:3.5rem; margin-bottom:1rem;"></div>
            <h1 style="font-size:1.6rem; color:#f87171; margin-bottom:0.5rem;">403 - Quyền Truy Cập Bị Từ Chối</h1>
            <p style="color:var(--text-secondary); font-size:0.92rem; margin-bottom:1.5rem;">
                Tài khoản của bạn (<strong style="color:#93c5fd;"><%=request.getAttribute("userRole")%></strong>) không có quyền truy cập vào đường dẫn:
                <br><code style="background:rgba(0,0,0,0.3); padding:0.2rem 0.5rem; border-radius:4px; color:#fca5a5;"><%=request.getAttribute("requestedPath")%></code>
            </p>
            <a href="<%=request.getContextPath()%>/dashboard" class="btn btn-primary">
                 Quay về Trang chủ
            </a>
        </div>
    </div>
</body>
</html>
