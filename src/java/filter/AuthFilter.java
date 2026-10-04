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
 * Bo loc xac thuc va phan quyen 5 vai tro cua he thong.
 * Chan tat ca request tai server truoc khi vao Controller.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final Map<String, Set<String>> ALLOWED = new LinkedHashMap<String, Set<String>>();

    static {
        // 1. Phan he quan tri nguoi dung & thiet bi: Chi ADMIN
        ALLOWED.put("/admin", roles("ADMIN"));

        // 2. Phan he quan ly danh muc mat hang, ranh hang, phieu nap: ADMIN, CATALOG_MANAGER, OPERATOR
        ALLOWED.put("/master", roles("ADMIN", "CATALOG_MANAGER", "OPERATOR"));

        // 3. Chuc nang sua nhan: ADMIN, REVIEWER
        ALLOWED.put("/label", roles("ADMIN", "REVIEWER"));

        // 4. Xem danh sach phien, chi tiet phien, xuat CSV, dashboard, profile: Tat ca 5 vai tro
        ALLOWED.put("/sessions", roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
        ALLOWED.put("/session",  roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
        ALLOWED.put("/dashboard", roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
        ALLOWED.put("/profile",   roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
        ALLOWED.put("/export",    roles("ADMIN", "CATALOG_MANAGER", "OPERATOR", "REVIEWER", "VIEWER"));
    }

    private static Set<String> roles(String... names) {
        return new HashSet<String>(Arrays.asList(names));
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // Dong bo UTF-8 cho toan bo request/response
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        // Bo qua cac duong dan cong khai: dang nhap, tai nguyen tinh, endpoint nhan du lieu tu ESP32
        if (path.equals("/") || path.equals("/index.jsp")
                || path.startsWith("/login")
                || path.startsWith("/logout")
                || path.startsWith("/api/")
                || path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/images/")
                || path.startsWith("/assets/")) {
            chain.doFilter(request, response);
            return;
        }

        // Kiem tra phien dang nhap
        HttpSession session = req.getSession(false);
        AppUser user = (session != null) ? (AppUser) session.getAttribute("user") : null;

        if (user == null) {
            // Luu lai URL can vao de sau khi login thanh cong thi redirect toi
            session = req.getSession(true);
            session.setAttribute("redirectAfterLogin", path);
            resp.sendRedirect(contextPath + "/login");
            return;
        }

        // Kiem tra tai khoan co bi khoa dot xuat khong
        if (user.isLocked()) {
            session.invalidate();
            req.setAttribute("errorMessage", "Tài khoản của bạn đã bị khóa bởi Quản trị viên.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // Kiem tra ma tran quyen theo tien to duong dan (path prefix)
        for (Map.Entry<String, Set<String>> entry : ALLOWED.entrySet()) {
            String prefix = entry.getKey();
            if (path.startsWith(prefix)) {
                Set<String> allowedRoles = entry.getValue();
                if (!allowedRoles.contains(user.getRoleCode())) {
                    req.setAttribute("forbiddenPath", path);
                    req.setAttribute("currentRole", user.getRoleCode());
                    req.setAttribute("allowedRoles", allowedRoles);
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    req.getRequestDispatcher("/WEB-INF/views/403.jsp").forward(req, resp);
                    return;
                }
                break;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
