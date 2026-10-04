<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.AppUser" %>
<%
    AppUser navUser = (AppUser) session.getAttribute("user");
    String currentPath = request.getRequestURI();
%>
<nav class="navbar">
    <div style="display: flex; align-items: center; gap: 28px;">
        <a href="<%= request.getContextPath() %>/dashboard" class="nav-brand">
            <span>🥤 VendGuard</span>
            <span class="brand-badge">PRJ301</span>
        </a>

        <ul class="nav-links">
            <li>
                <a href="<%= request.getContextPath() %>/dashboard" 
                   class="nav-link <%= currentPath.contains("/dashboard") ? "active" : "" %>">
                    📊 Bảng điều khiển
                </a>
            </li>

            <% if (navUser != null && navUser.isAdmin()) { %>
            <li>
                <a href="<%= request.getContextPath() %>/admin/users" 
                   class="nav-link <%= currentPath.contains("/admin/users") || currentPath.contains("/admin/user") ? "active" : "" %>">
                    👥 Người dùng
                </a>
            </li>
            <li>
                <a href="<%= request.getContextPath() %>/admin/roles" 
                   class="nav-link <%= currentPath.contains("/admin/roles") ? "active" : "" %>">
                    🛡️ Vai trò & Quyền
                </a>
            </li>
            <% } %>

            <li>
                <a href="<%= request.getContextPath() %>/sessions" 
                   class="nav-link <%= currentPath.contains("/session") ? "active" : "" %>">
                    📦 Phiên nhả hàng
                </a>
            </li>
        </ul>
    </div>

    <div class="nav-user">
        <% if (navUser != null) { 
            String roleClass = "badge-viewer";
            if (navUser.isAdmin()) roleClass = "badge-admin";
            else if (navUser.isCatalogManager()) roleClass = "badge-catalog";
            else if (navUser.isOperator()) roleClass = "badge-operator";
            else if (navUser.isReviewer()) roleClass = "badge-reviewer";
        %>
            <a href="<%= request.getContextPath() %>/profile" class="user-pill" style="text-decoration: none;">
                <div class="user-avatar">
                    <%= navUser.getFullName() != null && !navUser.getFullName().isEmpty() 
                        ? navUser.getFullName().substring(0, 1).toUpperCase() : "U" %>
                </div>
                <div class="user-info-text">
                    <div class="user-name"><%= navUser.getFullName() %></div>
                    <span class="user-role-badge <%= roleClass %>"><%= navUser.getRoleCode() %></span>
                </div>
            </a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout" title="Đăng xuất khỏi hệ thống">
                Đăng xuất ➔
            </a>
        <% } else { %>
            <a href="<%= request.getContextPath() %>/login" class="btn btn-sm btn-primary">Đăng nhập</a>
        <% } %>
    </div>
</nav>
