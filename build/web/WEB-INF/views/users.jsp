<%@page import="java.util.List"%>
<%@page import="model.AppUser"%>
<%@page import="model.AppRole"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Quản lý người dùng - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">👥 Danh sách người dùng hệ thống</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Tổng cộng: <strong><%=request.getAttribute("totalUsers")%></strong> tài khoản
                    </p>
                </div>
                <a href="<%=request.getContextPath()%>/admin/user/create" class="btn btn-primary">
                    ➕ Thêm tài khoản mới
                </a>
            </div>

            <!-- SEARCH / FILTER -->
            <form action="<%=request.getContextPath()%>/admin/users" method="GET" style="display:flex; gap:0.75rem; flex-wrap:wrap; margin-bottom:1.25rem;">
                <input type="text" name="q" value="<%=request.getAttribute("q") != null ? WebUtil.esc(request.getAttribute("q")) : ""%>" placeholder="Tìm theo username, họ tên, email..." style="flex:1; min-width:200px;">

                <select name="roleId" style="width:180px;">
                    <option value="">-- Tất cả vai trò --</option>
                    <%
                        List<AppRole> roles = (List<AppRole>) request.getAttribute("roles");
                        Integer selectedRoleId = (Integer) request.getAttribute("roleId");
                        if (roles != null) {
                            for (AppRole r : roles) {
                    %>
                        <option value="<%=r.getRoleId()%>" <%=(selectedRoleId != null && selectedRoleId == r.getRoleId()) ? "selected" : ""%>><%=r.getRoleName()%></option>
                    <%
                            }
                        }
                    %>
                </select>

                <select name="locked" style="width:160px;">
                    <option value="">-- Trạng thái --</option>
                    <option value="0" <%="0".equals(request.getAttribute("locked")) ? "selected" : ""%>>Đang hoạt động</option>
                    <option value="1" <%="1".equals(request.getAttribute("locked")) ? "selected" : ""%>>Đã bị khóa</option>
                </select>

                <button type="submit" class="btn btn-primary">🔍 Lọc</button>
                <a href="<%=request.getContextPath()%>/admin/users" class="btn btn-outline">Xóa lọc</a>
            </form>

            <!-- USER TABLE -->
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên đăng nhập</th>
                            <th>Họ và tên</th>
                            <th>Email / SĐT</th>
                            <th>Vai trò</th>
                            <th>Trạng thái</th>
                            <th>Ngày tạo</th>
                            <th style="text-align:center;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<AppUser> users = (List<AppUser>) request.getAttribute("users");
                            if (users != null && !users.isEmpty()) {
                                for (AppUser u : users) {
                        %>
                        <tr>
                            <td><%=u.getUserId()%></td>
                            <td><strong><%=WebUtil.esc(u.getUsername())%></strong></td>
                            <td><%=WebUtil.esc(u.getFullName())%></td>
                            <td>
                                <div><%=WebUtil.esc(u.getEmail())%></div>
                                <small style="color:var(--text-muted);"><%=WebUtil.esc(u.getPhone())%></small>
                            </td>
                            <td><span class="user-badge"><%=u.getRoleCode()%></span></td>
                            <td>
                                <% if (u.isLocked()) { %>
                                    <span class="badge badge-danger">Đã khóa</span>
                                <% } else { %>
                                    <span class="badge badge-success">Hoạt động</span>
                                <% } %>
                            </td>
                            <td><%=WebUtil.formatDateTime(u.getCreatedAt())%></td>
                            <td style="text-align:center;">
                                <div style="display:inline-flex; gap:0.35rem;">
                                    <a href="<%=request.getContextPath()%>/admin/user/edit?id=<%=u.getUserId()%>" class="btn btn-outline btn-sm">Sửa</a>
                                    <% if (u.isLocked()) { %>
                                        <a href="<%=request.getContextPath()%>/admin/user/action?act=unlock&id=<%=u.getUserId()%>" class="btn btn-success btn-sm" onclick="return confirm('Mở khóa tài khoản này?');">Mở</a>
                                    <% } else { %>
                                        <a href="<%=request.getContextPath()%>/admin/user/action?act=lock&id=<%=u.getUserId()%>" class="btn btn-warning btn-sm" onclick="return confirm('Khóa tài khoản này?');">Khóa</a>
                                    <% } %>
                                    <a href="<%=request.getContextPath()%>/admin/user/action?act=reset&id=<%=u.getUserId()%>" class="btn btn-outline btn-sm" onclick="return confirm('Reset mật khẩu về 123456?');">Reset</a>
                                    <a href="<%=request.getContextPath()%>/admin/user/action?act=delete&id=<%=u.getUserId()%>" class="btn btn-danger btn-sm" onclick="return confirm('Xóa vĩnh viễn tài khoản này?');">Xóa</a>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" style="text-align:center; color:var(--text-muted);">Không tìm thấy người dùng phù hợp.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- PAGINATION -->
            <%
                int currentPage = (Integer) request.getAttribute("currentPage");
                int totalPages = (Integer) request.getAttribute("totalPages");
                if (totalPages > 1) {
            %>
            <div class="pagination">
                <% for (int p = 1; p <= totalPages; p++) { %>
                    <a href="<%=request.getContextPath()%>/admin/users?page=<%=p%>&q=<%=(request.getAttribute("q")!=null?request.getAttribute("q"):"")%>&roleId=<%=(request.getAttribute("roleId")!=null?request.getAttribute("roleId"):"")%>&locked=<%=(request.getAttribute("locked")!=null?request.getAttribute("locked"):"")%>" class="<%=(p == currentPage ? "active" : "")%>"><%=p%></a>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>
</body>
</html>
