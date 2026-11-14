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
import util.PasswordUtil;

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

            if (oldPass == null || newPass == null || confirmPass == null
                || oldPass.isEmpty() || newPass.isEmpty() || confirmPass.isEmpty()) {
                req.setAttribute("passError", "Please fill in all password fields.");
                req.setAttribute("user", me);
                req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
                return;
            }

            if (!newPass.equals(confirmPass)) {
                req.setAttribute("passError", "New password and confirm password do not match.");
                req.setAttribute("user", me);
                req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
                return;
            }

            if (newPass.length() < 6) {
                req.setAttribute("passError", "New password must be at least 6 characters long.");
                req.setAttribute("user", me);
                req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
                return;
            }

            // Kiểm tra mật khẩu cũ
            AppUser dbUser = userDAO.findById(me.getUserId());
            if (dbUser == null || !PasswordUtil.verify(oldPass, dbUser.getPassHash())) {
                req.setAttribute("passError", "Incorrect current password.");
                req.setAttribute("user", me);
                req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
                return;
            }

            // Cập nhật mật khẩu mới
            String newHash = PasswordUtil.hash(newPass);
            if (userDAO.updatePassword(me.getUserId(), newHash)) {
                req.setAttribute("passSuccess", "Password updated successfully!");
            } else {
                req.setAttribute("passError", "Could not update password.");
            }

        } else if ("update_info".equals(action)) {
            String fullName = req.getParameter("fullName");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");

            if (fullName == null || fullName.trim().isEmpty()) {
                req.setAttribute("infoError", "Full name cannot be blank.");
                req.setAttribute("user", me);
                req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
                return;
            }

            me.setFullName(fullName.trim());
            me.setEmail(email != null ? email.trim() : null);
            me.setPhone(phone != null ? phone.trim() : null);

            if (userDAO.update(me)) {
                session.setAttribute("user", me);
                req.setAttribute("infoSuccess", "Profile updated successfully!");
            } else {
                req.setAttribute("infoError", "Error updating profile.");
            }
        }

        req.setAttribute("user", me);
        req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
    }
}
