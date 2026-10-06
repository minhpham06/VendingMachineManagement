<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>404 - Không tìm thấy trang</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <div style="display:flex; justify-content:center; align-items:center; min-height:100vh; padding:1.5rem;">
        <div class="card" style="max-width:480px; text-align:center; padding:2.5rem;">
            <div style="font-size:3.5rem; margin-bottom:1rem;">🔍</div>
            <h1 style="font-size:1.6rem; color:#60a5fa; margin-bottom:0.5rem;">404 - Không Tìm Thấy Trang</h1>
            <p style="color:var(--text-secondary); font-size:0.92rem; margin-bottom:1.5rem;">
                Đường dẫn bạn yêu cầu không tồn tại hoặc đã bị thay đổi.
            </p>
            <a href="<%=request.getContextPath()%>/dashboard" class="btn btn-primary">
                🏠 Quay về Trang chủ
            </a>
        </div>
    </div>
</body>
</html>
