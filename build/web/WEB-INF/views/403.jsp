<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Set" %>
<%@ page import="model.AppUser" %>
<%@ page import="util.WebUtil" %>
<%
    AppUser user = (AppUser) session.getAttribute("user");
    String forbiddenPath = (String) request.getAttribute("forbiddenPath");
    String currentRole = (String) request.getAttribute("currentRole");
    Set<String> allowedRoles = (Set<String>) request.getAttribute("allowedRoles");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 - Quyền truy cập bị từ chối | VendGuard PRJ301</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/nav.jsp"/>

    <main class="main-wrapper">
        <div class="card error-page">
            <div class="error-code">403</div>
            <h1 class="error-title">Truy cập bị từ chối (Access Denied)</h1>
            <p class="error-desc">
                Bạn không có quyền truy cập vào đường dẫn: 
                <b style="color: var(--danger);"><%= WebUtil.esc(forbiddenPath) %></b>
            </p>

            <div style="background: #f8fafc; border: 1px solid var(--border); border-radius: var(--radius-md); padding: 18px; max-width: 480px; margin: 0 auto 24px; text-align: left; font-size: 13.5px;">
                <div style="margin-bottom: 8px;">
                    <b>Vai trò hiện tại của bạn:</b> 
                    <span class="badge badge-viewer"><%= currentRole != null ? currentRole : "CHƯA XÁC ĐỊNH" %></span>
                </div>
                <div>
                    <b>Các vai trò được phép truy cập:</b>
                    <% if (allowedRoles != null) {
                        for (String r : allowedRoles) { %>
                            <span class="badge badge-admin"><%= r %></span>
                    <%  }
                    } %>
                </div>
            </div>

            <div>
                <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-primary">
                    ← Quay lại Bảng điều khiển
                </a>
            </div>
        </div>
    </main>

    <footer class="footer">
        Đồ án PRJ301 - Đề số 01: Máy bán hàng thu nhỏ tự phát hiện kẹt hàng &copy; Fall 2026. Trường Đại học FPT.
    </footer>
</body>
</html>
