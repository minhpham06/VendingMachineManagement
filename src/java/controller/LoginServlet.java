package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.AppUserDAO;
import dao.DeviceDAO;
import model.AppUser;
import model.Device;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AppUserDAO userDAO = new AppUserDAO();
    private final DeviceDAO deviceDAO = new DeviceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        if (req.getParameter("logout") != null) {
            req.setAttribute("successMessage", "You have logged out successfully.");
        }
        if (req.getParameter("locked") != null) {
            req.setAttribute("errorMessage", "Your account is currently locked. Please contact the Administrator.");
        }

        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("errorMessage", "Please enter both username and password.");
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        username = username.trim();
        AppUser user = userDAO.authenticate(username, password);

        if (user == null) {
            AppUser existing = userDAO.findByUsername(username);
            if (existing != null && existing.isLocked()) {
                req.setAttribute("errorMessage", "Account is currently locked.");
            } else {
                req.setAttribute("errorMessage", "Invalid username or password.");
            }
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        if (user.isLocked()) {
            req.setAttribute("errorMessage", "Your account has been locked. Please contact the Administrator.");
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // Đăng nhập thành công -> Lưu session
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);

        // Nạp danh sách máy được phân công
        List<Device> assignedDevices;
        if ("ADMIN".equals(user.getRoleCode())) {
            assignedDevices = deviceDAO.getAllDevices();
        } else {
            assignedDevices = deviceDAO.getDevicesByUserId(user.getUserId());
        }
        session.setAttribute("assignedDevices", assignedDevices);
        if (assignedDevices != null && !assignedDevices.isEmpty()) {
            Device current = assignedDevices.get(0);
            session.setAttribute("currentDeviceId", current.getDeviceId());
            session.setAttribute("currentDevice", current);
        } else {
            session.removeAttribute("currentDeviceId");
            session.removeAttribute("currentDevice");
        }

        String target = (String) session.getAttribute("targetUrl");
        if (target != null && !target.isEmpty()) {
            session.removeAttribute("targetUrl");
            resp.sendRedirect(target);
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }
}
