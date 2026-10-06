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
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Lập phiếu nạp hàng - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container" style="max-width: 600px;">
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">📥 Lập Phiếu Nạp Bổ Sung Hàng</h2>
                <a href="<%=request.getContextPath()%>/master/restocks" class="btn btn-outline btn-sm">⬅️ Quay lại</a>
            </div>

            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger" style="margin-bottom: 1.25rem;">
                    <span>⚠️ <%=request.getAttribute("errorMessage")%></span>
                </div>
            <% } %>

            <form action="<%=request.getContextPath()%>/master/restock/create" method="POST">
                <div class="form-group">
                    <label for="slotId">Chọn Rãnh nạp hàng (*)</label>
                    <select id="slotId" name="slotId" required>
                        <option value="">-- Chọn rãnh nhận hàng --</option>
                        <% if (slots != null) {
                            for (VendSlot s : slots) {
                                boolean isSel = (selectedSlotId != null && selectedSlotId.intValue() == s.getSlotId());
                        %>
                            <option value="<%=s.getSlotId()%>" <%=isSel ? "selected" : ""%>>
                                <%=s.getCode()%> - <%=s.getProductName() != null ? s.getProductName() : "(Trống)"%> 
                                (Hiện có: <%=s.getCurrentStock()%>/<%=s.getCapacity()%>)
                            </option>
                        <% } } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="quantity">Số lượng nạp thêm (gói) (*)</label>
                    <input type="number" id="quantity" name="quantity" value="<%=currentQty%>" required>
                </div>

                <div class="form-group">
                    <label for="note">Ghi chú phiếu nạp</label>
                    <textarea id="note" name="note" rows="3" placeholder="vd: Bổ sung hàng đầu ca trực..."><%=WebUtil.esc(currentNote)%></textarea>
                </div>

                <div style="display:flex; justify-content:flex-end; gap:0.75rem; margin-top:1.5rem;">
                    <a href="<%=request.getContextPath()%>/master/restocks" class="btn btn-outline">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary">📥 Xác nhận nạp hàng</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
