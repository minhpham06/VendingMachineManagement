<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Tu dong chuyen huong vao dashboard neu da dang nhap, hoac vao trang login
    response.sendRedirect(request.getContextPath() + "/dashboard");
%>
