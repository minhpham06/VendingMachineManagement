<%@page import="model.VendProduct"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    VendProduct product = (VendProduct) request.getAttribute("product");
    boolean isEdit = (product != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title><%=(isEdit ? "Edit Product" : "Add New Product")%> - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container" style="max-width: 600px;">
        <div class="card">
            <div class="card-header">
                <h2 class="card-title"><%=(isEdit ? " Update Product" : " Add New Product")%></h2>
                <a href="<%=request.getContextPath()%>/master/products" class="btn btn-outline btn-sm">Back</a>
            </div>

            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger"><span> <%=request.getAttribute("errorMessage")%></span></div>
            <% } %>

            <form action="<%=request.getContextPath()%><%=isEdit ? "/master/product/edit?id=" + product.getProductId() : "/master/product/create"%>" method="POST">
                <div class="form-group">
                    <label for="code">Product Code (*)</label>
                    <input type="text" id="code" name="code" value="<%=isEdit ? WebUtil.esc(product.getCode()) : ""%>" placeholder="e.g. PRD-POCKY-01" required>
                </div>

                <div class="form-group">
                    <label for="name">Product Name (*)</label>
                    <input type="text" id="name" name="name" value="<%=isEdit ? WebUtil.esc(product.getName()) : ""%>" placeholder="e.g. Chocolate Pocky" required>
                </div>

                <div class="form-group">
                    <label for="nominalWeight">Nominal Weight (g) (*)</label>
                    <input type="number" step="0.1" id="nominalWeight" name="nominalWeight" value="<%=isEdit ? product.getNominalWeight() : "25.0"%>" required>
                    <small style="color:var(--text-muted);">Weight of a single unit for scale sensor verification.</small>
                </div>

                <div class="form-group">
                    <label for="tolerance">Tolerance (&plusmn; g) (*)</label>
                    <input type="number" step="0.1" id="tolerance" name="tolerance" value="<%=isEdit ? product.getTolerance() : "3.0"%>" required>
                    <small style="color:var(--text-muted);">Maximum allowable weight deviation still marked as SUCCESS.</small>
                </div>

                <div class="form-group">
                    <label for="price">Price (VND)</label>
                    <input type="number" step="1000" id="price" name="price" value="<%=isEdit ? (int)product.getPrice() : "10000"%>">
                </div>

                <div class="form-group">
                    <label for="note">Notes</label>
                    <textarea id="note" name="note" rows="2" placeholder="Product notes..."><%=isEdit && product.getNote() != null ? WebUtil.esc(product.getNote()) : ""%></textarea>
                </div>

                <div class="form-group">
                    <label>Status</label>
                    <select name="isActive">
                        <option value="1" <%=!isEdit || product.isActive() ? "selected" : ""%>>Active</option>
                        <option value="0" <%=isEdit && !product.isActive() ? "selected" : ""%>>Inactive</option>
                    </select>
                </div>

                <div style="display:flex; justify-content:flex-end; gap:0.75rem; margin-top:1.5rem;">
                    <a href="<%=request.getContextPath()%>/master/products" class="btn btn-outline">Cancel</a>
                    <button type="submit" class="btn btn-primary"><%=(isEdit ? " Save Changes" : " Add Product")%></button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
