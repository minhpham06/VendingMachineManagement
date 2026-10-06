<%@page import="model.AppUser"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser navUser = (AppUser) session.getAttribute("user");
    String navRole = (navUser != null) ? navUser.getRoleCode() : "";
    String currentPath = request.getServletPath();
    if (currentPath == null) currentPath = "";
%>
<nav class="navbar">
    <div class="nav-header">
        <a href="<%=request.getContextPath()%>/dashboard" class="nav-brand">VendDB</a>
        <button class="nav-toggle" onclick="document.getElementById('nav-collapse').classList.toggle('show')">
            ☰
        </button>
    </div>
    
    <div class="nav-collapse" id="nav-collapse">
        <div class="nav-menu">
            <a href="<%=request.getContextPath()%>/dashboard" class="nav-item <%="/dashboard".equals(currentPath) ? "active" : ""%>">Tổng quan</a>
            <a href="<%=request.getContextPath()%>/sessions" class="nav-item <%="/sessions".equals(currentPath) || "/session/detail".equals(currentPath) ? "active" : ""%>">Phiên đo</a>
            <a href="<%=request.getContextPath()%>/alerts" class="nav-item <%="/alerts".equals(currentPath) ? "active" : ""%>">Cảnh báo</a>

            <% if ("ADMIN".equals(navRole) || "CATALOG_MANAGER".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/master/products" class="nav-item <%="/master/products".equals(currentPath) || "/master/product/create".equals(currentPath) || "/master/product/edit".equals(currentPath) ? "active" : ""%>">Mặt hàng</a>
            <% } %>

            <% if ("ADMIN".equals(navRole) || "CATALOG_MANAGER".equals(navRole) || "OPERATOR".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/master/slots" class="nav-item <%="/master/slots".equals(currentPath) || "/master/slot/edit".equals(currentPath) ? "active" : ""%>">Rãnh chứa</a>
            <% } %>

            <% if ("ADMIN".equals(navRole) || "OPERATOR".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/master/restocks" class="nav-item <%="/master/restocks".equals(currentPath) || "/master/restock/create".equals(currentPath) ? "active" : ""%>">Nạp hàng</a>
            <% } %>

            <% if ("ADMIN".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/admin/users" class="nav-item <%="/admin/users".equals(currentPath) || "/admin/user/create".equals(currentPath) || "/admin/user/edit".equals(currentPath) ? "active" : ""%>">Tài khoản</a>
                <a href="<%=request.getContextPath()%>/admin/roles" class="nav-item <%="/admin/roles".equals(currentPath) ? "active" : ""%>">Phân quyền</a>
            <% } %>

            <a href="<%=request.getContextPath()%>/export" class="nav-item <%="/export".equals(currentPath) ? "active" : ""%>">Xuất CSV</a>
        </div>

        <div class="nav-right">
            <% if (navUser != null) { %>
                <a href="<%=request.getContextPath()%>/profile" class="nav-profile" title="Xem thông tin cá nhân">
                    <span class="role-tag"><%=navUser.getRoleCode()%></span>
                    <span class="user-fullname"><%=navUser.getFullName()%></span>
                </a>
                <a href="<%=request.getContextPath()%>/logout" class="btn-logout">Đăng xuất</a>
            <% } else { %>
                <a href="<%=request.getContextPath()%>/login" class="nav-item">Đăng nhập</a>
            <% } %>
        </div>
    </div>
</nav>
