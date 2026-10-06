package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.AppUserDAO;
import model.AppUser;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AppUserDAO userDAO = new AppUserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        if (req.getParameter("logout") != null) {
            req.setAttribute("successMessage", "Bạn đã đăng xuất thành công khỏi hệ thống.");
        }
        if (req.getParameter("locked") != null) {
            req.setAttribute("errorMessage", "Tài khoản của bạn hiện đang bị khóa. Vui lòng liên hệ Quản trị viên.");
        }

        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        username = username.trim();
        AppUser user = userDAO.authenticate(username, password);

        if (user == null) {
            AppUser existing = userDAO.findByUsername(username);
            if (existing != null && existing.isLocked()) {
                req.setAttribute("errorMessage", "Tài khoản đang bị khóa.");
            } else {
                req.setAttribute("errorMessage", "Sai tên đăng nhập hoặc mật khẩu.");
            }
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        if (user.isLocked()) {
            req.setAttribute("errorMessage", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Quản trị viên.");
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // Đăng nhập thành công -> Lưu session
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);

        String target = (String) session.getAttribute("targetUrl");
        if (target != null && !target.isEmpty()) {
            session.removeAttribute("targetUrl");
            resp.sendRedirect(target);
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }
}
