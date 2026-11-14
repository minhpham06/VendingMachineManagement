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
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Vending Slots - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title"> Vending Slots & Coil Management</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Monitor inventory per slot, assigned product, and auto-suspension state when consecutive jams occur
                    </p>
                </div>
            </div>

            <% if ("updated".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span> Slot configuration updated successfully!</span></div>
            <% } else if ("toggled".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span> Slot status toggled successfully!</span></div>
            <% } %>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Slot Code</th>
                            <th>Slot Name</th>
                            <th>Assigned Product</th>
                            <th>Nominal Weight</th>
                            <th>Capacity</th>
                            <th>Stock</th>
                            <th>Status</th>
                            <th style="text-align:center;">Action</th>
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
                                    <span style="color:var(--text-muted);"><em>(Unassigned)</em></span>
                                <% } %>
                            </td>
                            <td>
                                <% if (s.getProductName() != null) { %>
                                    <%=WebUtil.formatWeight(s.getNominalWeight())%> (&plusmn;<%=WebUtil.formatWeight(s.getTolerance())%>)
                                <% } else { %>
                                    -
                                <% } %>
                            </td>
                            <td><%=s.getCapacity()%> pcs</td>
                            <td>
                                <strong><%=s.getCurrentStock()%></strong> / <%=s.getCapacity()%>
                                <% if (s.getCurrentStock() <= 2) { %>
                                    <span class="badge badge-warning" style="margin-left:0.4rem;">Low</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (!s.isSuspended()) { %>
                                    <span class="badge badge-success">Active</span>
                                <% } else { %>
                                    <span class="badge badge-danger">SUSPENDED</span>
                                <% } %>
                            </td>
                            <td style="text-align:center;">
                                <div style="display:inline-flex; gap:0.4rem;">
                                    <% if (canEdit) { %>
                                        <a href="<%=request.getContextPath()%>/master/slot/edit?id=<%=s.getSlotId()%>" class="btn btn-outline btn-sm">Configure</a>
                                    <% } %>
                                    <% if (canToggle) { %>
                                        <% if (!s.isSuspended()) { %>
                                            <a href="<%=request.getContextPath()%>/master/slot/toggle?id=<%=s.getSlotId()%>" class="btn btn-warning btn-sm" onclick="return confirm('Temporarily lock this slot?');">Lock Slot</a>
                                        <% } else { %>
                                            <a href="<%=request.getContextPath()%>/master/slot/toggle?id=<%=s.getSlotId()%>" class="btn btn-success btn-sm" onclick="return confirm('Unlock this slot to resume vending?');">Unlock</a>
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
                            <td colspan="8" style="text-align:center; color:var(--text-muted);">No slots configured.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
