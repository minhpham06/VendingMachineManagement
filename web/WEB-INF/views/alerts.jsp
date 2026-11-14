<%@page import="java.util.List"%>
<%@page import="model.VendAlert"%>
<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser me = (AppUser) session.getAttribute("user");
    boolean canResolve = (me != null && ("ADMIN".equals(me.getRoleCode()) || "OPERATOR".equals(me.getRoleCode())));
    String filter = (String) request.getAttribute("filter");
    if (filter == null || filter.trim().isEmpty()) {
        filter = "all";
    }

    int totalCount = (Integer) request.getAttribute("totalCount");
    int unresolvedCount = (Integer) request.getAttribute("unresolvedCount");
    int resolvedCount = (Integer) request.getAttribute("resolvedCount");

    String resolvedIdParam = (String) request.getAttribute("resolvedId");
    int justResolvedId = WebUtil.parseInt(resolvedIdParam, 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Smart Alerts - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .filter-tabs {
            display: flex;
            gap: 0.5rem;
            border-bottom: 2px solid #e2e8f0;
            margin-bottom: 1.25rem;
            padding-bottom: 0.25rem;
        }
        .filter-tab {
            padding: 8px 16px;
            text-decoration: none;
            font-size: 0.88rem;
            font-weight: 600;
            color: #64748b;
            border-radius: 6px;
            transition: all 0.15s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .filter-tab:hover {
            color: #1d4ed8;
            background: #f1f5f9;
        }
        .filter-tab.active {
            color: #2563eb;
            background: #eff6ff;
            border-bottom: 2px solid #2563eb;
            border-radius: 6px 6px 0 0;
            margin-bottom: -6px;
        }
        .tab-badge {
            font-size: 0.75rem;
            padding: 2px 7px;
            border-radius: 9999px;
            background: #e2e8f0;
            color: #334155;
            font-weight: 700;
        }
        .filter-tab.active .tab-badge {
            background: #2563eb;
            color: #ffffff;
        }
        .row-just-resolved {
            background-color: #f0fdf4 !important;
            border-left: 4px solid #16a34a !important;
            transition: background 0.3s ease;
        }
        /* Modal Styles */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.6);
            z-index: 2000;
            justify-content: center;
            align-items: center;
            padding: 1rem;
        }
        .modal-box {
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 12px;
            max-width: 520px;
            width: 100%;
            padding: 1.75rem;
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.15);
            text-align: left;
            animation: modalFadeIn 0.2s ease-out;
        }
        @keyframes modalFadeIn {
            from { opacity: 0; transform: scale(0.96); }
            to { opacity: 1; transform: scale(1); }
        }
    </style>
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header" style="flex-wrap: wrap; gap: 1rem; justify-content: space-between; align-items: center;">
                <div>
                    <h2 class="card-title">Operational Alert & Incident Engine</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Real-time automated incident detection: Jam Streaks, Low Stock, Motor Failures and Weight Anomalies
                    </p>
                </div>
                <div style="display:flex; gap:0.5rem; align-items:center;">
                    <a href="<%=request.getContextPath()%>/alert/test-email" class="btn btn-outline btn-sm" title="Dispatch a test alert email to <%=util.EmailService.DEFAULT_OPERATOR_EMAIL%>">
                        Send Test Alert Email
                    </a>
                </div>
            </div>

            <!-- TABS -->
            <div class="filter-tabs">
                <a href="<%=request.getContextPath()%>/alerts?filter=all" 
                   class="filter-tab <%="all".equals(filter) ? "active" : ""%>">
                    All Alerts
                    <span class="tab-badge"><%=totalCount%></span>
                </a>
                <a href="<%=request.getContextPath()%>/alerts?filter=open" 
                   class="filter-tab <%="open".equals(filter) ? "active" : ""%>">
                    Open Issues
                    <span class="tab-badge" style="<%=(unresolvedCount > 0 ? "background:#fee2e2; color:#b91c1c;" : "")%>"><%=unresolvedCount%></span>
                </a>
                <a href="<%=request.getContextPath()%>/alerts?filter=resolved" 
                   class="filter-tab <%="resolved".equals(filter) ? "active" : ""%>">
                    Resolved History
                    <span class="tab-badge"><%=resolvedCount%></span>
                </a>
            </div>

            <% if ("test_sent".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success" style="margin-bottom: 1.25rem;">
                    <span>Live test alert email dispatched to <strong><%=util.EmailService.DEFAULT_OPERATOR_EMAIL%></strong> (Operator: <strong><%=util.EmailService.DEFAULT_OPERATOR_NAME%></strong>). Please check your inbox!</span>
                </div>
            <% } else if ("resolved".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success" style="margin-bottom: 1.25rem; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.5rem;">
                    <span>Incident <strong>#<%=justResolvedId > 0 ? justResolvedId : ""%></strong> successfully resolved and recorded in history! Confirmation audit email has been sent to <strong><%=util.EmailService.DEFAULT_OPERATOR_EMAIL%></strong>.</span>
                    <a href="<%=request.getContextPath()%>/alerts?filter=resolved" class="btn btn-outline btn-sm" style="background:#ffffff; color:#16a34a; border-color:#86efac; font-weight:700;">View in Resolved History</a>
                </div>
            <% } %>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Alert ID</th>
                            <th>Machine</th>
                            <th>Severity</th>
                            <th>Rule Code</th>
                            <th>Slot</th>
                            <th>Alert Message</th>
                            <th>Status & Resolution Audit</th>
                            <th>Timestamp</th>
                            <% if (canResolve) { %><th style="text-align:center;">Action</th><% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<VendAlert> alerts = (List<VendAlert>) request.getAttribute("alerts");
                            if (alerts != null && !alerts.isEmpty()) {
                                for (VendAlert a : alerts) {
                                    boolean isCurrentJustResolved = (justResolvedId > 0 && a.getAlertId() == justResolvedId);
                        %>
                        <tr class="<%=isCurrentJustResolved ? "row-just-resolved" : ""%>">
                            <td>
                                <strong>#<%=a.getAlertId()%></strong>
                                <% if (isCurrentJustResolved) { %>
                                    <div style="font-size:0.7rem; font-weight:700; color:#16a34a; text-transform:uppercase;">Just Resolved</div>
                                <% } %>
                            </td>
                            <td>
                                <div style="font-weight:600; color:#0f172a;"><%=a.getDeviceCode() != null ? a.getDeviceCode() : "Vend-01"%></div>
                                <small style="color:var(--text-muted);"><%=a.getMachineName() != null ? WebUtil.esc(a.getMachineName()) : ""%></small>
                            </td>
                            <td>
                                <% if ("CRITICAL".equalsIgnoreCase(a.getSeverity())) { %>
                                    <span class="badge badge-danger">CRITICAL</span>
                                <% } else if ("WARNING".equalsIgnoreCase(a.getSeverity())) { %>
                                    <span class="badge badge-warning">WARNING</span>
                                <% } else { %>
                                    <span class="badge badge-info">INFO</span>
                                <% } %>
                            </td>
                            <td><span style="font-weight:700; color:#334155;"><%=a.getRuleCode()%></span></td>
                            <td>
                                <% if (a.getSlotCode() != null) { %>
                                    <span class="user-badge"><%=a.getSlotCode()%></span>
                                    <% if (a.isSlotSuspended()) { %>
                                        <span class="badge badge-danger" style="margin-top:3px; display:inline-block; font-size:0.7rem;">Locked</span>
                                    <% } %>
                                <% } else { %>
                                    <span style="color:var(--text-muted);">-</span>
                                <% } %>
                            </td>
                            <td style="max-width:300px; color:#1e293b;"><%=WebUtil.esc(a.getMessage())%></td>
                            <td>
                                <% if (a.isResolved()) { %>
                                    <span class="badge badge-success">RESOLVED</span>
                                    <div style="font-size:0.8rem; color:#475569; margin-top:4px;">
                                        By: <strong><%=a.getHandlerName() != null && !a.getHandlerName().trim().isEmpty() ? WebUtil.esc(a.getHandlerName()) : "Operator / Staff"%></strong>
                                    </div>
                                    <% if (a.getHandledNote() != null && !a.getHandledNote().trim().isEmpty()) { %>
                                        <div style="font-size:0.78rem; color:#64748b; margin-top:2px; font-style:italic; line-height:1.3;">
                                            "<%=WebUtil.esc(a.getHandledNote())%>"
                                        </div>
                                    <% } %>
                                <% } else { %>
                                    <span class="badge badge-danger">OPEN (Action Required)</span>
                                <% } %>
                            </td>
                            <td style="font-size:0.85rem; color:#64748b;"><%=WebUtil.formatDateTime(a.getCreatedAt())%></td>
                            <% if (canResolve) { %>
                            <td style="text-align:center;">
                                <% if (!a.isResolved()) { %>
                                    <button type="button" class="btn btn-primary btn-sm btn-resolve"
                                            data-id="<%=a.getAlertId()%>"
                                            data-dev="<%=a.getDeviceCode() != null ? WebUtil.esc(a.getDeviceCode()) : "Vend-01"%>"
                                            data-slot="<%=a.getSlotCode() != null ? WebUtil.esc(a.getSlotCode()) : "None"%>"
                                            data-rule="<%=WebUtil.esc(a.getRuleCode())%>"
                                            data-msg="<%=WebUtil.esc(a.getMessage())%>"
                                            data-suspended="<%=a.isSlotSuspended()%>"
                                            onclick="openResolveModalFromBtn(this)">
                                        Resolve Incident
                                    </button>
                                <% } else { %>
                                    <span style="color:var(--text-muted); font-size:0.82rem; font-weight:600;">Closed</span>
                                <% } %>
                            </td>
                            <% } %>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="9" style="text-align:center; padding:2.5rem; color:var(--text-muted);">
                                No alerts matching current filter (<%=filter%>).
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- RESOLUTION MODAL -->
    <div id="resolveModal" class="modal-overlay" onclick="closeResolveModal(event)">
        <div class="modal-box" onclick="event.stopPropagation()">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem; border-bottom:1px solid #e2e8f0; padding-bottom:0.75rem;">
                <h3 style="margin:0; font-size:1.25rem; color:#0f172a;">
                    Resolve Incident <span id="modalAlertTitle" style="color:#2563eb;"></span>
                </h3>
                <button type="button" onclick="closeResolveModal()" style="background:none; border:none; font-size:0.88rem; font-weight:600; color:#64748b; cursor:pointer;">
                    Close
                </button>
            </div>

            <!-- INCIDENT SUMMARY BOX -->
            <div style="background:#f8fafc; border:1px solid #cbd5e1; border-radius:8px; padding:0.85rem 1rem; margin-bottom:1.25rem; font-size:0.88rem;">
                <div style="display:flex; justify-content:space-between; margin-bottom:0.35rem;">
                    <span style="color:#64748b;">Machine:</span>
                    <strong id="modalDevName" style="color:#0f172a;">-</strong>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:0.35rem;">
                    <span style="color:#64748b;">Target Slot:</span>
                    <strong id="modalSlotCode" style="color:#0f172a;">-</strong>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:0.35rem;">
                    <span style="color:#64748b;">Rule Code:</span>
                    <strong id="modalRuleCode" style="color:#2563eb;">-</strong>
                </div>
                <div style="border-top:1px dashed #cbd5e1; padding-top:0.4rem; margin-top:0.4rem;">
                    <span style="color:#64748b;">Issue:</span>
                    <div id="modalAlertMsg" style="color:#334155; margin-top:2px; font-weight:500;">-</div>
                </div>
            </div>

            <form action="<%=request.getContextPath()%>/alert/resolve" method="POST">
                <input type="hidden" name="id" id="modalAlertId" value="0">
                <input type="hidden" name="filter" value="<%=filter%>">

                <!-- PRESET SUGGESTIONS -->
                <div class="form-group" style="margin-bottom:0.75rem;">
                    <label for="presetNote" style="font-size:0.85rem; font-weight:600; color:#334155;">Standard Action Taken (Presets)</label>
                    <select id="presetNote" onchange="applyPresetNote(this.value)">
                        <option value="">-- Select standard action taken (or write below) --</option>
                        <option value="Cleared jammed product from coil and verified drop mechanism">Cleared jammed product from coil and verified drop mechanism</option>
                        <option value="Restocked product inventory to capacity and inspected slot">Restocked product inventory to capacity and inspected slot</option>
                        <option value="Inspected motor wiring and reset spring rotation alignment">Inspected motor wiring and reset spring rotation alignment</option>
                        <option value="Tared loadcell sensor and verified weight baseline stability">Tared loadcell sensor and verified weight baseline stability</option>
                        <option value="Routine inspection completed - mechanism operating normally">Routine inspection completed - mechanism operating normally</option>
                        <option value="False alarm - slot mechanism tested and passed">False alarm - slot mechanism tested and passed</option>
                    </select>
                </div>

                <!-- RESOLUTION NOTE -->
                <div class="form-group" style="margin-bottom:1rem;">
                    <label for="handledNote" style="font-size:0.85rem; font-weight:600; color:#334155;">Resolution Note (*)</label>
                    <textarea id="handledNote" name="note" rows="3" required placeholder="Describe action taken to fix this issue (e.g. Unjammed coil, replaced product)..."></textarea>
                </div>

                <!-- UNSUSPEND SLOT CHECKBOX -->
                <div id="unsuspendBox" style="background:#eff6ff; border:1px solid #bfdbfe; border-radius:8px; padding:0.75rem 1rem; margin-bottom:1.25rem; display:none;">
                    <label style="display:flex; align-items:center; gap:8px; margin:0; cursor:pointer; font-size:0.88rem; color:#1e40af; font-weight:600;">
                        <input type="checkbox" name="unsuspendSlot" value="1" id="unsuspendSlotCheck" style="width:16px; height:16px; cursor:pointer;">
                        Unsuspend Slot (Unlock coil to resume vending immediately)
                    </label>
                </div>

                <div style="display:flex; justify-content:flex-end; gap:0.75rem;">
                    <button type="button" class="btn btn-outline" onclick="closeResolveModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary" style="font-weight:700;">Confirm Resolution</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openResolveModalFromBtn(btn) {
            if (!btn) return;
            const alertId = parseInt(btn.getAttribute('data-id') || '0', 10);
            const devCode = btn.getAttribute('data-dev') || 'Vend-01';
            const slotCode = btn.getAttribute('data-slot') || 'None';
            const ruleCode = btn.getAttribute('data-rule') || 'INCIDENT';
            const msg = btn.getAttribute('data-msg') || '';
            const isSuspended = (btn.getAttribute('data-suspended') === 'true');

            openResolveModal(alertId, devCode, slotCode, ruleCode, msg, isSuspended);
        }

        function openResolveModal(alertId, devCode, slotCode, ruleCode, msg, isSuspended) {
            document.getElementById('modalAlertId').value = alertId;
            document.getElementById('modalAlertTitle').innerText = '#' + alertId;
            document.getElementById('modalDevName').innerText = devCode;
            document.getElementById('modalSlotCode').innerText = slotCode;
            document.getElementById('modalRuleCode').innerText = ruleCode;
            document.getElementById('modalAlertMsg').innerText = msg;

            document.getElementById('handledNote').value = '';
            document.getElementById('presetNote').value = '';

            const unsuspendBox = document.getElementById('unsuspendBox');
            const unsuspendCheck = document.getElementById('unsuspendSlotCheck');
            if (isSuspended && slotCode !== 'None' && slotCode !== '') {
                unsuspendBox.style.display = 'block';
                unsuspendCheck.checked = true;
            } else {
                unsuspendBox.style.display = 'none';
                unsuspendCheck.checked = false;
            }

            document.getElementById('resolveModal').style.display = 'flex';
        }

        function closeResolveModal(e) {
            document.getElementById('resolveModal').style.display = 'none';
        }

        function applyPresetNote(val) {
            if (val) {
                document.getElementById('handledNote').value = val;
            }
        }
    </script>
</body>
</html>
