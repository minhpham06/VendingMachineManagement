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

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AppUserDAO userDAO = new AppUserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        AppUser me = (AppUser) session.getAttribute("user");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Load lai du lieu moi nhat tu DB
        AppUser fresh = userDAO.findById(me.getUserId());
        if (fresh != null) {
            session.setAttribute("user", fresh);
            req.setAttribute("user", fresh);
        } else {
            req.setAttribute("user", me);
        }

        req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        AppUser me = (AppUser) session.getAttribute("user");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        if ("change_password".equals(action)) {
            String oldPass = req.getParameter("oldPassword");
            String newPass = req.getParameter("newPassword");
            String confirmPass = req.getParameter("confirmPassword");

            if (oldPass == null || oldPass.isEmpty() || newPass == null || newPass.isEmpty()) {
                req.setAttribute("passError", "Vui lòng nhập đầy đủ mật khẩu cũ và mới.");
            } else if (newPass.length() < 6) {
                req.setAttribute("passError", "Mật khẩu mới phải có tối thiểu 6 ký tự.");
            } else if (!newPass.equals(confirmPass)) {
                req.setAttribute("passError", "Mật khẩu xác nhận không trùng khớp.");
            } else {
                boolean ok = userDAO.changePassword(me.getUserId(), oldPass, newPass);
                if (ok) {
                    req.setAttribute("passSuccess", "Đổi mật khẩu thành công!");
                } else {
                    req.setAttribute("passError", "Mật khẩu hiện tại không đúng.");
                }
            }
        } else if ("update_info".equals(action)) {
            String fullName = req.getParameter("fullName");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");

            if (fullName == null || fullName.trim().isEmpty()) {
                req.setAttribute("infoError", "Họ và tên không được để trống.");
            } else {
                AppUser u = userDAO.findById(me.getUserId());
                if (u != null) {
                    u.setFullName(fullName.trim());
                    u.setEmail(email != null ? email.trim() : null);
                    u.setPhone(phone != null ? phone.trim() : null);
                    boolean ok = userDAO.update(u);
                    if (ok) {
                        session.setAttribute("user", u);
                        req.setAttribute("infoSuccess", "Cập nhật thông tin cá nhân thành công!");
                    } else {
                        req.setAttribute("infoError", "Không thể cập nhật thông tin.");
                    }
                }
            }
        }

        doGet(req, resp);
    }
}
