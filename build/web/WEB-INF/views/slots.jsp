<%@page import="java.util.List"%>
<%@page import="model.VendSlot"%>
<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser me = (AppUser) session.getAttribute("user");
    boolean canEdit = (me != null && ("ADMIN".equals(me.getRoleCode()) || "CATALOG_MANAGER".equals(me.getRoleCode())));
    boolean canToggle = (me != null && ("ADMIN".equals(me.getRoleCode()) || "OPERATOR".equals(me.getRoleCode())));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Quản lý rãnh chứa hàng - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title"> Quản lý Rãnh chứa & Lò xo</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Theo dõi lượng tồn kho từng rãnh, sản phẩm gán vào và trạng thái tự khóa (SUSPENDED) khi phát hiện kẹt hàng liên tiếp
                    </p>
                </div>
            </div>

            <% if ("updated".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span> Đã cập nhật cấu hình rãnh thành công!</span></div>
            <% } else if ("toggled".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span> Đã chuyển đổi trạng thái rãnh thành công!</span></div>
            <% } %>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Mã Rãnh</th>
                            <th>Tên rãnh</th>
                            <th>Mặt hàng được gán</th>
                            <th>Khối lượng chuẩn</th>
                            <th>Sức chứa</th>
                            <th>Tồn kho</th>
                            <th>Trạng thái rãnh</th>
                            <th style="text-align:center;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<VendSlot> slots = (List<VendSlot>) request.getAttribute("slots");
                            if (slots != null && !slots.isEmpty()) {
                                for (VendSlot s : slots) {
                        %>
                        <tr>
                            <td><strong><span class="user-badge"><%=s.getCode()%></span></strong></td>
                            <td><%=WebUtil.esc(s.getName())%></td>
                            <td>
                                <% if (s.getProductName() != null) { %>
                                    <strong><%=WebUtil.esc(s.getProductName())%></strong>
                                <% } else { %>
                                    <span style="color:var(--text-muted);"><em>(Chưa gán mặt hàng)</em></span>
                                <% } %>
                            </td>
                            <td>
                                <% if (s.getProductName() != null) { %>
                                    <%=WebUtil.formatWeight(s.getNominalWeight())%> (&plusmn;<%=WebUtil.formatWeight(s.getTolerance())%>)
                                <% } else { %>
                                    -
                                <% } %>
                            </td>
                            <td><%=s.getCapacity()%> gói</td>
                            <td>
                                <strong><%=s.getCurrentStock()%></strong> / <%=s.getCapacity()%>
                                <% if (s.getCurrentStock() <= 2) { %>
                                    <span class="badge badge-warning" style="margin-left:0.4rem;">Sắp hết</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (!s.isSuspended()) { %>
                                    <span class="badge badge-success">Sẵn sàng (Active)</span>
                                <% } else { %>
                                    <span class="badge badge-danger">TỰ KHÓA (SUSPENDED)</span>
                                <% } %>
                            </td>
                            <td style="text-align:center;">
                                <div style="display:inline-flex; gap:0.4rem;">
                                    <% if (canEdit) { %>
                                        <a href="<%=request.getContextPath()%>/master/slot/edit?id=<%=s.getSlotId()%>" class="btn btn-outline btn-sm">Cấu hình</a>
                                    <% } %>
                                    <% if (canToggle) { %>
                                        <% if (!s.isSuspended()) { %>
                                            <a href="<%=request.getContextPath()%>/master/slot/toggle?id=<%=s.getSlotId()%>" class="btn btn-warning btn-sm" onclick="return confirm('Khóa tạm thời rãnh này?');">Khóa rãnh</a>
                                        <% } else { %>
                                            <a href="<%=request.getContextPath()%>/master/slot/toggle?id=<%=s.getSlotId()%>" class="btn btn-success btn-sm" onclick="return confirm('Mở khóa rãnh để tiếp tục bán?');">Mở khóa</a>
                                        <% } %>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" style="text-align:center; color:var(--text-muted);">Chưa có rãnh nào được cấu hình.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
