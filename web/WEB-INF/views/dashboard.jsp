<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.AppUser" %>
<%@ page import="util.WebUtil" %>
<%
    AppUser user = (AppUser) request.getAttribute("currentUser");
    int totalSessions = (Integer) request.getAttribute("totalSessions");
    int totalUsers = (Integer) request.getAttribute("totalUsers");
    int totalAlerts = (Integer) request.getAttribute("totalAlerts");
    String successRate = (String) request.getAttribute("successRate");
    Map<String, Integer> labelCounts = (Map<String, Integer>) request.getAttribute("labelCounts");

    int successCount = labelCounts != null && labelCounts.get("SUCCESS") != null ? labelCounts.get("SUCCESS") : 0;
    int jamCount = labelCounts != null && labelCounts.get("JAM") != null ? labelCounts.get("JAM") : 0;
    int wrongCount = labelCounts != null && labelCounts.get("WRONG_ITEM") != null ? labelCounts.get("WRONG_ITEM") : 0;
    int motorFailCount = labelCounts != null && labelCounts.get("MOTOR_FAIL") != null ? labelCounts.get("MOTOR_FAIL") : 0;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng điều khiển | VendGuard PRJ301</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/nav.jsp"/>

    <main class="main-wrapper">
        <div class="page-header">
            <div>
                <h1 class="page-title">📊 Bảng điều khiển tổng quan</h1>
                <p class="page-subtitle">Hệ thống giám sát máy bán hàng tự phát hiện kẹt hàng qua vòng xoay lò xo và khối lượng khay</p>
            </div>
            <div>
                <span class="badge <%= user.isAdmin() ? "badge-admin" : "badge-viewer" %>" style="font-size: 13px; padding: 6px 14px;">
                    Vai trò hiện tại: <%= user.getRoleCode() %>
                </span>
            </div>
        </div>

        <!-- KPI Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div>
                    <div class="stat-label">Tổng lượt nhả hàng</div>
                    <div class="stat-value"><%= totalSessions %></div>
                    <div class="stat-sub">Dữ liệu mẫu ban đầu: 240 phiên</div>
                </div>
                <div class="stat-icon blue">📦</div>
            </div>

            <div class="stat-card">
                <div>
                    <div class="stat-label">Tỷ lệ thành công</div>
                    <div class="stat-value" style="color: #10b981;"><%= successRate %>%</div>
                    <div class="stat-sub"><%= successCount %> phiên SUCCESS</div>
                </div>
                <div class="stat-icon green">✅</div>
            </div>

            <div class="stat-card">
                <div>
                    <div class="stat-label">Cảnh báo kẹt / lỗi</div>
                    <div class="stat-value" style="color: #ef4444;"><%= totalAlerts %></div>
                    <div class="stat-sub">Sự cố cần can thiệp</div>
                </div>
                <div class="stat-icon red">⚠️</div>
            </div>

            <div class="stat-card">
                <div>
                    <div class="stat-label">Tài khoản nhân sự</div>
                    <div class="stat-value"><%= totalUsers %></div>
                    <div class="stat-sub">5 vai trò hệ thống</div>
                </div>
                <div class="stat-icon purple">👥</div>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px;">
            <!-- Phan bo nhan phien -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">📈 Phân bố nhãn kết quả phân loại</h2>
                    <span style="font-size: 12px; color: var(--text-muted);">Quy tắc tự động & Duyệt nhãn</span>
                </div>

                <div style="display: flex; flex-direction: column; gap: 16px; margin-top: 10px;">
                    <div>
                        <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px;">
                            <span class="badge badge-success">SUCCESS - Thành công</span>
                            <b><%= successCount %> phiên (<%= totalSessions > 0 ? (successCount * 100 / totalSessions) : 0 %>%)</b>
                        </div>
                        <div style="height: 10px; background: #e2e8f0; border-radius: 5px; overflow: hidden;">
                            <div style="height: 100%; background: #10b981; width: <%= totalSessions > 0 ? (successCount * 100 / totalSessions) : 0 %>%;"></div>
                        </div>
                    </div>

                    <div>
                        <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px;">
                            <span class="badge badge-jam">JAM - Kẹt hàng trong rãnh</span>
                            <b><%= jamCount %> phiên (<%= totalSessions > 0 ? (jamCount * 100 / totalSessions) : 0 %>%)</b>
                        </div>
                        <div style="height: 10px; background: #e2e8f0; border-radius: 5px; overflow: hidden;">
                            <div style="height: 100%; background: #ef4444; width: <%= totalSessions > 0 ? (jamCount * 100 / totalSessions) : 0 %>%;"></div>
                        </div>
                    </div>

                    <div>
                        <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px;">
                            <span class="badge badge-wrong">WRONG_ITEM - Sai / Rơi đôi</span>
                            <b><%= wrongCount %> phiên (<%= totalSessions > 0 ? (wrongCount * 100 / totalSessions) : 0 %>%)</b>
                        </div>
                        <div style="height: 10px; background: #e2e8f0; border-radius: 5px; overflow: hidden;">
                            <div style="height: 100%; background: #f59e0b; width: <%= totalSessions > 0 ? (wrongCount * 100 / totalSessions) : 0 %>%;"></div>
                        </div>
                    </div>

                    <div>
                        <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px;">
                            <span class="badge badge-motor">MOTOR_FAIL - Lỗi động cơ</span>
                            <b><%= motorFailCount %> phiên (<%= totalSessions > 0 ? (motorFailCount * 100 / totalSessions) : 0 %>%)</b>
                        </div>
                        <div style="height: 10px; background: #e2e8f0; border-radius: 5px; overflow: hidden;">
                            <div style="height: 100%; background: #8b5cf6; width: <%= totalSessions > 0 ? (motorFailCount * 100 / totalSessions) : 0 %>%;"></div>
                        </div>
                    </div>
                </div>

                <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border); display: flex; justify-content: flex-end;">
                    <a href="<%= request.getContextPath() %>/sessions" class="btn btn-secondary btn-sm">
                        Xem chi tiết danh sách phiên ➔
                    </a>
                </div>
            </div>

            <!-- Thong tin vai tro & Phim tat -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">🛡️ Quyền hạn của bạn</h2>
                </div>

                <div style="margin-bottom: 16px;">
                    <p style="font-size: 13px; color: var(--text-muted);">Bạn đang đăng nhập với vai trò:</p>
                    <div style="font-size: 16px; font-weight: 700; color: var(--primary-dark); margin: 4px 0 10px;">
                        <%= user.getRoleName() != null ? user.getRoleName() : user.getRoleCode() %>
                    </div>
                </div>

                <div style="display: flex; flex-direction: column; gap: 10px;">
                    <% if (user.isAdmin()) { %>
                        <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-primary" style="justify-content: flex-start;">
                            👥 Quản lý người dùng
                        </a>
                        <a href="<%= request.getContextPath() %>/admin/roles" class="btn btn-secondary" style="justify-content: flex-start;">
                            🛡️ Xem ma trận phân quyền
                        </a>
                    <% } %>

                    <a href="<%= request.getContextPath() %>/sessions" class="btn btn-secondary" style="justify-content: flex-start;">
                        📦 Xem danh sách phiên đo
                    </a>

                    <a href="<%= request.getContextPath() %>/profile" class="btn btn-secondary" style="justify-content: flex-start;">
                        🔑 Đổi mật khẩu cá nhân
                    </a>
                </div>

                <div style="margin-top: 20px; padding: 12px; background: #f8fafc; border-radius: var(--radius-sm); border: 1px solid var(--border); font-size: 12px; color: var(--text-muted);">
                    💡 <b>Quy định bảo mật:</b> Hệ thống kiểm soát quyền từ phía Server qua bộ lọc <code>AuthFilter</code>. Mọi hành vi truy cập trái phép bằng cách dán URL sẽ bị chặn với mã <b>HTTP 403 Forbidden</b>.
                </div>
            </div>
        </div>
    </main>

    <footer class="footer">
        Đồ án PRJ301 - Đề số 01: Máy bán hàng thu nhỏ tự phát hiện kẹt hàng &copy; Fall 2026. Trường Đại học FPT.
    </footer>
</body>
</html>
