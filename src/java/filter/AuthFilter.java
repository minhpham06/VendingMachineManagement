package filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.AppUser;

/**
 * Bộ lọc xác thực và phân quyền 5 vai trò phía server.
 * Chặn bypass URL và cấu hình UTF-8 toàn hệ thống.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final Map<String, Set<String>> ALLOWED = new LinkedHashMap<String, Set<String>>();

    static {
        // 1. Quản trị hệ thống (Người dùng & Thiết bị): Chỉ ADMIN
        ALLOWED.put("/admin", roles("ADMIN"));

        // 2. Quản lý Mặt hàng: ADMIN, CATALOG_MANAGER
        ALLOWED.put("/master/product", roles("ADMIN", "CATALOG_MANAGER"));

        // 3. Quản lý Rãnh lò xo: ADMIN, CATALOG_MANAGER, OPERATOR
        ALLOWED.put("/master/slot", roles("ADMIN", "CATALOG_MANAGER", "OPERATOR"));

        // 4. Phiếu nạp hàng: ADMIN, OPERATOR
        ALLOWED.put("/master/restock", roles("ADMIN", "OPERATOR"));

        // 5. Kiểm duyệt & Sửa nhãn: ADMIN, REVIEWER
        ALLOWED.put("/label", roles("ADMIN", "REVIEWER"));

        // 6. Xử lý cảnh báo: ADMIN, OPERATOR
        ALLOWED.put("/alert/resolve", roles("ADMIN", "OPERATOR"));

        // 7. Xem danh sách phiên, chi tiết phiên, dashboard, alerts, profile, export CSV: Cả 5 vai trò
        ALLOWED.put("/alerts",    roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
        ALLOWED.put("/sessions",  roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
        ALLOWED.put("/session",   roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
        ALLOWED.put("/dashboard", roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
        ALLOWED.put("/profile",   roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
        ALLOWED.put("/export",    roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
    }

    private static Set<String> roles(String... r) {
        return new HashSet<String>(Arrays.asList(r));
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // Thiết lập bảng mã UTF-8 cho cả request và response
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String path = req.getServletPath();
        if (path == null || path.isEmpty()) {
            path = "/";
        }

        // 1. Cho phép tài nguyên tĩnh và API không cần session Web
        if (path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/")
            || path.endsWith(".css") || path.endsWith(".js") || path.endsWith(".png") || path.endsWith(".jpg")
            || path.endsWith(".ico") || "/api/ingest".equals(path)) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Cho phép trang Login / Logout và trang chủ
        if ("/login".equals(path) || "/logout".equals(path) || "/".equals(path) || "/index.jsp".equals(path)) {
            chain.doFilter(request, response);
            return;
        }

        // 3. Kiểm tra Session đăng nhập
        HttpSession session = req.getSession(false);
        AppUser user = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (user == null) {
            // Chưa đăng nhập -> Lưu URL muốn vào và chuyển sang login
            String target = req.getRequestURI();
            String query = req.getQueryString();
            if (query != null) {
                target += "?" + query;
            }
            if (session == null) {
                session = req.getSession(true);
            }
            session.setAttribute("targetUrl", target);
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // 4. Kiểm tra tài khoản bị khóa
        if (user.isLocked()) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login?locked=1");
            return;
        }

        // 5. Kiểm tra phân quyền truy cập theo role_code
        String userRole = user.getRoleCode();
        boolean pathProtected = false;
        boolean permitted = false;

        for (Map.Entry<String, Set<String>> entry : ALLOWED.entrySet()) {
            if (path.startsWith(entry.getKey())) {
                pathProtected = true;
                if (entry.getValue().contains(userRole)) {
                    permitted = true;
                    break;
                }
            }
        }

        if (pathProtected && !permitted) {
            req.setAttribute("userRole", userRole);
            req.setAttribute("requestedPath", path);
            req.getRequestDispatcher("/WEB-INF/views/403.jsp").forward(req, resp);
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
