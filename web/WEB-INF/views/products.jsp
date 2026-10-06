<%@page import="java.util.List"%>
<%@page import="model.VendProduct"%>
<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser me = (AppUser) session.getAttribute("user");
    boolean canEdit = (me != null && ("ADMIN".equals(me.getRoleCode()) || "CATALOG_MANAGER".equals(me.getRoleCode())));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Danh mục mặt hàng - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">🍬 Quản lý Danh mục Mặt hàng</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Cấu hình Khối lượng danh định ($W_{danh\_định}$) và Dung sai ($\Delta_{dung\_sai}$) làm chuẩn đối chiếu cho máy bán hàng
                    </p>
                </div>
                <% if (canEdit) { %>
                    <a href="<%=request.getContextPath()%>/master/product/create" class="btn btn-primary">
                        ➕ Thêm mặt hàng mới
                    </a>
                <% } %>
            </div>

            <% if ("created".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span>✅ Đã thêm mặt hàng mới thành công!</span></div>
            <% } else if ("updated".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span>✅ Đã cập nhật mặt hàng thành công!</span></div>
            <% } else if ("deleted".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span>✅ Đã xóa mặt hàng thành công!</span></div>
            <% } else if ("fk_constraint".equals(request.getParameter("error"))) { %>
                <div class="alert alert-danger"><span>⚠️ Không thể xóa mặt hàng do đang được gán trong Rãnh máy bán hàng.</span></div>
            <% } %>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Mã SP</th>
                            <th>Tên mặt hàng</th>
                            <th>Khối lượng chuẩn ($W_{chuẩn}$)</th>
                            <th>Dung sai ($\pm\Delta$)</th>
                            <th>Đơn giá</th>
                            <th>Trạng thái</th>
                            <th>Ngày tạo</th>
                            <% if (canEdit) { %><th style="text-align:center;">Thao tác</th><% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<VendProduct> products = (List<VendProduct>) request.getAttribute("products");
                            if (products != null && !products.isEmpty()) {
                                for (VendProduct p : products) {
                        %>
                        <tr>
                            <td><span class="user-badge"><%=WebUtil.esc(p.getCode())%></span></td>
                            <td><strong><%=WebUtil.esc(p.getName())%></strong></td>
                            <td><span class="badge badge-info"><%=WebUtil.formatWeight(p.getNominalWeight())%></span></td>
                            <td>&plusmn; <%=WebUtil.formatWeight(p.getTolerance())%></td>
                            <td><%=WebUtil.formatCurrency(p.getPrice())%></td>
                            <td>
                                <% if (p.isActive()) { %>
                                    <span class="badge badge-success">Đang kinh doanh</span>
                                <% } else { %>
                                    <span class="badge badge-danger">Tạm ngưng</span>
                                <% } %>
                            </td>
                            <td><%=WebUtil.formatDateTime(p.getCreatedAt())%></td>
                            <% if (canEdit) { %>
                            <td style="text-align:center;">
                                <div style="display:inline-flex; gap:0.4rem;">
                                    <a href="<%=request.getContextPath()%>/master/product/edit?id=<%=p.getProductId()%>" class="btn btn-outline btn-sm">Sửa</a>
                                    <a href="<%=request.getContextPath()%>/master/product/delete?id=<%=p.getProductId()%>" class="btn btn-danger btn-sm" onclick="return confirm('Bạn có chắc chắn muốn xóa mặt hàng này?');">Xóa</a>
                                </div>
                            </td>
                            <% } %>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" style="text-align:center; color:var(--text-muted);">Chưa có mặt hàng nào trong hệ thống.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
