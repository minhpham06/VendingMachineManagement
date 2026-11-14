<%@page import="java.util.List"%>
<%@page import="model.VendSlot"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    List<VendSlot> slots = (List<VendSlot>) request.getAttribute("slots");
    Integer selectedSlotId = (Integer) request.getAttribute("selectedSlotId");
    Integer selectedQuantity = (Integer) request.getAttribute("selectedQuantity");
    String selectedNote = (String) request.getAttribute("selectedNote");
    
    int currentQty = (selectedQuantity != null && selectedQuantity > 0) ? selectedQuantity : 1;
    String currentNote = selectedNote != null ? selectedNote : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>New Restock Entry - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container" style="max-width: 600px;">
        <div class="card">
            <div class="card-header">
                <h2 class="card-title"> Create Restock Entry</h2>
                <a href="<%=request.getContextPath()%>/master/restocks" class="btn btn-outline btn-sm">Back</a>
            </div>

            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger" style="margin-bottom: 1.25rem;">
                    <span> <%=request.getAttribute("errorMessage")%></span>
                </div>
            <% } %>

            <form action="<%=request.getContextPath()%>/master/restock/create" method="POST">
                <div class="form-group">
                    <label for="slotId">Select Restock Slot (*)</label>
                    <select id="slotId" name="slotId" required>
                        <option value="">-- Select Slot --</option>
                        <% if (slots != null) {
                            for (VendSlot s : slots) {
                                boolean isSel = (selectedSlotId != null && selectedSlotId.intValue() == s.getSlotId());
                                boolean isLocked = s.isSuspended() || !s.isActive();
                        %>
                            <option value="<%=s.getSlotId()%>" <%=isSel ? "selected" : ""%> <%=isLocked ? "style='color:#dc2626;'" : ""%>>
                                <%=s.getCode()%> - <%=s.getProductName() != null ? s.getProductName() : "(Empty)"%> 
                                (Current: <%=s.getCurrentStock()%>/<%=s.getCapacity()%>)
                                <%=isLocked ? "  [LOCKED]" : ""%>
                            </option>
                        <% } } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="quantity">Quantity to Restock (pcs) (*)</label>
                    <input type="number" id="quantity" name="quantity" value="<%=currentQty%>" required>
                </div>

                <div class="form-group">
                    <label for="note">Restock Notes</label>
                    <textarea id="note" name="note" rows="3" placeholder="e.g. Shift restock..."><%=WebUtil.esc(currentNote)%></textarea>
                </div>

                <div style="display:flex; justify-content:flex-end; gap:0.75rem; margin-top:1.5rem;">
                    <a href="<%=request.getContextPath()%>/master/restocks" class="btn btn-outline">Cancel</a>
                    <button type="submit" class="btn btn-primary"> Confirm Restock</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
