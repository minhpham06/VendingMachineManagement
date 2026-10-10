<%@page import="model.AppUser"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser navUser = (AppUser) session.getAttribute("user");
    String navRole = (navUser != null) ? navUser.getRoleCode() : "";
    
    String forwardPath = (String) request.getAttribute("javax.servlet.forward.servlet_path");
    String forwardUri = (String) request.getAttribute("javax.servlet.forward.request_uri");
    String reqUri = request.getRequestURI();
    String servletPath = request.getServletPath();
    String fullPath = (" " + forwardPath + " " + forwardUri + " " + reqUri + " " + servletPath).toLowerCase();
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
            <a href="<%=request.getContextPath()%>/dashboard" class="nav-item <%=fullPath.contains("dashboard") ? "active" : ""%>">Tổng quan</a>
            <a href="<%=request.getContextPath()%>/sessions" class="nav-item <%=fullPath.contains("session") ? "active" : ""%>">Phiên đo</a>
            <a href="<%=request.getContextPath()%>/alerts" class="nav-item <%=fullPath.contains("alert") ? "active" : ""%>">Cảnh báo</a>

            <% if ("ADMIN".equals(navRole) || "CATALOG_MANAGER".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/master/products" class="nav-item <%=fullPath.contains("product") ? "active" : ""%>">Mặt hàng</a>
            <% } %>

            <% if ("ADMIN".equals(navRole) || "CATALOG_MANAGER".equals(navRole) || "OPERATOR".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/master/slots" class="nav-item <%=fullPath.contains("slot") ? "active" : ""%>">Rãnh chứa</a>
            <% } %>

            <% if ("ADMIN".equals(navRole) || "OPERATOR".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/master/restocks" class="nav-item <%=fullPath.contains("restock") ? "active" : ""%>">Nạp hàng</a>
            <% } %>

            <% if ("ADMIN".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/admin/users" class="nav-item <%=fullPath.contains("/admin/user") || fullPath.contains("user_form") || fullPath.contains("/users") ? "active" : ""%>">Tài khoản</a>
                <a href="<%=request.getContextPath()%>/admin/roles" class="nav-item <%=fullPath.contains("role") ? "active" : ""%>">Phân quyền</a>
            <% } %>

            <a href="<%=request.getContextPath()%>/export" class="nav-item <%=fullPath.contains("export") ? "active" : ""%>">Xuất CSV</a>
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
