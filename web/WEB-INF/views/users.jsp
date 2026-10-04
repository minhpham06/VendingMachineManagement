<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.AppRole" %>
<%@ page import="model.AppUser" %>
<%@ page import="util.WebUtil" %>
<%
    List<AppUser> users = (List<AppUser>) request.getAttribute("users");
    List<AppRole> roles = (List<AppRole>) request.getAttribute("roles");
    int currentPage = (Integer) request.getAttribute("page");
    int totalPages = (Integer) request.getAttribute("totalPages");
    int totalUsers = (Integer) request.getAttribute("total");
    String query = (String) request.getAttribute("query");
    if (query == null) query = "";
    Integer selectedRoleId = (Integer) request.getAttribute("selectedRoleId");
    String selectedLocked = (String) request.getAttribute("selectedLocked");

    AppUser currentUser = (AppUser) session.getAttribute("user");
    String flashSuccess = (String) session.getAttribute("flashSuccess");
    String flashError = (String) session.getAttribute("flashError");
    session.removeAttribute("flashSuccess");
    session.removeAttribute("flashError");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý người dùng | VendGuard PRJ301</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/nav.jsp"/>

    <main class="main-wrapper">
        <div class="page-header">
            <div>
                <h1 class="page-title">👥 Quản lý người dùng & Phân vai trò</h1>
                <p class="page-subtitle">Tổng số: <b><%= totalUsers %></b> tài khoản trong hệ thống</p>
            </div>
            <div>
                <a href="<%= request.getContextPath() %>/admin/user/create" class="btn btn-primary">
                    ➕ Thêm người dùng mới
                </a>
            </div>
        </div>

        <% if (flashSuccess != null && !flashSuccess.isEmpty()) { %>
            <div class="alert alert-success">
                <span>✅ <%= WebUtil.esc(flashSuccess) %></span>
            </div>
        <% } %>

        <% if (flashError != null && !flashError.isEmpty()) { %>
            <div class="alert alert-danger">
                <span>⚠️ <%= WebUtil.esc(flashError) %></span>
            </div>
        <% } %>

        <!-- Filter Bar -->
        <form method="get" action="<%= request.getContextPath() %>/admin/users" class="filter-bar">
            <div style="flex: 1; min-width: 200px;">
                <input type="text" name="q" class="form-control" placeholder="Tìm theo username, họ tên, email..." 
                       value="<%= WebUtil.esc(query) %>">
            </div>

            <div style="min-width: 180px;">
                <select name="roleId" class="form-control">
                    <option value="">-- Tất cả vai trò --</option>
                    <% if (roles != null) {
                        for (AppRole r : roles) { %>
                            <option value="<%= r.getRoleId() %>" 
                                <%= (selectedRoleId != null && selectedRoleId == r.getRoleId()) ? "selected" : "" %>>
                                <%= r.getRoleName() %> (<%= r.getRoleCode() %>)
                            </option>
                    <%  }
                    } %>
                </select>
            </div>

            <div style="min-width: 150px;">
                <select name="locked" class="form-control">
                    <option value="">-- Trạng thái khóa --</option>
                    <option value="0" <%= "0".equals(selectedLocked) ? "selected" : "" %>>Đang hoạt động</option>
                    <option value="1" <%= "1".equals(selectedLocked) ? "selected" : "" %>>Bị khóa</option>
                </select>
            </div>

            <button type="submit" class="btn btn-secondary">🔍 Lọc dữ liệu</button>
            <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-secondary" title="Đặt lại bộ lọc">↺</a>
        </form>

        <!-- User Table -->
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th style="width: 50px;">ID</th>
                        <th>Tên đăng nhập</th>
                        <th>Họ và tên</th>
                        <th>Email / Điện thoại</th>
                        <th>Vai trò hệ thống</th>
                        <th>Trạng thái</th>
                        <th>Ngày tạo</th>
                        <th style="text-align: right; width: 220px;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (users != null && !users.isEmpty()) {
                        for (AppUser u : users) {
                            String roleBadgeClass = "badge-viewer";
                            if (u.isAdmin()) roleBadgeClass = "badge-admin";
                            else if (u.isCatalogManager()) roleBadgeClass = "badge-catalog";
                            else if (u.isOperator()) roleBadgeClass = "badge-operator";
                            else if (u.isReviewer()) roleBadgeClass = "badge-reviewer";
                    %>
                        <tr>
                            <td><b>#<%= u.getUserId() %></b></td>
                            <td>
                                <span style="font-weight: 700; color: var(--text-main);"><%= WebUtil.esc(u.getUsername()) %></span>
                                <% if (currentUser != null && currentUser.getUserId() == u.getUserId()) { %>
                                    <span style="font-size: 11px; background: #e0f2fe; color: #0369a1; padding: 2px 6px; border-radius: 4px; margin-left: 4px;">(Bạn)</span>
                                <% } %>
                            </td>
                            <td><%= WebUtil.esc(u.getFullName()) %></td>
                            <td>
                                <div><%= u.getEmail() != null ? WebUtil.esc(u.getEmail()) : "-" %></div>
                                <div style="font-size: 12px; color: var(--text-muted);"><%= u.getPhone() != null ? WebUtil.esc(u.getPhone()) : "" %></div>
                            </td>
                            <td>
                                <span class="badge <%= roleBadgeClass %>"><%= u.getRoleCode() %></span>
                            </td>
                            <td>
                                <% if (u.isLocked()) { %>
                                    <span class="badge badge-locked">🔒 Đã khóa</span>
                                <% } else { %>
                                    <span class="badge badge-active">🟢 Hoạt động</span>
                                <% } %>
                            </td>
                            <td style="font-size: 12.5px; color: var(--text-muted);">
                                <%= WebUtil.formatDateTime(u.getCreatedAt()) %>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: inline-flex; gap: 6px;">
                                    <a href="<%= request.getContextPath() %>/admin/user/edit?id=<%= u.getUserId() %>" 
                                       class="btn btn-sm btn-secondary" title="Sửa thông tin">
                                        ✏️ Sửa
                                    </a>

                                    <% if (currentUser != null && currentUser.getUserId() != u.getUserId()) { %>
                                        <% if (u.isLocked()) { %>
                                            <a href="<%= request.getContextPath() %>/admin/user/action?act=unlock&id=<%= u.getUserId() %>" 
                                               class="btn btn-sm btn-success" title="Mở khóa tài khoản"
                                               onclick="return confirm('Mở khóa cho tài khoản <%= u.getUsername() %>?');">
                                                🔓 Mở
                                            </a>
                                        <% } else { %>
                                            <a href="<%= request.getContextPath() %>/admin/user/action?act=lock&id=<%= u.getUserId() %>" 
                                               class="btn btn-sm btn-danger" title="Khóa tài khoản"
                                               onclick="return confirm('Bạn có chắc chắn muốn khóa tài khoản <%= u.getUsername() %>?');">
                                                🔒 Khóa
                                            </a>
                                        <% } %>

                                        <a href="<%= request.getContextPath() %>/admin/user/action?act=reset&id=<%= u.getUserId() %>" 
                                           class="btn btn-sm btn-warning" title="Đặt lại mật khẩu về 123456"
                                           onclick="return confirm('Đặt lại mật khẩu của <%= u.getUsername() %> về 123456?');">
                                            🔑 Reset
                                        </a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 36px; color: var(--text-muted);">
                                Không tìm thấy người dùng nào phù hợp với điều kiện tìm kiếm.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <% if (totalPages > 1) { %>
            <div class="pagination">
                <% for (int p = 1; p <= totalPages; p++) { %>
                    <a href="?page=<%= p %>&q=<%= WebUtil.esc(query) %>&roleId=<%= selectedRoleId != null ? selectedRoleId : "" %>&locked=<%= selectedLocked != null ? selectedLocked : "" %>" 
                       class="page-item <%= p == currentPage ? "active" : "" %>">
                        <%= p %>
                    </a>
                <% } %>
            </div>
        <% } %>
    </main>

    <footer class="footer">
        Đồ án PRJ301 - Đề số 01: Máy bán hàng thu nhỏ tự phát hiện kẹt hàng &copy; Fall 2026. Trường Đại học FPT.
    </footer>
</body>
</html>
