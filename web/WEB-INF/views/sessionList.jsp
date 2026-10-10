<%@page import="java.util.List"%>
<%@page import="model.VendSession"%>
<%@page import="model.VendSlot"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Danh sách phiên đo - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title"> Danh sách Phiên đo Lượt nhả hàng (Vend Sessions)</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Tổng số phiên: <strong><%=request.getAttribute("totalSessions")%></strong> lượt chạy thực nghiệm
                    </p>
                </div>
                <a href="<%=request.getContextPath()%>/export" class="btn btn-outline">
                     Xuất dữ liệu CSV
                </a>
            </div>

            <!-- SEARCH / FILTER -->
            <form action="<%=request.getContextPath()%>/sessions" method="GET" class="filter-bar" style="display:flex; gap:0.75rem; flex-wrap:wrap; margin-bottom:1.25rem;">
                <%
                    String currentLabel = (String) request.getAttribute("label");
                    Integer currentSlotId = (Integer) request.getAttribute("slotId");
                    List<VendSlot> slots = (List<VendSlot>) request.getAttribute("slots");
                %>
                <select name="label" style="min-width:180px; flex:1;">
                    <option value="">-- Tất cả phân loại --</option>
                    <option value="SUCCESS" <%="SUCCESS".equals(currentLabel) ? "selected" : ""%>>SUCCESS (Thành công)</option>
                    <option value="JAM" <%="JAM".equals(currentLabel) ? "selected" : ""%>>JAM (Kẹt rãnh)</option>
                    <option value="WRONG_ITEM" <%="WRONG_ITEM".equals(currentLabel) ? "selected" : ""%>>WRONG_ITEM (Rơi 2 món/Sai)</option>
                    <option value="MOTOR_FAIL" <%="MOTOR_FAIL".equals(currentLabel) ? "selected" : ""%>>MOTOR_FAIL (Lỗi động cơ)</option>
                </select>

                <select name="slotId" style="min-width:180px; flex:1;">
                    <option value="">-- Tất cả các rãnh --</option>
                    <% if (slots != null) {
                        for (VendSlot s : slots) {
                    %>
                        <option value="<%=s.getSlotId()%>" <%=(currentSlotId != null && currentSlotId == s.getSlotId()) ? "selected" : ""%>><%=s.getCode()%> (<%=s.getProductName() != null ? s.getProductName() : "Trống"%>)</option>
                    <% } } %>
                </select>

                <div style="display:flex; gap:0.5rem;">
                    <button type="submit" class="btn btn-primary"> Lọc phiên</button>
                    <a href="<%=request.getContextPath()%>/sessions" class="btn btn-outline">Xóa lọc</a>
                </div>
            </form>

            <!-- SESSION TABLE -->
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Seq #</th>
                            <th>Rãnh / Mặt hàng</th>
                            <th>Động cơ quay?</th>
                            <th>Thời gian quay</th>
                            <th>Khối lượng ($W_{trước} \rightarrow W_{sau}$)</th>
                            <th>Độ tăng ($\Delta W$)</th>
                            <th>Nhãn phân loại</th>
                            <th>Nguồn nhãn</th>
                            <th style="text-align:center;">Chi tiết</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<VendSession> sessions = (List<VendSession>) request.getAttribute("sessions");
                            if (sessions != null && !sessions.isEmpty()) {
                                for (VendSession s : sessions) {
                                    String lbl = s.getCurrentLabel();
                        %>
                        <tr>
                            <td><strong>#<%=s.getDeviceSeq()%></strong></td>
                            <td>
                                <div><span class="user-badge"><%=s.getSlotCode()%></span></div>
                                <small style="color:var(--text-muted);"><%=s.getProductName() != null ? WebUtil.esc(s.getProductName()) : "-"%></small>
                            </td>
                            <td>
                                <% if (s.getCoilTurns() >= 1) { %>
                                    <span class="badge badge-success">1 Vòng</span>
                                <% } else { %>
                                    <span class="badge badge-danger">Chưa đủ vòng</span>
                                <% } %>
                            </td>
                            <td><%=s.getMotorMs()%> ms</td>
                            <td><%=WebUtil.formatWeight(s.getWeightBefore())%> &rarr; <%=WebUtil.formatWeight(s.getWeightAfter())%></td>
                            <td><strong>+<%=WebUtil.formatWeight(s.getWeightDelta())%></strong></td>
                            <td>
                                <% if ("SUCCESS".equals(lbl)) { %>
                                    <span class="badge badge-success">SUCCESS</span>
                                <% } else if ("JAM".equals(lbl)) { %>
                                    <span class="badge badge-danger">JAM</span>
                                <% } else if ("WRONG_ITEM".equals(lbl)) { %>
                                    <span class="badge badge-warning">WRONG_ITEM</span>
                                <% } else if ("MOTOR_FAIL".equals(lbl)) { %>
                                    <span class="badge badge-purple">MOTOR_FAIL</span>
                                <% } else { %>
                                    <span class="badge badge-info"><%=lbl%></span>
                                <% } %>
                            </td>
                            <td>
                                <% if ("REVIEWER".equals(s.getLabelSource())) { %>
                                    <span class="badge badge-warning">Reviewer</span>
                                <% } else { %>
                                    <span style="color:var(--text-muted); font-size:0.8rem;">Auto (System)</span>
                                <% } %>
                            </td>
                            <td style="text-align:center;">
                                <a href="<%=request.getContextPath()%>/session/detail?id=<%=s.getSessionId()%>" class="btn btn-outline btn-sm">
                                     Xem & Sửa
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="9" style="text-align:center; color:var(--text-muted);">Không tìm thấy phiên đo nào.</td>
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
                    String filterQuery = "";
                    if (currentLabel != null && !currentLabel.trim().isEmpty()) {
                        filterQuery += "&label=" + java.net.URLEncoder.encode(currentLabel, "UTF-8");
                    }
                    if (currentSlotId != null && currentSlotId > 0) {
                        filterQuery += "&slotId=" + currentSlotId;
                    }
            %>
            <div class="pagination-wrapper">
                <div class="pagination-info">
                    Đang xem trang <strong><%=currentPage%></strong> / <strong><%=totalPages%></strong>
                </div>

                <div class="pagination">
                    <% if (currentPage > 1) { %>
                        <a href="<%=request.getContextPath()%>/sessions?page=<%=currentPage - 1%><%=filterQuery%>" class="page-btn" title="Trang trước">&laquo;</a>
                    <% } else { %>
                        <span class="page-btn disabled" title="Đang ở trang đầu">&laquo;</span>
                    <% } %>

                    <div class="pagination-numbers">
                        <%
                            int startP = Math.max(1, currentPage - 1);
                            int endP = Math.min(totalPages, currentPage + 1);
                            if (startP > 1) {
                        %>
                            <a href="<%=request.getContextPath()%>/sessions?page=1<%=filterQuery%>" class="page-btn">1</a>
                            <% if (startP > 2) { %><span class="page-dots">&hellip;</span><% } %>
                        <% } %>

                        <% for (int p = startP; p <= endP; p++) { %>
                            <% if (p == currentPage) { %>
                                <span class="page-btn active"><%=p%></span>
                            <% } else { %>
                                <a href="<%=request.getContextPath()%>/sessions?page=<%=p%><%=filterQuery%>" class="page-btn"><%=p%></a>
                            <% } %>
                        <% } %>

                        <% if (endP < totalPages) { %>
                            <% if (endP < totalPages - 1) { %><span class="page-dots">&hellip;</span><% } %>
                            <a href="<%=request.getContextPath()%>/sessions?page=<%=totalPages%><%=filterQuery%>" class="page-btn"><%=totalPages%></a>
                        <% } %>
                    </div>

                    <% if (currentPage < totalPages) { %>
                        <a href="<%=request.getContextPath()%>/sessions?page=<%=currentPage + 1%><%=filterQuery%>" class="page-btn" title="Trang sau">&raquo;</a>
                    <% } else { %>
                        <span class="page-btn disabled" title="Đang ở trang cuối">&raquo;</span>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</body>
</html>
