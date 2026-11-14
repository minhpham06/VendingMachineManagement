<%@page import="java.util.List"%>
<%@page import="model.VendSession"%>
<%@page import="model.VendSlot"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Vend Sessions - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title"> Vend Sessions List</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Total: <strong><%=request.getAttribute("totalSessions")%></strong> test runs
                    </p>
                </div>
                <a href="<%=request.getContextPath()%>/export" class="btn btn-outline">
                     Export CSV
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
                    <option value="">-- All Classifications --</option>
                    <option value="SUCCESS" <%="SUCCESS".equals(currentLabel) ? "selected" : ""%>>SUCCESS (Success)</option>
                    <option value="JAM" <%="JAM".equals(currentLabel) ? "selected" : ""%>>JAM (Item Jam)</option>
                    <option value="WRONG_ITEM" <%="WRONG_ITEM".equals(currentLabel) ? "selected" : ""%>>WRONG_ITEM (Double/Wrong Item)</option>
                    <option value="MOTOR_FAIL" <%="MOTOR_FAIL".equals(currentLabel) ? "selected" : ""%>>MOTOR_FAIL (Motor Failure)</option>
                </select>

                <select name="slotId" style="min-width:180px; flex:1;">
                    <option value="">-- All Slots --</option>
                    <% if (slots != null) {
                        for (VendSlot s : slots) {
                    %>
                        <option value="<%=s.getSlotId()%>" <%=(currentSlotId != null && currentSlotId == s.getSlotId()) ? "selected" : ""%>><%=s.getCode()%> (<%=s.getProductName() != null ? s.getProductName() : "Empty"%>)</option>
                    <% } } %>
                </select>

                <div style="display:flex; gap:0.5rem;">
                    <button type="submit" class="btn btn-primary"> Filter</button>
                    <a href="<%=request.getContextPath()%>/sessions" class="btn btn-outline">Clear</a>
                </div>
            </form>

            <!-- SESSION TABLE -->
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Seq #</th>
                            <th>Slot / Product</th>
                            <th>Motor Status</th>
                            <th>Motor Duration</th>
                            <th>Weight </th>
                            <th>Delta Weight </th>
                            <th>Classification Label</th>
                            <th>Label Source</th>
                            <th style="text-align:center;">Action</th>
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
                                    <span class="badge badge-success">1 Turn</span>
                                <% } else { %>
                                    <span class="badge badge-danger">Incomplete</span>
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
                                     View & Edit
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="9" style="text-align:center; color:var(--text-muted);">No sessions found.</td>
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
                    Viewing page <strong><%=currentPage%></strong> of <strong><%=totalPages%></strong>
                </div>

                <div class="pagination">
                    <% if (currentPage > 1) { %>
                        <a href="<%=request.getContextPath()%>/sessions?page=<%=currentPage - 1%><%=filterQuery%>" class="page-btn" title="Previous page">&laquo;</a>
                    <% } else { %>
                        <span class="page-btn disabled" title="First page">&laquo;</span>
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
                        <a href="<%=request.getContextPath()%>/sessions?page=<%=currentPage + 1%><%=filterQuery%>" class="page-btn" title="Next page">&raquo;</a>
                    <% } else { %>
                        <span class="page-btn disabled" title="Last page">&raquo;</span>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</body>
</html>
