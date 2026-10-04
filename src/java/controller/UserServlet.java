package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.AppRoleDAO;
import dao.AppUserDAO;
import model.AppRole;
import model.AppUser;
import util.WebUtil;

@WebServlet(urlPatterns = {
    "/admin/users",
    "/admin/user/create",
    "/admin/user/edit",
    "/admin/user/action"
})
public class UserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final int PAGE_SIZE = 10;
    private final AppUserDAO userDAO = new AppUserDAO();
    private final AppRoleDAO roleDAO = new AppRoleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        if ("/admin/user/create".equals(path)) {
            showCreateForm(req, resp);
        } else if ("/admin/user/edit".equals(path)) {
            showEditForm(req, resp);
        } else if ("/admin/user/action".equals(path)) {
            handleAction(req, resp);
        } else {
            showList(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        if ("/admin/user/create".equals(path)) {
            doCreate(req, resp);
        } else if ("/admin/user/edit".equals(path)) {
            doEdit(req, resp);
        } else if ("/admin/user/action".equals(path)) {
            handleAction(req, resp);
        } else {
            showList(req, resp);
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String query = req.getParameter("q");
        String roleStr = req.getParameter("roleId");
        String lockedStr = req.getParameter("locked");
        int page = WebUtil.parseInt(req.getParameter("page"), 1);
        if (page < 1) page = 1;

        Integer roleId = (roleStr != null && !roleStr.trim().isEmpty()) ? WebUtil.parseInt(roleStr, 0) : null;
        if (roleId != null && roleId <= 0) roleId = null;

        Boolean isLocked = null;
        if ("1".equals(lockedStr)) isLocked = Boolean.TRUE;
        else if ("0".equals(lockedStr)) isLocked = Boolean.FALSE;

        List<AppUser> users = userDAO.searchUsers(query, roleId, isLocked, page, PAGE_SIZE);
        int total = userDAO.countUsers(query, roleId, isLocked);
        int totalPages = (total + PAGE_SIZE - 1) / PAGE_SIZE;
        if (totalPages < 1) totalPages = 1;

        List<AppRole> roles = roleDAO.getAllRoles();

        req.setAttribute("users", users);
        req.setAttribute("roles", roles);
        req.setAttribute("page", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("total", total);
        req.setAttribute("query", query);
        req.setAttribute("selectedRoleId", roleId);
        req.setAttribute("selectedLocked", lockedStr);

        req.getRequestDispatcher("/WEB-INF/views/users.jsp").forward(req, resp);
    }

    private void showCreateForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("roles", roleDAO.getAllRoles());
        req.setAttribute("isEdit", false);
        req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = WebUtil.parseInt(req.getParameter("id"), 0);
        AppUser u = userDAO.findById(id);
        if (u == null) {
            req.getSession().setAttribute("flashError", "Không tìm thấy người dùng có ID: " + id);
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        req.setAttribute("userItem", u);
        req.setAttribute("roles", roleDAO.getAllRoles());
        req.setAttribute("isEdit", true);
        req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
    }

    private void doCreate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String password = req.getParameter("password");
        int roleId = WebUtil.parseInt(req.getParameter("roleId"), 0);

        if (username == null || username.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty() ||
            password == null || password.isEmpty() || roleId <= 0) {
            req.setAttribute("errorMessage", "Vui lòng nhập đầy đủ các trường bắt buộc (Username, Mật khẩu, Họ tên, Vai trò).");
            req.setAttribute("roles", roleDAO.getAllRoles());
            req.setAttribute("isEdit", false);
            req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
            return;
        }

        username = username.trim().toLowerCase();
        if (userDAO.isUsernameExists(username, null)) {
            req.setAttribute("errorMessage", "Tên đăng nhập '" + username + "' đã tồn tại trên hệ thống.");
            req.setAttribute("roles", roleDAO.getAllRoles());
            req.setAttribute("isEdit", false);
            req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
            return;
        }

        AppUser u = new AppUser();
        u.setUsername(username);
        u.setFullName(fullName.trim());
        u.setEmail(email != null ? email.trim() : null);
        u.setPhone(phone != null ? phone.trim() : null);
        u.setRoleId(roleId);
        u.setLocked(false);

        int newId = userDAO.insert(u, password);
        if (newId > 0) {
            req.getSession().setAttribute("flashSuccess", "Thêm người dùng '" + username + "' thành công!");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
        } else {
            req.setAttribute("errorMessage", "Có lỗi xảy ra trong quá trình lưu dữ liệu.");
            req.setAttribute("roles", roleDAO.getAllRoles());
            req.setAttribute("isEdit", false);
            req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
        }
    }

    private void doEdit(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = WebUtil.parseInt(req.getParameter("id"), 0);
        AppUser existing = userDAO.findById(id);
        if (existing == null) {
            req.getSession().setAttribute("flashError", "Người dùng không tồn tại.");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        int roleId = WebUtil.parseInt(req.getParameter("roleId"), 0);

        if (fullName == null || fullName.trim().isEmpty() || roleId <= 0) {
            req.setAttribute("errorMessage", "Họ tên và vai trò không được để trống.");
            req.setAttribute("userItem", existing);
            req.setAttribute("roles", roleDAO.getAllRoles());
            req.setAttribute("isEdit", true);
            req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
            return;
        }

        existing.setFullName(fullName.trim());
        existing.setEmail(email != null ? email.trim() : null);
        existing.setPhone(phone != null ? phone.trim() : null);
        existing.setRoleId(roleId);

        boolean ok = userDAO.update(existing);
        if (ok) {
            req.getSession().setAttribute("flashSuccess", "Cập nhật tài khoản '" + existing.getUsername() + "' thành công!");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
        } else {
            req.setAttribute("errorMessage", "Không thể cập nhật thông tin người dùng.");
            req.setAttribute("userItem", existing);
            req.setAttribute("roles", roleDAO.getAllRoles());
            req.setAttribute("isEdit", true);
            req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
        }
    }

    private void handleAction(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        AppUser me = (AppUser) session.getAttribute("user");

        String action = req.getParameter("act");
        int targetId = WebUtil.parseInt(req.getParameter("id"), 0);

        if (targetId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        AppUser target = userDAO.findById(targetId);
        if (target == null) {
            session.setAttribute("flashError", "Người dùng không tồn tại.");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        if ("lock".equals(action)) {
            if (target.getUserId() == me.getUserId()) {
                session.setAttribute("flashError", "Bạn không thể tự khóa chính tài khoản của mình!");
            } else {
                userDAO.toggleLock(targetId, true);
                session.setAttribute("flashSuccess", "Đã khóa tài khoản '" + target.getUsername() + "'.");
            }
        } else if ("unlock".equals(action)) {
            userDAO.toggleLock(targetId, false);
            session.setAttribute("flashSuccess", "Đã mở khóa tài khoản '" + target.getUsername() + "'.");
        } else if ("reset".equals(action)) {
            userDAO.resetPassword(targetId, "123456");
            session.setAttribute("flashSuccess", "Đã đặt lại mật khẩu cho tài khoản '" + target.getUsername() + "' về mặc định: 123456");
        } else if ("delete".equals(action)) {
            if (target.getUserId() == me.getUserId()) {
                session.setAttribute("flashError", "Bạn không thể tự xóa chính tài khoản của mình!");
            } else {
                boolean del = userDAO.delete(targetId);
                if (del) {
                    session.setAttribute("flashSuccess", "Đã xóa tài khoản '" + target.getUsername() + "'.");
                } else {
                    session.setAttribute("flashError", "Không thể xóa người dùng vì tài khoản này đã có dữ liệu tham chiếu (phiên/nhãn/cảnh báo). Khuyến nghị dùng tính năng 'Khóa tài khoản' thay thế.");
                }
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
