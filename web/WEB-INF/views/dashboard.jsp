<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Tổng quan hệ thống - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(380px, 1fr));
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }
        .canvas-container {
            position: relative;
            width: 100%;
            height: 260px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        canvas {
            max-width: 100%;
            max-height: 100%;
        }
    </style>
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <!-- KPI METRICS -->
        <%
            int totalSessions = (Integer) request.getAttribute("totalSessions");
            int totalAlerts = (Integer) request.getAttribute("totalAlerts");
            int totalProducts = (Integer) request.getAttribute("totalProducts");
            int totalSlots = (Integer) request.getAttribute("totalSlots");
            Map<String, Integer> labelCounts = (Map<String, Integer>) request.getAttribute("labelCounts");
            int successCnt = labelCounts.get("SUCCESS");
            int jamCnt = labelCounts.get("JAM");
            int wrongCnt = labelCounts.get("WRONG_ITEM");
            int motorCnt = labelCounts.get("MOTOR_FAIL");
            double successRate = totalSessions > 0 ? (double) successCnt / totalSessions * 100.0 : 0.0;
        %>

        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-label">Tổng lượt nhả hàng</span>
                <span class="stat-val"><%=totalSessions%></span>
            </div>
            <div class="stat-card success">
                <span class="stat-label">Thành công (SUCCESS)</span>
                <span class="stat-val"><%=successCnt%> <small style="font-size:0.9rem; color:var(--success);">(<%=String.format("%.1f", successRate)%>%)</small></span>
            </div>
            <div class="stat-card danger">
                <span class="stat-label">Kẹt hàng (JAM)</span>
                <span class="stat-val"><%=jamCnt%></span>
            </div>
            <div class="stat-card warning">
                <span class="stat-label">Rơi 2 món / Sai (WRONG)</span>
                <span class="stat-val"><%=wrongCnt%></span>
            </div>
            <div class="stat-card purple">
                <span class="stat-label">Lỗi động cơ (MOTOR_FAIL)</span>
                <span class="stat-val"><%=motorCnt%></span>
            </div>
            <div class="stat-card <%=(totalAlerts > 0 ? "danger" : "")%>">
                <span class="stat-label">Cảnh báo chưa xử lý</span>
                <span class="stat-val"><%=totalAlerts%></span>
            </div>
        </div>

        <!-- CHARTS SECTION -->
        <div class="charts-grid">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">🍩 Cơ cấu phân loại lượt nhả</h3>
                </div>
                <div class="canvas-container">
                    <canvas id="donutChart" width="360" height="240"></canvas>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">📊 Tỷ lệ kẹt theo mặt hàng (%)</h3>
                </div>
                <div class="canvas-container">
                    <canvas id="barChart" width="380" height="240"></canvas>
                </div>
            </div>
        </div>

        <!-- PRODUCT STATS TABLE -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">📦 Thống kê chi tiết theo Mặt hàng & Rãnh</h3>
            </div>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Mặt hàng</th>
                            <th>Tổng lượt chạy</th>
                            <th>Thành công</th>
                            <th>Kẹt hàng (JAM)</th>
                            <th>Tỷ lệ kẹt</th>
                            <th>Đánh giá rủi ro</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Map<String, Object>> pStats = (List<Map<String, Object>>) request.getAttribute("productStats");
                            if (pStats != null && !pStats.isEmpty()) {
                                for (Map<String, Object> p : pStats) {
                                    double rate = (Double) p.get("jamRate");
                        %>
                        <tr>
                            <td><strong><%=WebUtil.esc(p.get("name"))%></strong></td>
                            <td><%=p.get("total")%></td>
                            <td><span class="badge badge-success"><%=p.get("success")%></span></td>
                            <td><span class="badge badge-danger"><%=p.get("jam")%></span></td>
                            <td><strong><%=String.format("%.1f", rate)%>%</strong></td>
                            <td>
                                <% if (rate > 20.0) { %>
                                    <span class="badge badge-danger">Rủi ro cao (Cần chỉnh lò xo)</span>
                                <% } else if (rate > 10.0) { %>
                                    <span class="badge badge-warning">Cảnh báo trung bình</span>
                                <% } else { %>
                                    <span class="badge badge-success">Ổn định</span>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="6" style="text-align:center; color:var(--text-muted);">Chưa có dữ liệu thống kê mặt hàng.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <footer>
        Dự án PRJ301 - Đề số 01: Máy bán hàng tự động phát hiện kẹt hàng &copy; Fall 2026
    </footer>

    <!-- SCRIPT VE BIEU DO CANVAS THUAN (KHONG DUNG THU VIEN NGOAI) -->
    <script>
        // 1. Ve bieu do hinh tron Donut
        (function() {
            const canvas = document.getElementById('donutChart');
            if (!canvas) return;
            const ctx = canvas.getContext('2d');
            const data = [
                { label: 'SUCCESS', val: <%=successCnt%>, color: '#10b981' },
                { label: 'JAM', val: <%=jamCnt%>, color: '#ef4444' },
                { label: 'WRONG', val: <%=wrongCnt%>, color: '#f59e0b' },
                { label: 'MOTOR', val: <%=motorCnt%>, color: '#8b5cf6' }
            ];
            const total = <%=totalSessions%>;
            if (total === 0) return;

            let startAngle = -0.5 * Math.PI;
            const cx = 130, cy = 120, r = 85, innerR = 50;

            data.forEach(item => {
                const sliceAngle = (item.val / total) * 2 * Math.PI;
                ctx.beginPath();
                ctx.arc(cx, cy, r, startAngle, startAngle + sliceAngle);
                ctx.arc(cx, cy, innerR, startAngle + sliceAngle, startAngle, true);
                ctx.closePath();
                ctx.fillStyle = item.color;
                ctx.fill();
                startAngle += sliceAngle;
            });

            // Legend
            let legendY = 45;
            data.forEach(item => {
                ctx.fillStyle = item.color;
                ctx.fillRect(240, legendY, 12, 12);
                ctx.fillStyle = '#f8fafc';
                ctx.font = '12px Segoe UI';
                const pct = total > 0 ? ((item.val/total)*100).toFixed(1) : 0;
                ctx.fillText(item.label + ': ' + item.val + ' (' + pct + '%)', 260, legendY + 10);
                legendY += 32;
            });
        })();

        // 2. Ve bieu do cot Bar Chart
        (function() {
            const canvas = document.getElementById('barChart');
            if (!canvas) return;
            const ctx = canvas.getContext('2d');

            const prodNames = [
                <% if (pStats != null) {
                    for (int i=0; i<pStats.size(); i++) { %>
                        "<%=WebUtil.esc(pStats.get(i).get("name"))%>"<%= (i < pStats.size()-1) ? "," : "" %>
                <% } } %>
            ];
            const jamRates = [
                <% if (pStats != null) {
                    for (int i=0; i<pStats.size(); i++) { %>
                        <%=String.format("%.1f", (Double)pStats.get(i).get("jamRate"))%><%= (i < pStats.size()-1) ? "," : "" %>
                <% } } %>
            ];

            if (prodNames.length === 0) return;

            const paddingLeft = 40, paddingBottom = 40, chartW = 320, chartH = 170;
            const maxVal = 40; // Max 40%

            // Axes
            ctx.strokeStyle = 'rgba(255,255,255,0.15)';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(paddingLeft, 20);
            ctx.lineTo(paddingLeft, 20 + chartH);
            ctx.lineTo(paddingLeft + chartW, 20 + chartH);
            ctx.stroke();

            // Y-axis labels
            ctx.fillStyle = '#94a3b8';
            ctx.font = '10px Segoe UI';
            ctx.fillText('40%', 10, 25);
            ctx.fillText('20%', 10, 20 + chartH/2);
            ctx.fillText('0%', 15, 20 + chartH);

            const barW = 45;
            const gap = (chartW - (prodNames.length * barW)) / (prodNames.length + 1);

            prodNames.forEach((name, idx) => {
                const rate = jamRates[idx] || 0;
                const h = (rate / maxVal) * chartH;
                const x = paddingLeft + gap + idx * (barW + gap);
                const y = 20 + chartH - h;

                // Bar gradient
                const grad = ctx.createLinearGradient(x, y, x, y + h);
                grad.addColorStop(0, '#f87171');
                grad.addColorStop(1, '#dc2626');

                ctx.fillStyle = grad;
                ctx.fillRect(x, y, barW, h);

                // Label rate on top
                ctx.fillStyle = '#f8fafc';
                ctx.font = 'bold 11px Segoe UI';
                ctx.fillText(rate + '%', x + 8, y - 5);

                // Product label below
                ctx.fillStyle = '#94a3b8';
                ctx.font = '10px Segoe UI';
                const shortName = name.length > 10 ? name.substring(0, 10) + '..' : name;
                ctx.fillText(shortName, x - 5, 20 + chartH + 18);
            });
        })();
    </script>
</body>
</html>
