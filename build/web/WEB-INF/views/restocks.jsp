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
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Restock History - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title"> Restock History & Logs</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Log of vending inventory restocks performed by machine operators
                    </p>
                </div>
                <% if (canRestock) { %>
                    <a href="<%=request.getContextPath()%>/master/restock/create" class="btn btn-primary">
                         Create Restock Entry
                    </a>
                <% } %>
            </div>

            <% if ("created".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span> Restock entry created and inventory updated successfully!</span></div>
            <% } %>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Restock ID</th>
                            <th>Slot</th>
                            <th>Product</th>
                            <th>Quantity</th>
                            <th>Operator</th>
                            <th>Operator Notes</th>
                            <th>Restocked At</th>
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
                            <td><span class="badge badge-success">+<%=r.getQuantity()%> pcs</span></td>
                            <td><%=WebUtil.esc(r.getRestockedByName())%></td>
                            <td style="color:var(--text-secondary);"><%=r.getNote() != null ? WebUtil.esc(r.getNote()) : "-"%></td>
                            <td><%=WebUtil.formatDateTime(r.getCreatedAt())%></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="7" style="text-align:center; color:var(--text-muted);">No restock records found.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
