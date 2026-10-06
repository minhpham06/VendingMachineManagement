<%@page import="java.util.List"%>
<%@page import="model.VendSession"%>
<%@page import="model.VendLabel"%>
<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    VendSession s = (VendSession) request.getAttribute("sessionData");
    List<VendLabel> labelHistory = (List<VendLabel>) request.getAttribute("labelHistory");
    AppUser me = (AppUser) session.getAttribute("user");
    boolean canReview = (me != null && ("ADMIN".equals(me.getRoleCode()) || "REVIEWER".equals(me.getRoleCode())));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Chi tiết phiên đo #<%=s.getDeviceSeq()%> - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }
        @media (max-width: 768px) {
            .detail-grid { grid-template-columns: 1fr; }
        }
        .canvas-container {
            width: 100%;
            height: 250px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
    </style>
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <!-- HEADER -->
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
            <div>
                <h1 style="font-size:1.5rem;">🔬 Chi tiết Phiên Thực Nghiệm: Seq #<%=s.getDeviceSeq()%></h1>
                <p style="color:var(--text-secondary); font-size:0.85rem;">Mã phiên hệ thống: #<%=s.getSessionId()%> | Thời gian: <%=WebUtil.formatDateTime(s.getMeasuredAt())%></p>
            </div>
            <a href="<%=request.getContextPath()%>/sessions" class="btn btn-outline">⬅️ Danh sách phiên</a>
        </div>

        <% if ("corrected".equals(request.getParameter("success"))) { %>
            <div class="alert alert-success"><span>✅ Đã cập nhật và lưu vết lịch sử hiệu chỉnh nhãn thành công!</span></div>
        <% } %>
        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger"><span>⚠️ <%=request.getAttribute("errorMessage")%></span></div>
        <% } %>

        <div class="detail-grid">
            <!-- COT 1: THONG SO VAT LY -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">⚙️ Thông số Đo đạc Thực nghiệm</h3>
                    <span class="badge badge-info"><%=s.isSample() ? "Dữ liệu mẫu" : "Thực nghiệm ESP32"%></span>
                </div>

                <div style="display:flex; flex-direction:column; gap:0.85rem; font-size:0.92rem;">
                    <div style="display:flex; justify-content:space-between; border-bottom:1px solid rgba(255,255,255,0.05); padding-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Rãnh máy / Mặt hàng:</span>
                        <strong><%=s.getSlotCode()%> - <%=WebUtil.esc(s.getProductName())%></strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; border-bottom:1px solid rgba(255,255,255,0.05); padding-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Khối lượng danh định chuẩn:</span>
                        <span><%=WebUtil.formatWeight(s.getNominalWeight())%> (&plusmn;<%=WebUtil.formatWeight(s.getTolerance())%>)</span>
                    </div>
                    <div style="display:flex; justify-content:space-between; border-bottom:1px solid rgba(255,255,255,0.05); padding-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Cảm biến trục động cơ (Reed Switch):</span>
                        <span>
                            <% if (s.getCoilTurns() >= 1) { %>
                                <span class="badge badge-success">Quay đủ 1 vòng</span>
                            <% } else { %>
                                <span class="badge badge-danger">Kẹt motor (Chưa đủ vòng)</span>
                            <% } %>
                        </span>
                    </div>
                    <div style="display:flex; justify-content:space-between; border-bottom:1px solid rgba(255,255,255,0.05); padding-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Thời gian quay thực tế:</span>
                        <strong><%=s.getMotorMs()%> ms</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; border-bottom:1px solid rgba(255,255,255,0.05); padding-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Khối lượng trước khi nhả ($W_{trước}$):</span>
                        <span><%=WebUtil.formatWeight(s.getWeightBefore())%></span>
                    </div>
                    <div style="display:flex; justify-content:space-between; border-bottom:1px solid rgba(255,255,255,0.05); padding-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Độ lệch đỉnh khi rơi ($\Delta W_{peak}$):</span>
                        <span style="color:#f59e0b;"><%=WebUtil.formatWeight(s.getPeakDelta())%></span>
                    </div>
                    <div style="display:flex; justify-content:space-between; border-bottom:1px solid rgba(255,255,255,0.05); padding-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Khối lượng sau ổn định ($W_{sau}$):</span>
                        <span><%=WebUtil.formatWeight(s.getWeightAfter())%></span>
                    </div>
                    <div style="display:flex; justify-content:space-between; border-bottom:1px solid rgba(255,255,255,0.05); padding-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Độ tăng khối lượng khay ($\Delta W$):</span>
                        <strong style="font-size:1.05rem; color:#38bdf8;">+<%=WebUtil.formatWeight(s.getWeightDelta())%></strong>
                    </div>
                </div>
            </div>

            <!-- COT 2: BIEU DO DANG SONG CANVAS -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">📈 Đồ thị Biến thiên Khối lượng Khay (Weight Profile)</h3>
                </div>
                <div class="canvas-container">
                    <canvas id="weightWaveCanvas" width="460" height="230"></canvas>
                </div>
                <p style="font-size:0.78rem; color:var(--text-muted); text-align:center; margin-top:0.5rem;">
                    Mô phỏng 3 pha: Khối lượng ban đầu ($W_{trước}$) &rarr; Đỉnh xung lực ($W_{đỉnh}$) &rarr; Trạng thái cân bằng ($W_{sau}$)
                </p>
            </div>
        </div>

        <!-- LICH SU NHAN & REVIEWER FORM -->
        <div class="detail-grid">
            <!-- LICH SU NHAN -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">🏷️ Lịch sử Gán nhãn (Audit Trail)</h3>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Nhãn</th>
                                <th>Nguồn gán</th>
                                <th>Người duyệt</th>
                                <th>Lý do hiệu chỉnh</th>
                                <th>Thời gian</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (labelHistory != null && !labelHistory.isEmpty()) {
                                    for (VendLabel l : labelHistory) {
                            %>
                            <tr>
                                <td>
                                    <span class="badge <%=("SUCCESS".equals(l.getLabelCode()) ? "badge-success" : ("JAM".equals(l.getLabelCode()) ? "badge-danger" : ("WRONG_ITEM".equals(l.getLabelCode()) ? "badge-warning" : "badge-purple")))%>">
                                        <%=l.getLabelCode()%>
                                    </span>
                                </td>
                                <td>
                                    <% if ("REVIEWER".equals(l.getSource())) { %>
                                        <span class="badge badge-warning">Reviewer</span>
                                    <% } else { %>
                                        <span style="color:var(--text-muted);">Hệ thống (Auto)</span>
                                    <% } %>
                                </td>
                                <td><%=l.getReviewerName() != null ? WebUtil.esc(l.getReviewerName()) : "-"%></td>
                                <td style="color:var(--text-secondary);"><%=l.getReason() != null ? WebUtil.esc(l.getReason()) : "-"%></td>
                                <td><%=WebUtil.formatDateTime(l.getLabeledAt())%></td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- FORM REVIEWER SUA NHAN -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">✍️ Hiệu chỉnh Nhãn (Dành cho Reviewer)</h3>
                </div>

                <% if (canReview) { %>
                    <form action="<%=request.getContextPath()%>/label/correct" method="POST">
                        <input type="hidden" name="sessionId" value="<%=s.getSessionId()%>">

                        <div class="form-group">
                            <label for="newLabel">Chọn Nhãn chính xác (*)</label>
                            <select id="newLabel" name="newLabel" required>
                                <option value="SUCCESS" <%="SUCCESS".equals(s.getCurrentLabel()) ? "selected" : ""%>>SUCCESS (Nhả hàng thành công)</option>
                                <option value="JAM" <%="JAM".equals(s.getCurrentLabel()) ? "selected" : ""%>>JAM (Kẹt hàng trong rãnh)</option>
                                <option value="WRONG_ITEM" <%="WRONG_ITEM".equals(s.getCurrentLabel()) ? "selected" : ""%>>WRONG_ITEM (Rơi 2 món / Sai mặt hàng)</option>
                                <option value="MOTOR_FAIL" <%="MOTOR_FAIL".equals(s.getCurrentLabel()) ? "selected" : ""%>>MOTOR_FAIL (Lỗi trục động cơ)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="reason">Lý do hiệu chỉnh (* tối thiểu 5 ký tự)</label>
                            <textarea id="reason" name="reason" rows="3" placeholder="Nhập lý do hiệu chỉnh nhãn (vd: Đối chiếu video thấy rơi 2 gói kẹo)..." required minlength="5"></textarea>
                        </div>

                        <button type="submit" class="btn btn-warning" style="width:100%;">
                            💾 Xác nhận sửa nhãn (Lưu vào Audit Log)
                        </button>
                    </form>
                <% } else { %>
                    <div class="alert alert-warning">
                        <span>ℹ️ Chỉ người dùng có vai trò <strong>REVIEWER</strong> hoặc <strong>ADMIN</strong> mới có quyền hiệu chỉnh nhãn cho phiên này.</span>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- CANVAS WAVE SCRIPT -->
    <script>
        (function() {
            const canvas = document.getElementById('weightWaveCanvas');
            if (!canvas) return;
            const ctx = canvas.getContext('2d');

            const wBefore = <%=s.getWeightBefore()%>;
            const wDelta = <%=s.getWeightDelta()%>;
            const peakDelta = <%=s.getPeakDelta()%>;
            const wAfter = <%=s.getWeightAfter()%>;
            const wPeak = wBefore + peakDelta;

            const maxW = Math.max(60, wPeak + 10, wAfter + 10);
            const w = canvas.width, h = canvas.height;
            const padL = 40, padR = 20, padT = 30, padB = 40;
            const graphW = w - padL - padR;
            const graphH = h - padT - padB;

            function getY(val) {
                return padT + graphH - ((val / maxW) * graphH);
            }

            // Grid lines
            ctx.strokeStyle = 'rgba(255,255,255,0.08)';
            ctx.lineWidth = 1;
            for (let i = 0; i <= maxW; i += 15) {
                const y = getY(i);
                ctx.beginPath();
                ctx.moveTo(padL, y);
                ctx.lineTo(padL + graphW, y);
                ctx.stroke();

                ctx.fillStyle = '#64748b';
                ctx.font = '10px Segoe UI';
                ctx.fillText(i + 'g', 10, y + 3);
            }

            const p1 = { x: padL, y: getY(wBefore) };
            const p2 = { x: padL + graphW * 0.3, y: getY(wBefore) };
            const p3 = { x: padL + graphW * 0.45, y: getY(wPeak) };
            const p4 = { x: padL + graphW * 0.55, y: getY(wAfter - 2) };
            const p5 = { x: padL + graphW * 0.65, y: getY(wAfter + 1.5) };
            const p6 = { x: padL + graphW * 0.8, y: getY(wAfter) };
            const p7 = { x: padL + graphW, y: getY(wAfter) };

            ctx.beginPath();
            ctx.moveTo(p1.x, p1.y);
            ctx.lineTo(p2.x, p2.y);
            ctx.quadraticCurveTo(p2.x + 20, p3.y, p3.x, p3.y);
            ctx.quadraticCurveTo(p3.x + 15, p4.y, p4.x, p4.y);
            ctx.quadraticCurveTo(p4.x + 15, p5.y, p5.x, p5.y);
            ctx.quadraticCurveTo(p5.x + 20, p6.y, p6.x, p6.y);
            ctx.lineTo(p7.x, p7.y);

            ctx.strokeStyle = '#38bdf8';
            ctx.lineWidth = 3;
            ctx.stroke();

            ctx.lineTo(p7.x, padT + graphH);
            ctx.lineTo(p1.x, padT + graphH);
            ctx.closePath();
            const grad = ctx.createLinearGradient(0, padT, 0, padT + graphH);
            grad.addColorStop(0, 'rgba(56, 189, 248, 0.35)');
            grad.addColorStop(1, 'rgba(56, 189, 248, 0.0)');
            ctx.fillStyle = grad;
            ctx.fill();

            const points = [
                { pt: p2, label: 'Trước: ' + wBefore.toFixed(1) + 'g', color: '#94a3b8' },
                { pt: p3, label: 'Đỉnh: ' + wPeak.toFixed(1) + 'g', color: '#f59e0b' },
                { pt: p6, label: 'Sau: ' + wAfter.toFixed(1) + 'g', color: '#10b981' }
            ];

            points.forEach(item => {
                ctx.beginPath();
                ctx.arc(item.pt.x, item.pt.y, 5, 0, 2 * Math.PI);
                ctx.fillStyle = item.color;
                ctx.fill();
                ctx.strokeStyle = '#0f172a';
                ctx.lineWidth = 2;
                ctx.stroke();

                ctx.fillStyle = '#f8fafc';
                ctx.font = 'bold 11px Segoe UI';
                ctx.fillText(item.label, item.pt.x - 20, item.pt.y - 12);
            });
        })();
    </script>
</body>
</html>
