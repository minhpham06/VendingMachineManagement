<%@page import="java.util.List"%>
<%@page import="model.AppUser"%>
<%@page import="model.Device"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser navUser = (AppUser) session.getAttribute("user");
    String navRole = (navUser != null) ? navUser.getRoleCode() : "";

    List<Device> navDevices = (List<Device>) session.getAttribute("assignedDevices");
    Integer navCurrentDevId = (Integer) session.getAttribute("currentDeviceId");
    Device navCurrentDevice = (Device) session.getAttribute("currentDevice");

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
            Menu
        </button>
    </div>
    
    <div class="nav-collapse" id="nav-collapse">
        <div class="nav-menu">
            <a href="<%=request.getContextPath()%>/dashboard" class="nav-item <%=fullPath.contains("dashboard") ? "active" : ""%>">Dashboard</a>
            <a href="<%=request.getContextPath()%>/sessions" class="nav-item <%=fullPath.contains("session") ? "active" : ""%>">Sessions</a>
            <a href="<%=request.getContextPath()%>/alerts" class="nav-item <%=fullPath.contains("alert") ? "active" : ""%>">Alerts</a>

            <% if ("ADMIN".equals(navRole) || "CATALOG_MANAGER".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/master/products" class="nav-item <%=fullPath.contains("product") ? "active" : ""%>">Products</a>
            <% } %>

            <% if ("ADMIN".equals(navRole) || "CATALOG_MANAGER".equals(navRole) || "OPERATOR".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/master/slots" class="nav-item <%=fullPath.contains("slot") ? "active" : ""%>">Slots</a>
            <% } %>

            <% if ("ADMIN".equals(navRole) || "OPERATOR".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/master/restocks" class="nav-item <%=fullPath.contains("restock") ? "active" : ""%>">Restock</a>
            <% } %>

            <% if ("ADMIN".equals(navRole)) { %>
                <a href="<%=request.getContextPath()%>/admin/assignments" class="nav-item <%=fullPath.contains("assignment") ? "active" : ""%>" title="Machine Assignments">Assignments</a>
                <a href="<%=request.getContextPath()%>/admin/users" class="nav-item <%=fullPath.contains("/admin/user") || fullPath.contains("user_form") || fullPath.contains("/users") ? "active" : ""%>">Users</a>
                <a href="<%=request.getContextPath()%>/admin/roles" class="nav-item <%=fullPath.contains("role") ? "active" : ""%>">Roles & Permissions</a>
            <% } %>

            <a href="<%=request.getContextPath()%>/export" class="nav-item <%=fullPath.contains("export") ? "active" : ""%>">Export CSV</a>
            <a href="<%=request.getContextPath()%>/" class="nav-item" title="View customer storefront">Vending Store</a>
        </div>

        <div class="nav-right" style="display: flex; align-items: center; gap: 0.75rem;">
            <% if (navUser != null) { %>
                <!-- ACTIVE MACHINE SELECTOR (LIGHT THEME - NO ICONS) -->
                <% if (navDevices != null && !navDevices.isEmpty()) { %>
                    <div class="machine-selector-wrapper" style="display:flex; align-items:center; background: #f8fafc; padding: 4px 10px; border-radius: 8px; border: 1.5px solid #3b82f6; box-shadow: 0 1px 3px rgba(59, 130, 246, 0.1);">
                        <span style="font-size: 0.82rem; color: #1d4ed8; font-weight: 700; margin-right: 6px; display:flex; align-items:center; letter-spacing: 0.3px;">
                            Machine:
                        </span>
                        <select onchange="if(this.value) window.location.href='<%=request.getContextPath()%>/switch-machine?deviceId='+this.value;" 
                                style="background: transparent; color: #0f172a; border: none; font-size: 0.86rem; font-weight: 600; cursor: pointer; outline: none; padding-right: 4px;">
                            <% for (Device d : navDevices) { %>
                                <option value="<%=d.getDeviceId()%>" <%=(navCurrentDevId != null && navCurrentDevId == d.getDeviceId()) ? "selected" : ""%> style="background:#ffffff; color:#0f172a; font-weight:600;">
                                    <%=d.isHardwareDemo() ? "[HARDWARE] " : "[VIRTUAL] "%><%=d.getDeviceCode()%> - <%=d.getMachineName() != null ? d.getMachineName() : ""%>
                                </option>
                            <% } %>
                        </select>
                    </div>
                <% } else if (!"CATALOG_MANAGER".equals(navRole) && !"VIEWER".equals(navRole)) { %>
                    <span style="font-size: 0.78rem; font-weight: 600; color: #b91c1c; background: #fef2f2; border: 1px solid #fecaca; padding: 4px 10px; border-radius: 8px;">
                        Not Assigned
                    </span>
                <% } %>

                <a href="<%=request.getContextPath()%>/profile" class="nav-profile" title="View profile">
                    <span class="role-tag"><%=navUser.getRoleCode()%></span>
                    <span class="user-fullname"><%=navUser.getFullName()%></span>
                </a>
                <a href="<%=request.getContextPath()%>/logout" class="btn-logout">Logout</a>
            <% } else { %>
                <a href="<%=request.getContextPath()%>/login" class="nav-item">Login</a>
            <% } %>
        </div>
    </div>
</nav>
