package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.DeviceAssignmentDAO;
import dao.DeviceDAO;
import model.AppUser;
import model.Device;
import util.WebUtil;

@WebServlet("/switch-machine")
public class SwitchMachineServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final DeviceDAO deviceDAO = new DeviceDAO();
    private final DeviceAssignmentDAO assignmentDAO = new DeviceAssignmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        AppUser user = (AppUser) session.getAttribute("user");
        int deviceId = WebUtil.parseInt(req.getParameter("deviceId"), 0);

        if (deviceId > 0) {
            boolean hasPermission = false;
            if ("ADMIN".equals(user.getRoleCode())) {
                hasPermission = true;
            } else {
                hasPermission = assignmentDAO.isUserAssignedToDevice(user.getUserId(), deviceId);
            }

            if (hasPermission) {
                Device device = deviceDAO.findById(deviceId);
                if (device != null) {
                    session.setAttribute("currentDeviceId", deviceId);
                    session.setAttribute("currentDevice", device);
                }
            }
        }

        // Quay lại trang trước đó hoặc về dashboard
        String referer = req.getHeader("Referer");
        if (referer != null && !referer.isEmpty() && !referer.contains("/switch-machine") && !referer.contains("/login")) {
            resp.sendRedirect(referer);
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        }
    }
}
