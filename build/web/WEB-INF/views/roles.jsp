<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="model.AppRole"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Roles & Permissions - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title"> System Roles & Permission Matrix</h2>
                    <p style="font-size:0.85rem; color:var(--text-secondary); margin-top:0.25rem;">
                        5 standard system roles enforced strictly via <code>AuthFilter</code>
                    </p>
                </div>
            </div>

            <div class="table-responsive" style="margin-bottom:2rem;">
                <table>
                    <thead>
                        <tr>
                            <th>Role Code</th>
                            <th>Display Name</th>
                            <th>Responsibilities</th>
                            <th style="text-align:center;">User Count</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<AppRole> roles = (List<AppRole>) request.getAttribute("roles");
                            Map<Integer, Integer> userCounts = (Map<Integer, Integer>) request.getAttribute("userCounts");
                            if (roles != null) {
                                for (AppRole r : roles) {
                                    int count = userCounts != null && userCounts.containsKey(r.getRoleId()) ? userCounts.get(r.getRoleId()) : 0;
                        %>
                        <tr>
                            <td><span class="user-badge"><%=r.getRoleCode()%></span></td>
                            <td><strong><%=WebUtil.esc(r.getRoleName())%></strong></td>
                            <td style="color:var(--text-secondary);"><%=WebUtil.esc(r.getDescription())%></td>
                            <td style="text-align:center;"><span class="badge badge-info"><%=count%></span></td>
                        </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <!-- PERMISSION MATRIX -->
            <div class="card-header">
                <h3 class="card-title" style="font-size:1.1rem;"> Permission Matrix by Module</h3>
            </div>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>Functional Module</th>
                            <th style="text-align:center;">ADMIN</th>
                            <th style="text-align:center;">CATALOG_MGR</th>
                            <th style="text-align:center;">OPERATOR</th>
                            <th style="text-align:center;">REVIEWER</th>
                            <th style="text-align:center;">VIEWER</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>User & System Administration (/admin/*)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Full Access</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                        </tr>
                        <tr>
                            <td><strong>Product Catalog (/master/product*)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Full Access</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Full Access</span></td>
                            <td style="text-align:center;"><span class="badge badge-info">View</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                        </tr>
                        <tr>
                            <td><strong>Slot & Coil Management (/master/slot*)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Full Access</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Configure</span></td>
                            <td style="text-align:center;"><span class="badge badge-warning">Lock/Unlock</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                        </tr>
                        <tr>
                            <td><strong>Restock Inventory (/master/restock*)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Full Access</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Create</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                        </tr>
                        <tr>
                            <td><strong>Review & Correct Labels (/label/*)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Full Access</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Edit + Reason</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                        </tr>
                        <tr>
                            <td><strong>Alert Resolution (/alert/resolve)</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">Full Access</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">Resolve</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                            <td style="text-align:center;"><span class="badge badge-danger">None</span></td>
                        </tr>
                        <tr>
                            <td><strong>Dashboard, View Sessions & Export CSV</strong></td>
                            <td style="text-align:center;"><span class="badge badge-success">View + Export</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">View + Export</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">View + Export</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">View + Export</span></td>
                            <td style="text-align:center;"><span class="badge badge-success">View + Export</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
