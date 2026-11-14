package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.AppUserDAO;
import dao.DeviceAssignmentDAO;
import dao.DeviceDAO;
import model.AppUser;
import model.Device;
import util.WebUtil;

@WebServlet("/admin/assignments")
public class MachineAssignmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final AppUserDAO userDAO = new AppUserDAO();
    private final DeviceDAO deviceDAO = new DeviceDAO();
    private final DeviceAssignmentDAO assignmentDAO = new DeviceAssignmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy danh sách toàn bộ người dùng
        List<AppUser> allUsers = userDAO.getAllUsers();
        List<AppUser> targetUsers = new ArrayList<AppUser>();
        for (AppUser u : allUsers) {
            String role = u.getRoleCode();
            // Lọc ra Operator và Reviewer để phân quyền máy (hoặc các role nghiệp vụ)
            if ("OPERATOR".equals(role) || "REVIEWER".equals(role)) {
                targetUsers.add(u);
            }
        }

        // Lấy danh sách tất cả các máy
        List<Device> allDevices = deviceDAO.getAllDevices();

        // Lấy map phân công: userId -> List<Device>
        Map<Integer, List<Device>> assignmentsMap = assignmentDAO.getAssignmentsGroupedByUser();

        if (req.getParameter("success") != null) {
            req.setAttribute("successMessage", "Phân công quyền quản lý máy thành công!");
        }

        req.setAttribute("targetUsers", targetUsers);
        req.setAttribute("allDevices", allDevices);
        req.setAttribute("assignmentsMap", assignmentsMap);

        req.getRequestDispatcher("/WEB-INF/views/assignments.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        AppUser admin = (session != null) ? (AppUser) session.getAttribute("user") : null;
        if (admin == null || !"ADMIN".equals(admin.getRoleCode())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int userId = WebUtil.parseInt(req.getParameter("userId"), 0);
        String[] devIdStrs = req.getParameterValues("deviceIds");

        List<Integer> deviceIds = new ArrayList<Integer>();
        if (devIdStrs != null) {
            for (String str : devIdStrs) {
                int id = WebUtil.parseInt(str, 0);
                if (id > 0) {
                    deviceIds.add(id);
                }
            }
        }

        if (userId > 0) {
            assignmentDAO.assignDevices(userId, deviceIds, admin.getUserId());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/assignments?success=1");
    }
}
