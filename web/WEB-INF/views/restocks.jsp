<%@page import="java.util.List"%>
<%@page import="model.VendRestock"%>
<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser me = (AppUser) session.getAttribute("user");
    boolean canRestock = (me != null && ("ADMIN".equals(me.getRoleCode()) || "OPERATOR".equals(me.getRoleCode())));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Lịch sử nạp hàng - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">📥 Lịch sử Phiếu Nạp Hàng (Restock Logs)</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Nhật ký các lượt bổ sung bánh kẹo vào rãnh máy bán hàng của Nhân viên vận hành (OPERATOR)
                    </p>
                </div>
                <% if (canRestock) { %>
                    <a href="<%=request.getContextPath()%>/master/restock/create" class="btn btn-primary">
                        ➕ Lập phiếu nạp hàng
                    </a>
                <% } %>
            </div>

            <% if ("created".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span>✅ Đã tạo phiếu nạp hàng và cập nhật tồn kho thành công!</span></div>
            <% } %>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Mã phiếu</th>
                            <th>Rãnh nạp</th>
                            <th>Mặt hàng</th>
                            <th>Số lượng nạp</th>
                            <th>Người thực hiện</th>
                            <th>Ghi chú vận hành</th>
                            <th>Thời gian nạp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<VendRestock> restocks = (List<VendRestock>) request.getAttribute("restocks");
                            if (restocks != null && !restocks.isEmpty()) {
                                for (VendRestock r : restocks) {
                        %>
                        <tr>
                            <td>#<%=r.getRestockId()%> (<%=WebUtil.esc(r.getCode())%>)</td>
                            <td><span class="user-badge"><%=r.getSlotCode()%></span></td>
                            <td><strong><%=r.getProductName() != null ? WebUtil.esc(r.getProductName()) : "-"%></strong></td>
                            <td><span class="badge badge-success">+<%=r.getQuantity()%> gói</span></td>
                            <td><%=WebUtil.esc(r.getRestockedByName())%></td>
                            <td style="color:var(--text-secondary);"><%=r.getNote() != null ? WebUtil.esc(r.getNote()) : "-"%></td>
                            <td><%=WebUtil.formatDateTime(r.getCreatedAt())%></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="7" style="text-align:center; color:var(--text-muted);">Chưa có lịch sử nạp hàng.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
