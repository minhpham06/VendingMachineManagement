<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.VendSession" %>
<%@ page import="util.WebUtil" %>
<%
    List<VendSession> rows = (List<VendSession>) request.getAttribute("rows");
    int currentPage = (Integer) request.getAttribute("page");
    int totalPages = (Integer) request.getAttribute("pages");
    int total = (Integer) request.getAttribute("total");
    String label = (String) request.getAttribute("label");
    if (label == null) label = "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" con 0tent="width=device-width, initial-scale=1.0">
    <title>Danh sác`    h phiên dữ liệu | VendGuard PRJ301</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/nav.jsp"/>

    <main class="main-wrapper">
        <div class="page-header">
            <div>
                <h1 class="page-title">📦 Danh sách phiên nhả hàng</h1>
                <p class="page-subtitle">Tổng số: <b><%= total %></b> phiên ghi nhận (Đối chiếu số vòng quay lò xo và khối lượng khay)</p>
            </div>
            <div>
                <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-secondary">
                    ← Về Bảng điều khiển
                </a>
            </div>
        </div>

        <!-- Filter Bar -->
        <form method="get" action="<%= request.getContextPath() %>/sessions" class="filter-bar">
            <div style="min-width: 220px;">
                <select name="label" class="form-control">
                    <option value="">-- Tất cả nhãn phân loại --</option>
                    <option value="SUCCESS" <%= "SUCCESS".equals(label) ? "selected" : "" %>>SUCCESS (Nhả hàng thành công)</option>
                    <option value="JAM" <%= "JAM".equals(label) ? "selected" : "" %>>JAM (Kẹt hàng trong rãnh)</option>
                    <option value="WRONG_ITEM" <%= "WRONG_ITEM".equals(label) ? "selected" : "" %>>WRONG_ITEM (Sai món / Rơi đôi)</option>
                    <option value="MOTOR_FAIL" <%= "MOTOR_FAIL".equals(label) ? "selected" : "" %>>MOTOR_FAIL (Lỗi động cơ / Kẹt trục)</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">🔍 Lọc danh sách</button>
            <a href="<%= request.getContextPath() %>/sessions" class="btn btn-secondary" title="Đặt lại bộ lọc">↺</a>
        </form>

        <!-- Sessions Grid -->
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th style="width: 60px;">#ID</th>
                        <th>Thời điểm đo</th>
                        <th>Thiết bị</th>
                        <th>Khối lượng trước (g)</th>
                        <th>Khối lượng sau (g)</th>
                        <th>Chênh lệch (Δg)</th>
                        <th>Vòng quay</th>
                        <th>Thời gian motor (ms)</th>
                        <th>Nhãn phân loại</th>
                        <th>Nguồn dữ liệu</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (rows != null && !rows.isEmpty()) {
                        for (VendSession r : rows) {
                            String badgeClass = "badge-viewer";
                            if ("SUCCESS".equals(r.getLabelCode())) badgeClass = "badge-success";
                            else if ("JAM".equals(r.getLabelCode())) badgeClass = "badge-jam";
                            else if ("WRONG_ITEM".equals(r.getLabelCode())) badgeClass = "badge-wrong";
                            else if ("MOTOR_FAIL".equals(r.getLabelCode())) badgeClass = "badge-motor";
                    %>
                        <tr>
                            <td><b>#<%= r.getSessionId() %></b></td>
                            <td style="font-size: 13px;">
                                <%= WebUtil.formatDateTime(r.getMeasuredAt()) %>
                            </td>
                            <td>
                                <b><%= r.getDeviceCode() != null ? r.getDeviceCode() : "DEV-" + r.getDeviceId() %></b>
                                <span style="font-size: 11px; color: var(--text-muted);">(Seq: <%= r.getDeviceSeq() %>)</span>
                            </td>
                            <td><%= String.format("%.2f", r.getWeightBefore()) %></td>
                            <td><%= String.format("%.2f", r.getWeightAfter()) %></td>
                            <td>
                                <b style="color: <%= r.getWeightDelta() > 0 ? "#047857" : "#b91c1c" %>;">
                                    +<%= String.format("%.2f", r.getWeightDelta()) %> g
                                </b>
                            </td>
                            <td><%= r.getCoilTurns() %> vòng</td>
                            <td><%= r.getMotorMs() %> ms</td>
                            <td>
                                <span class="badge <%= badgeClass %>"><%= r.getLabelCode() %></span>
                            </td>
                            <td>
                                <span style="font-size: 11px; background: <%= r.isSample() ? "#f1f5f9" : "#dcfce7" %>; padding: 2px 6px; border-radius: 4px;">
                                    <%= r.isSample() ? "Dữ liệu mẫu" : "ESP32 thật" %>
                                </span>
                            </td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="10" style="text-align: center; padding: 36px; color: var(--text-muted);">
                                Không có phiên dữ liệu nào phù hợp với bộ lọc.
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
                    <a href="?page=<%= p %>&label=<%= WebUtil.esc(label) %>" 
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
