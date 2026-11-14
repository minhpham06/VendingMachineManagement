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
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Session Details #<%=s.getDeviceSeq()%> - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .detail-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 1.25rem;
            margin-bottom: 1.25rem;
            width: 100%;
        }
        @media (max-width: 768px) {
            .detail-grid {
                display: flex;
                flex-direction: column;
                gap: 1rem;
            }
        }
        .canvas-container {
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
            padding: 0.5rem 0;
        }
        .spec-list {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            font-size: 0.9rem;
        }
        .spec-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 0.45rem;
            flex-wrap: wrap;
            gap: 0.35rem;
        }
        .spec-label {
            color: var(--text-secondary);
            font-size: 0.88rem;
        }
    </style>
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <!-- HEADER -->
        <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:1.5rem; flex-wrap:wrap; gap:1rem;">
            <div>
                <h1 style="font-size:1.4rem;"> Experimental Session Details: Seq #<%=s.getDeviceSeq()%></h1>
                <p style="color:var(--text-secondary); font-size:0.85rem; margin-top:0.25rem;">System Session ID: #<%=s.getSessionId()%> | Timestamp: <%=WebUtil.formatDateTime(s.getMeasuredAt())%></p>
            </div>
            <a href="<%=request.getContextPath()%>/sessions" class="btn btn-outline btn-sm">Back to Sessions</a>
        </div>

        <% if ("corrected".equals(request.getParameter("success"))) { %>
            <div class="alert alert-success"><span> Label updated and audit trail saved successfully!</span></div>
        <% } %>
        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-danger"><span> <%=request.getAttribute("errorMessage")%></span></div>
        <% } %>

        <div class="detail-grid">
                
            <!-- COT 1: THONG SO VAT LY -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title"> Experimental Measurement Metrics</h3>
                    <span class="badge badge-info"><%=s.isSample() ? "Sample Data" : "ESP32 Experiment"%></span>
                </div>

                <div class="spec-list">
                    <div class="spec-row">
                        <span class="spec-label">Slot / Product:</span>
                        <strong><%=s.getSlotCode()%> - <%=WebUtil.esc(s.getProductName())%></strong>
                    </div>
                    <div class="spec-row">
                        <span class="spec-label">Standard Nominal Weight:</span>
                        <span><%=WebUtil.formatWeight(s.getNominalWeight())%> (&plusmn;<%=WebUtil.formatWeight(s.getTolerance())%>)</span>
                    </div>
                    <div class="spec-row">
                        <span class="spec-label">Motor Shaft Sensor (Reed Switch):</span>
                        <span>
                            <% if (s.getCoilTurns() >= 1) { %>
                                <span class="badge badge-success">Complete 1 Turn</span>
                            <% } else { %>
                                <span class="badge badge-danger">Motor Stalled (Incomplete)</span>
                            <% } %>
                        </span>
                    </div>
                    <div class="spec-row">
                        <span class="spec-label">Actual Rotation Duration:</span>
                        <strong><%=s.getMotorMs()%> ms</strong>
                    </div>
                    <div class="spec-row">
                        <span class="spec-label">Weight Before Dispense:</span>
                        <span><%=WebUtil.formatWeight(s.getWeightBefore())%></span>
                    </div>
                    <div class="spec-row">
                        <span class="spec-label">Impact Peak Delta:</span>
                        <span style="color:#f59e0b; font-weight:600;"><%=WebUtil.formatWeight(s.getPeakDelta())%></span>
                    </div>
                    <div class="spec-row">
                        <span class="spec-label">Weight After Stabilized:</span>
                        <span><%=WebUtil.formatWeight(s.getWeightAfter())%></span>
                    </div>
                    <div class="spec-row">
                        <span class="spec-label">Net Weight Delta:</span>
                        <strong style="font-size:1.05rem; color:#2563eb;">+<%=WebUtil.formatWeight(s.getWeightDelta())%></strong>
                    </div>
                </div>
            </div>

            <!-- COT 2: BIEU DO DANG SONG CANVAS -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title"> Dynamic Weight Profile Graph</h3>
                </div>
                <div class="canvas-container">
                    <canvas id="weightWaveCanvas" width="460" height="230" style="max-width:100%; height:auto; display:block;"></canvas>
                </div>
                <p style="font-size:0.78rem; color:var(--text-muted); text-align:center; margin-top:0.5rem;">
                    3-Phase Model: Initial ($W_{before}$) &rarr; Impact Peak ($W_{peak}$) &rarr; Stabilized ($W_{after}$)
                </p>
            </div>
        </div>

        <!-- LICH SU NHAN & REVIEWER FORM -->
        <div class="detail-grid">
            <!-- LICH SU NHAN -->
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title"> Label Audit Trail</h3>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Label</th>
                                <th>Source</th>
                                <th>Reviewer</th>
                                <th>Correction Reason</th>
                                <th>Timestamp</th>
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
                                        <span style="color:var(--text-muted);">System (Auto)</span>
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
                    <h3 class="card-title"> Label Correction (For Reviewers)</h3>
                </div>

                <% if (canReview) { %>
                    <form action="<%=request.getContextPath()%>/label/correct" method="POST">
                        <input type="hidden" name="sessionId" value="<%=s.getSessionId()%>">

                        <div class="form-group">
                            <label for="newLabel">Select Correct Label (*)</label>
                            <select id="newLabel" name="newLabel" required>
                                <option value="SUCCESS" <%="SUCCESS".equals(s.getCurrentLabel()) ? "selected" : ""%>>SUCCESS (Item Dispensed Successfully)</option>
                                <option value="JAM" <%="JAM".equals(s.getCurrentLabel()) ? "selected" : ""%>>JAM (Item Jammed in Coil)</option>
                                <option value="WRONG_ITEM" <%="WRONG_ITEM".equals(s.getCurrentLabel()) ? "selected" : ""%>>WRONG_ITEM (Double Drop / Wrong Item)</option>
                                <option value="MOTOR_FAIL" <%="MOTOR_FAIL".equals(s.getCurrentLabel()) ? "selected" : ""%>>MOTOR_FAIL (Motor Axis Failure)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="reason">Correction Reason (* min 5 characters)</label>
                            <textarea id="reason" name="reason" rows="3" placeholder="Enter correction reason (e.g., Video confirmed double drop)..." required minlength="5"></textarea>
                        </div>

                        <button type="submit" class="btn btn-warning" style="width:100%;">
                             Confirm Label Correction (Save to Audit Trail)
                        </button>
                    </form>
                <% } else { %>
                    <div class="alert alert-warning">
                        <span>Only users with <strong>REVIEWER</strong> or <strong>ADMIN</strong> role are authorized to correct labels for this session.</span>
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
                { pt: p2, label: 'Before: ' + wBefore.toFixed(1) + 'g', color: '#94a3b8' },
                { pt: p3, label: 'Peak: ' + wPeak.toFixed(1) + 'g', color: '#f59e0b' },
                { pt: p6, label: 'After: ' + wAfter.toFixed(1) + 'g', color: '#10b981' }
            ];

            points.forEach(item => {
                ctx.beginPath();
                ctx.arc(item.pt.x, item.pt.y, 5, 0, 2 * Math.PI);
                ctx.fillStyle = item.color;
                ctx.fill();
                ctx.strokeStyle = '#0f172a';
                ctx.lineWidth = 2;
                ctx.stroke();

                ctx.fillStyle = '#1e293b';
                ctx.font = 'bold 11px Segoe UI';
                ctx.fillText(item.label, item.pt.x - 20, item.pt.y - 12);
            });
        })();
    </script>
</body>
</html>
