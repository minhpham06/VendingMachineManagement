<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="model.AppRole"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Phân quyền & Vai trò - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">🛡️ Danh sách Vai trò & Ma trận Quyền hệ thống</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        5 vai trò chuẩn đề tài được kiểm soát chặt chẽ qua <code>AuthFilter</code>
                    </p>
                </div>
            </div>

            <div class="table-responsive" style="margin-bottom:2rem;">
                <table>
                    <thead>
                        <tr>
                            <th>Mã vai trò</th>
                            <th>Tên hiển thị</th>
                            <th>Mô tả trách nhiệm</th>
                            <th style="text-align:center;">Số người dùng</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<AppRole> roles = (List<AppRole>) request.getAttribute("roles");
                            Map<Integer, Integer> userCounts = (Map<Integer, Integer>) request.getAttribute("userCounts");
                            if (roles != null) {
                                for (AppRole r : roles) {
                                    int count = userCounts != null && userCounts.containsKey(r.getRoleId()) ? userCounts.get(r.getRoleId()) : 0;
                        %>
                        <tr>
                            <td><span class="user-badge"><%=r.getRoleCode()%></span></td>
                            <td><strong><%=WebUtil.esc(r.getRoleName())%></strong></td>
                            <td style="color:var(--text-secondary);"><%=WebUtil.esc(r.getDescription())%></td>
                            <td style="text-align:center;"><span class="badge badge-info"><%=count%></span></td>
                        </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <!-- PERMISSION MATRIX -->
            <div class="card-header">
                <h3 class="card-title" style="font-size:1.1rem;">📋 Ma trận phân quyền theo Phân hệ</h3>
            </div>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Phân hệ chức năng</th>
                            <th style="text-align:center;">ADMIN</th>
                            <th style="text-align:center;">CATALOG_MGR</th>
                            <th style="text-align:center;">OPERATOR</th>
                            <th style="text-align:center;">REVIEWER</th>
                            <th style="text-align:center;">VIEWER</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>Quản trị Tài khoản & Thiết bị (/admin/*)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Toàn quyền</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                        </tr>
                        <tr>
                            <td><strong>Danh mục Mặt hàng (/master/product*)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Toàn quyền</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Toàn quyền</span></td>
                            <td style="text-align:center;"><span class="badge badge-info">Xem</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                        </tr>
                        <tr>
                            <td><strong>Quản lý Rãnh lò xo (/master/slot*)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Toàn quyền</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Cấu hình</span></td>
                            <td style="text-align:center;"><span class="badge badge-warning">Khóa/Mở</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                        </tr>
                        <tr>
                            <td><strong>Lập phiếu nạp hàng (/master/restock*)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Toàn quyền</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Tạo mới</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                        </tr>
                        <tr>
                            <td><strong>Kiểm duyệt & Sửa nhãn (/label/*)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Toàn quyền</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Sửa nhãn + Lý do</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                        </tr>
                        <tr>
                            <td><strong>Xử lý cảnh báo (/alert/resolve)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Toàn quyền</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Xử lý</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">Không</span></td>
                        </tr>
                        <tr>
                            <td><strong>Dashboard, Xem Phiên & Xuất CSV</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Xem + Xuất</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Xem + Xuất</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Xem + Xuất</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Xem + Xuất</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Xem + Xuất</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
