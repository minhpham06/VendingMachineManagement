<%@page import="model.VendProduct"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    VendProduct product = (VendProduct) request.getAttribute("product");
    boolean isEdit = (product != null);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title><%=(isEdit ? "Sửa mặt hàng" : "Thêm mặt hàng mới")%> - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container" style="max-width: 600px;">
        <div class="card">
            <div class="card-header">
                <h2 class="card-title"><%=(isEdit ? " Cập nhật mặt hàng" : " Thêm mặt hàng mới")%></h2>
                <a href="<%=request.getContextPath()%>/master/products" class="btn btn-outline btn-sm">⬅ Quay lại</a>
            </div>

            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger"><span> <%=request.getAttribute("errorMessage")%></span></div>
            <% } %>

            <form action="<%=request.getContextPath()%><%=isEdit ? "/master/product/edit?id=" + product.getProductId() : "/master/product/create"%>" method="POST">
                <div class="form-group">
                    <label for="code">Mã mặt hàng (*)</label>
                    <input type="text" id="code" name="code" value="<%=isEdit ? WebUtil.esc(product.getCode()) : ""%>" placeholder="vd: PRD-POCKY-01" required>
                </div>

                <div class="form-group">
                    <label for="name">Tên mặt hàng (*)</label>
                    <input type="text" id="name" name="name" value="<%=isEdit ? WebUtil.esc(product.getName()) : ""%>" placeholder="vd: Bánh que Pocky Socola" required>
                </div>

                <div class="form-group">
                    <label for="nominalWeight">Khối lượng danh định (g) (*)</label>
                    <input type="number" step="0.1" id="nominalWeight" name="nominalWeight" value="<%=isEdit ? product.getNominalWeight() : "25.0"%>" required>
                    <small style="color:var(--text-muted);">Khối lượng một món hàng để đối chiếu cảm biến cân.</small>
                </div>

                <div class="form-group">
                    <label for="tolerance">Dung sai cho phép (± g) (*)</label>
                    <input type="number" step="0.1" id="tolerance" name="tolerance" value="<%=isEdit ? product.getTolerance() : "3.0"%>" required>
                    <small style="color:var(--text-muted);">Độ lệch cân nặng tối đa mà hệ thống vẫn ghi nhận là SUCCESS.</small>
                </div>

                <div class="form-group">
                    <label for="price">Đơn giá bán (VNĐ)</label>
                    <input type="number" step="1000" id="price" name="price" value="<%=isEdit ? (int)product.getPrice() : "10000"%>">
                </div>

                <div class="form-group">
                    <label for="note">Ghi chú</label>
                    <textarea id="note" name="note" rows="2" placeholder="Ghi chú mặt hàng..."><%=isEdit && product.getNote() != null ? WebUtil.esc(product.getNote()) : ""%></textarea>
                </div>

                <div class="form-group">
                    <label>Trạng thái</label>
                    <select name="isActive">
                        <option value="1" <%=!isEdit || product.isActive() ? "selected" : ""%>>Đang kinh doanh (Active)</option>
                        <option value="0" <%=isEdit && !product.isActive() ? "selected" : ""%>>Tạm ngừng kinh doanh</option>
                    </select>
                </div>

                <div style="display:flex; justify-content:flex-end; gap:0.75rem; margin-top:1.5rem;">
                    <a href="<%=request.getContextPath()%>/master/products" class="btn btn-outline">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary"><%=(isEdit ? " Lưu thay đổi" : " Thêm mặt hàng")%></button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
