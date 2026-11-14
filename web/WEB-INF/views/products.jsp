<%@page import="java.util.List"%>
<%@page import="model.VendProduct"%>
<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser me = (AppUser) session.getAttribute("user");
    boolean canEdit = (me != null && ("ADMIN".equals(me.getRoleCode()) || "CATALOG_MANAGER".equals(me.getRoleCode())));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Product Catalog - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title"> Product Catalog Management</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Configure Nominal Weight ($W_{nominal}$) and Tolerance ($\pm\Delta$) as standard verification baselines
                    </p>
                </div>
                <% if (canEdit) { %>
                    <a href="<%=request.getContextPath()%>/master/product/create" class="btn btn-primary">
                         Add New Product
                    </a>
                <% } %>
            </div>

            <% if ("created".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span> Product created successfully!</span></div>
            <% } else if ("updated".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span> Product updated successfully!</span></div>
            <% } else if ("deleted".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success"><span> Product deleted successfully!</span></div>
            <% } else if ("fk_constraint".equals(request.getParameter("error"))) { %>
                <div class="alert alert-danger"><span> Cannot delete product because it is currently assigned to a slot.</span></div>
            <% } %>

            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Code</th>
                            <th>Product Name</th>
                            <th>Nominal Weight ($W_{nominal}$)</th>
                            <th>Tolerance ($\pm\Delta$)</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Created At</th>
                            <% if (canEdit) { %><th style="text-align:center;">Action</th><% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<VendProduct> products = (List<VendProduct>) request.getAttribute("products");
                            if (products != null && !products.isEmpty()) {
                                for (VendProduct p : products) {
                        %>
                        <tr>
                            <td><span class="user-badge"><%=WebUtil.esc(p.getCode())%></span></td>
                            <td><strong><%=WebUtil.esc(p.getName())%></strong></td>
                            <td><span class="badge badge-info"><%=WebUtil.formatWeight(p.getNominalWeight())%></span></td>
                            <td>&plusmn; <%=WebUtil.formatWeight(p.getTolerance())%></td>
                            <td><%=WebUtil.formatCurrency(p.getPrice())%></td>
                            <td>
                                <% if (p.isActive()) { %>
                                    <span class="badge badge-success">Active</span>
                                <% } else { %>
                                    <span class="badge badge-danger">Inactive</span>
                                <% } %>
                            </td>
                            <td><%=WebUtil.formatDateTime(p.getCreatedAt())%></td>
                            <% if (canEdit) { %>
                            <td style="text-align:center;">
                                <div style="display:inline-flex; gap:0.4rem;">
                                    <a href="<%=request.getContextPath()%>/master/product/edit?id=<%=p.getProductId()%>" class="btn btn-outline btn-sm">Edit</a>
                                    <a href="<%=request.getContextPath()%>/master/product/delete?id=<%=p.getProductId()%>" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this product?');">Delete</a>
                                </div>
                            </td>
                            <% } %>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" style="text-align:center; color:var(--text-muted);">No products found in the catalog.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
