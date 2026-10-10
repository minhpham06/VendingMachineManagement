<%@page import="java.util.List"%>
<%@page import="model.VendAlert"%>
<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser me = (AppUser) session.getAttribute("user");
    boolean canResolve = (me != null && ("ADMIN".equals(me.getRoleCode()) || "OPERATOR".equals(me.getRoleCode())));
    String filter = (String) request.getAttribute("filter");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Cảnh báo thông minh - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title"> Động cơ Cảnh báo Thông minh (Smart Alert Engine)</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        4 quy tắc đề tài: Kẹt rãnh liên tiếp (JAM Streak), Cảnh báo sắp hết hàng (Low Stock), Trôi dạt cảm biến (Drift) & Mòn động cơ
                    </p>
                </div>
                <div style="display:flex; gap:0.5rem;">
                    <a href="<%=request.getContextPath()%>/alerts?filter=unresolved" class="btn <%=(!"all".equalsIgnoreCase(filter) ? "btn-primary" : "btn-outline")%> btn-sm">
                        Chưa xử lý (<%=request.getAttribute("unresolvedCount")%>)
                    </a>
                    <a href="<%=request.getContextPath()%>/alerts?filter=all" class="btn <%=( "all".equalsIgnoreCase(filter) ? "btn-primary" : "btn-outline")%> btn-sm">
                        Tất cả cảnh báo
                    </a>
                </div>
            </div>

            <% if ("resolved".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span> Đã xử lý và đóng cảnh báo thành công!</span></div>
            <% } %>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Mã</th>
                            <th>Mức độ</th>
                            <th>Loại cảnh báo</th>
                            <th>Rãnh liên quan</th>
                            <th>Nội dung thông báo</th>
                            <th>Trạng thái</th>
                            <th>Thời gian</th>
                            <% if (canResolve) { %><th style="text-align:center;">Xử lý</th><% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<VendAlert> alerts = (List<VendAlert>) request.getAttribute("alerts");
                            if (alerts != null && !alerts.isEmpty()) {
                                for (VendAlert a : alerts) {
                        %>
                        <tr>
                            <td>#<%=a.getAlertId()%></td>
                            <td>
                                <% if ("CRITICAL".equalsIgnoreCase(a.getSeverity())) { %>
                                    <span class="badge badge-danger">CRITICAL</span>
                                <% } else if ("WARNING".equalsIgnoreCase(a.getSeverity())) { %>
                                    <span class="badge badge-warning">WARNING</span>
                                <% } else { %>
                                    <span class="badge badge-info">INFO</span>
                                <% } %>
                            </td>
                            <td><strong><%=a.getRuleCode()%></strong></td>
                            <td>
                                <% if (a.getSlotCode() != null) { %>
                                    <span class="user-badge"><%=a.getSlotCode()%></span>
                                <% } else { %>
                                    -
                                <% } %>
                            </td>
                            <td style="max-width:320px;"><%=WebUtil.esc(a.getMessage())%></td>
                            <td>
                                <% if (a.isResolved()) { %>
                                    <span class="badge badge-success">Đã xử lý bởi <%=WebUtil.esc(a.getHandlerName())%></span>
                                <% } else { %>
                                    <span class="badge badge-danger">Chưa xử lý (OPEN)</span>
                                <% } %>
                            </td>
                            <td><%=WebUtil.formatDateTime(a.getCreatedAt())%></td>
                            <% if (canResolve) { %>
                            <td style="text-align:center;">
                                <% if (!a.isResolved()) { %>
                                    <form action="<%=request.getContextPath()%>/alert/resolve" method="POST" style="display:inline;">
                                        <input type="hidden" name="id" value="<%=a.getAlertId()%>">
                                        <button type="submit" class="btn btn-success btn-sm" onclick="return confirm('Đánh dấu đã xử lý cảnh báo này?');">
                                             Xử lý
                                        </button>
                                    </form>
                                <% } else { %>
                                    <span style="color:var(--text-muted); font-size:0.8rem;">Đã đóng</span>
                                <% } %>
                            </td>
                            <% } %>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" style="text-align:center; color:var(--text-muted);">Không có cảnh báo nào.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
