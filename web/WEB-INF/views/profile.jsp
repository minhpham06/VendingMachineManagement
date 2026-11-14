<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser user = (AppUser) request.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>User Profile - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container" style="max-width: 750px;">
        <!-- THONG TIN CA NHAN -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title"> Personal Information</h2>
                <span class="user-badge"><%=user.getRoleCode()%></span>
            </div>

            <% if (request.getAttribute("infoSuccess") != null) { %>
                <div class="alert alert-success"><span> <%=request.getAttribute("infoSuccess")%></span></div>
            <% } %>
            <% if (request.getAttribute("infoError") != null) { %>
                <div class="alert alert-danger"><span> <%=request.getAttribute("infoError")%></span></div>
            <% } %>

            <form action="<%=request.getContextPath()%>/profile" method="POST">
                <input type="hidden" name="action" value="update_info">

                <div class="form-group">
                    <label>Username</label>
                    <input type="text" value="<%=WebUtil.esc(user.getUsername())%>" disabled style="opacity:0.7; cursor:not-allowed;">
                </div>

                <div class="form-group">
                    <label for="fullName">Full Name (*)</label>
                    <input type="text" id="fullName" name="fullName" value="<%=WebUtil.esc(user.getFullName())%>" required>
                </div>

                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" value="<%=user.getEmail() != null ? WebUtil.esc(user.getEmail()) : ""%>">
                </div>

                <div class="form-group">
                    <label for="phone">Phone</label>
                    <input type="text" id="phone" name="phone" value="<%=user.getPhone() != null ? WebUtil.esc(user.getPhone()) : ""%>">
                </div>

                <div style="text-align:right;">
                    <button type="submit" class="btn btn-primary"> Update Profile</button>
                </div>
            </form>
        </div>

        <!-- DOI MAT KHAU -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title"> Change Password</h2>
            </div>

            <% if (request.getAttribute("passSuccess") != null) { %>
                <div class="alert alert-success"><span> <%=request.getAttribute("passSuccess")%></span></div>
            <% } %>
            <% if (request.getAttribute("passError") != null) { %>
                <div class="alert alert-danger"><span> <%=request.getAttribute("passError")%></span></div>
            <% } %>

            <form action="<%=request.getContextPath()%>/profile" method="POST">
                <input type="hidden" name="action" value="change_password">

                <div class="form-group">
                    <label for="oldPassword">Current Password (*)</label>
                    <input type="password" id="oldPassword" name="oldPassword" placeholder="Enter current password..." required>
                </div>

                <div class="form-group">
                    <label for="newPassword">New Password (*)</label>
                    <input type="password" id="newPassword" name="newPassword" placeholder="Min 6 characters..." required>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm New Password (*)</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-enter new password..." required>
                </div>

                <div style="text-align:right;">
                    <button type="submit" class="btn btn-warning"> Update Password</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
