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
import util.PasswordUtil;
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

        String q = req.getParameter("q");
        Integer roleId = null;
        String roleStr = req.getParameter("roleId");
        if (roleStr != null && !roleStr.isEmpty()) {
            roleId = WebUtil.parseInt(roleStr, 0);
            if (roleId == 0) roleId = null;
        }

        Boolean locked = null;
        String lockStr = req.getParameter("locked");
        if ("1".equals(lockStr)) locked = true;
        else if ("0".equals(lockStr)) locked = false;

        int page = WebUtil.parseInt(req.getParameter("page"), 1);
        if (page < 1) page = 1;

        int totalUsers = userDAO.count(q, roleId, locked);
        int totalPages = (int) Math.ceil((double) totalUsers / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * PAGE_SIZE;
        List<AppUser> users = userDAO.search(q, roleId, locked, offset, PAGE_SIZE);
        List<AppRole> roles = roleDAO.getAllRoles();

        req.setAttribute("users", users);
        req.setAttribute("roles", roles);
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("q", q);
        req.setAttribute("roleId", roleId);
        req.setAttribute("locked", lockStr);

        req.getRequestDispatcher("/WEB-INF/views/users.jsp").forward(req, resp);
    }

    private void showCreateForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("roles", roleDAO.getAllRoles());
        req.getRequestDispatcher("/WEB-INF/views/user_form.jsp").forward(req, resp);
    }

    private void doCreate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        int roleId = WebUtil.parseInt(req.getParameter("roleId"), 0);

        if (username == null || username.trim().isEmpty()
            || password == null || password.isEmpty()
            || fullName == null || fullName.trim().isEmpty()
            || roleId <= 0) {
            req.setAttribute("errorMessage", "Vui lòng nhập đầy đủ các trường bắt buộc.");
            req.setAttribute("roles", roleDAO.getAllRoles());
            req.getRequestDispatcher("/WEB-INF/views/user_form.jsp").forward(req, resp);
            return;
        }

        username = username.trim().toLowerCase();
        if (userDAO.findByUsername(username) != null) {
            req.setAttribute("errorMessage", "Tên đăng nhập '" + username + "' đã tồn tại trong hệ thống.");
            req.setAttribute("roles", roleDAO.getAllRoles());
            req.getRequestDispatcher("/WEB-INF/views/user_form.jsp").forward(req, resp);
            return;
        }

        AppUser u = new AppUser();
        u.setUsername(username);
        u.setPassHash(PasswordUtil.hash(password));
        u.setFullName(fullName.trim());
        u.setEmail(email != null ? email.trim() : null);
        u.setPhone(phone != null ? phone.trim() : null);
        u.setRoleId(roleId);
        u.setLocked(false);

        int newId = userDAO.insert(u);
        if (newId > 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?success=created");
        } else {
            req.setAttribute("errorMessage", "Không thể tạo tài khoản do lỗi cơ sở dữ liệu.");
            req.setAttribute("roles", roleDAO.getAllRoles());
            req.getRequestDispatcher("/WEB-INF/views/user_form.jsp").forward(req, resp);
        }
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int userId = WebUtil.parseInt(req.getParameter("id"), 0);
        AppUser u = userDAO.findById(userId);
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=notfound");
            return;
        }
        req.setAttribute("editUser", u);
        req.setAttribute("roles", roleDAO.getAllRoles());
        req.getRequestDispatcher("/WEB-INF/views/user_form.jsp").forward(req, resp);
    }

    private void doEdit(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int userId = WebUtil.parseInt(req.getParameter("id"), 0);
        AppUser u = userDAO.findById(userId);
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=notfound");
            return;
        }

        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        int roleId = WebUtil.parseInt(req.getParameter("roleId"), 0);
        boolean locked = "1".equals(req.getParameter("isLocked"));

        if (fullName == null || fullName.trim().isEmpty() || roleId <= 0) {
            req.setAttribute("errorMessage", "Họ tên và Vai trò không được để trống.");
            req.setAttribute("editUser", u);
            req.setAttribute("roles", roleDAO.getAllRoles());
            req.getRequestDispatcher("/WEB-INF/views/user_form.jsp").forward(req, resp);
            return;
        }

        u.setFullName(fullName.trim());
        u.setEmail(email != null ? email.trim() : null);
        u.setPhone(phone != null ? phone.trim() : null);
        u.setRoleId(roleId);
        u.setLocked(locked);

        if (userDAO.update(u)) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?success=updated");
        } else {
            req.setAttribute("errorMessage", "Lỗi cập nhật người dùng.");
            req.setAttribute("editUser", u);
            req.setAttribute("roles", roleDAO.getAllRoles());
            req.getRequestDispatcher("/WEB-INF/views/user_form.jsp").forward(req, resp);
        }
    }

    private void handleAction(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String act = req.getParameter("act");
        int userId = WebUtil.parseInt(req.getParameter("id"), 0);

        HttpSession session = req.getSession();
        AppUser me = (AppUser) session.getAttribute("user");

        if (me != null && me.getUserId() == userId && ("lock".equals(act) || "delete".equals(act))) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=self_action");
            return;
        }

        if ("lock".equals(act)) {
            userDAO.setLock(userId, true);
        } else if ("unlock".equals(act)) {
            userDAO.setLock(userId, false);
        } else if ("reset".equals(act)) {
            userDAO.updatePassword(userId, PasswordUtil.hash("123456"));
        } else if ("delete".equals(act)) {
            userDAO.delete(userId);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users?success=" + act);
    }
}
