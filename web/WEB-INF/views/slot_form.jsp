<%@page import="java.util.List"%>
<%@page import="model.VendSlot"%>
<%@page import="model.VendProduct"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    VendSlot slot = (VendSlot) request.getAttribute("slot");
    List<VendProduct> products = (List<VendProduct>) request.getAttribute("products");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Configure Slot - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container" style="max-width: 600px;">
        <div class="card">
            <div class="card-header">
                <h2 class="card-title"> Configure Slot: <%=slot.getCode()%></h2>
                <a href="<%=request.getContextPath()%>/master/slots" class="btn btn-outline btn-sm">Back</a>
            </div>

            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger"><span> <%=request.getAttribute("errorMessage")%></span></div>
            <% } %>

            <form action="<%=request.getContextPath()%>/master/slot/edit?id=<%=slot.getSlotId()%>" method="POST">
                <div class="form-group">
                    <label>Slot Code</label>
                    <input type="text" value="<%=slot.getCode()%> - <%=WebUtil.esc(slot.getName())%>" disabled style="opacity:0.7; cursor:not-allowed;">
                </div>

                <div class="form-group">
                    <label for="productId">Assigned Product (*)</label>
                    <select id="productId" name="productId">
                        <option value="">-- Unassigned --</option>
                        <% if (products != null) {
                            for (VendProduct p : products) {
                        %>
                            <option value="<%=p.getProductId()%>" <%=(slot.getProductId() != null && slot.getProductId() == p.getProductId()) ? "selected" : ""%>>
                                <%=p.getName()%> (<%=WebUtil.formatWeight(p.getNominalWeight())%>)
                            </option>
                        <% } } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="capacity">Maximum Capacity (pcs) (*)</label>
                    <input type="number" id="capacity" name="capacity" value="<%=slot.getCapacity()%>" required min="1" max="50">
                </div>

                <div class="form-group">
                    <label for="currentStock">Current Stock (*)</label>
                    <input type="number" id="currentStock" name="currentStock" value="<%=slot.getCurrentStock()%>" required min="0" max="50">
                </div>

                <div class="form-group">
                    <label for="isSuspended">Slot Status</label>
                    <select id="isSuspended" name="isSuspended">
                        <option value="0" <%=!slot.isSuspended() ? "selected" : ""%>>Normal Operation (ACTIVE)</option>
                        <option value="1" <%=slot.isSuspended() ? "selected" : ""%>>Suspended (SUSPENDED)</option>
                    </select>
                </div>

                <div style="display:flex; justify-content:flex-end; gap:0.75rem; margin-top:1.5rem;">
                    <a href="<%=request.getContextPath()%>/master/slots" class="btn btn-outline">Cancel</a>
                    <button type="submit" class="btn btn-primary"> Save Configuration</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
