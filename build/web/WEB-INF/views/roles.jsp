<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.AppRole" %>
<%@ page import="util.WebUtil" %>
<%
    List<AppRole> roles = (List<AppRole>) request.getAttribute("roles");
    Map<Integer, Integer> userCounts = (Map<Integer, Integer>) request.getAttribute("userCounts");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vai trò & Phân quyền | VendGuard PRJ301</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/nav.jsp"/>

    <main class="main-wrapper">
        <div class="page-header">
            <div>
                <h1 class="page-title">🛡️ Quản lý vai trò & Ma trận phân quyền</h1>
                <p class="page-subtitle">Hệ thống phân quyền 5 vai trò độc lập theo đúng quy chuẩn Mục VI & VII đề tài PRJ301</p>
            </div>
            <div>
                <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-secondary">
                    👥 Danh sách người dùng
                </a>
            </div>
        </div>

        <!-- Danh sach 5 vai tro -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">1. Danh sách 5 vai trò hệ thống & Số lượng nhân sự</h2>
            </div>
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width: 60px;">ID</th>
                            <th>Mã vai trò (Role Code)</th>
                            <th>Tên vai trò</th>
                            <th>Mô tả chức năng</th>
                            <th style="text-align: center;">Số lượng tài khoản</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (roles != null) {
                            for (AppRole r : roles) {
                                int count = userCounts != null && userCounts.get(r.getRoleId()) != null ? userCounts.get(r.getRoleId()) : 0;
                                String roleBadgeClass = "badge-viewer";
                                if ("ADMIN".equalsIgnoreCase(r.getRoleCode())) roleBadgeClass = "badge-admin";
                                else if ("CATALOG_MANAGER".equalsIgnoreCase(r.getRoleCode())) roleBadgeClass = "badge-catalog";
                                else if ("OPERATOR".equalsIgnoreCase(r.getRoleCode())) roleBadgeClass = "badge-operator";
                                else if ("REVIEWER".equalsIgnoreCase(r.getRoleCode())) roleBadgeClass = "badge-reviewer";
                        %>
                            <tr>
                                <td><b>#<%= r.getRoleId() %></b></td>
                                <td><span class="badge <%= roleBadgeClass %>"><%= r.getRoleCode() %></span></td>
                                <td><b><%= r.getRoleName() %></b></td>
                                <td style="color: var(--text-muted);"><%= r.getDescription() %></td>
                                <td style="text-align: center;">
                                    <span style="font-weight: 700; background: #e2e8f0; padding: 2px 10px; border-radius: 12px; font-size: 13px;">
                                        <%= count %> user
                                    </span>
                                </td>
                            </tr>
                        <%  }
                        } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Ma tran quyen du lieu -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">2. Bảng ma trận quyền trên từng đối tượng dữ liệu </h2>
                <span style="font-size: 12px; color: var(--text-muted);">
                    C: Thêm (Create) | R: Xem (Read) | U: Sửa (Update) | D: Xóa (Delete) | - : Không có quyền
                </span>
            </div>

            <div class="table-responsive">
                <table class="table" style="text-align: center;">
                    <thead>
                        <tr>
                            <th style="text-align: left;">Đối tượng dữ liệu</th>
                            <th style="color: #991b1b; text-align: center;">ADMIN</th>
                            <th style="color: #5b21b6; text-align: center;">CATALOG_MANAGER</th>
                            <th style="color: #92400e; text-align: center;">OPERATOR</th>
                            <th style="color: #1e40af; text-align: center;">REVIEWER</th>
                            <th style="color: #334155; text-align: center;">VIEWER</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td style="text-align: left;"><b>Phiên dữ liệu (Vend_Session)</b></td>
                            <td><span class="badge badge-admin">C R U D</span></td>
                            <td><span class="badge badge-catalog">R U</span></td>
                            <td><span class="badge badge-operator">R U</span></td>
                            <td><span class="badge badge-reviewer">R</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                        </tr>
                        <tr>
                            <td style="text-align: left;"><b>Nhãn của phiên (Vend_Label)</b></td>
                            <td><span class="badge badge-admin">C R U</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                            <td><span class="badge badge-reviewer">C R U</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                        </tr>
                        <tr>
                            <td style="text-align: left;"><b>Cảnh báo (Vend_Alert)</b></td>
                            <td><span class="badge badge-admin">C R U D</span></td>
                            <td><span class="badge badge-catalog">R U</span></td>
                            <td><span class="badge badge-operator">R U</span></td>
                            <td><span class="badge badge-reviewer">R U</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                        </tr>
                        <tr>
                            <td style="text-align: left;"><b>Mặt hàng (Vend_Product)</b></td>
                            <td><span class="badge badge-admin">C R U D</span></td>
                            <td><span class="badge badge-catalog">C R U D</span></td>
                            <td><span class="badge badge-operator">C R U D</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                        </tr>
                        <tr>
                            <td style="text-align: left;"><b>Rãnh chứa hàng (Vend_Slot)</b></td>
                            <td><span class="badge badge-admin">C R U D</span></td>
                            <td><span class="badge badge-catalog">C R U D</span></td>
                            <td><span class="badge badge-operator">C R U D</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                        </tr>
                        <tr>
                            <td style="text-align: left;"><b>Phiếu nạp hàng (Vend_Restock)</b></td>
                            <td><span class="badge badge-admin">C R U D</span></td>
                            <td><span class="badge badge-catalog">C R U D</span></td>
                            <td><span class="badge badge-operator">C R U D</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                            <td><span class="badge badge-viewer">R</span></td>
                        </tr>
                        <tr style="background: #fef2f2;">
                            <td style="text-align: left;"><b>Người dùng & Tài khoản (AppUser)</b></td>
                            <td><span class="badge badge-admin">C R U D</span></td>
                            <td style="color: #94a3b8; font-weight: bold;">-</td>
                            <td style="color: #94a3b8; font-weight: bold;">-</td>
                            <td style="color: #94a3b8; font-weight: bold;">-</td>
                            <td style="color: #94a3b8; font-weight: bold;">-</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            
        </div>
    </main>

    <footer class="footer">
        Đồ án PRJ301 - Đề số 01: Máy bán hàng thu nhỏ tự phát hiện kẹt hàng &copy; Fall 2026. Trường Đại học FPT.
    </footer>
</body>
</html>
