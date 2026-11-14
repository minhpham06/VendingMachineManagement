package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.DeviceDAO;
import dao.VendSessionDAO;
import dao.VendSlotDAO;
import model.AppUser;
import model.Device;
import model.VendSession;
import model.VendSlot;
import util.WebUtil;

@WebServlet("/sessions")
public class VendSessionListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final int PAGE_SIZE = 15;
    private final VendSessionDAO sessionDAO = new VendSessionDAO();
    private final VendSlotDAO slotDAO = new VendSlotDAO();
    private final DeviceDAO deviceDAO = new DeviceDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        AppUser user = (session != null) ? (AppUser) session.getAttribute("user") : null;
        Integer currentDeviceId = (session != null) ? (Integer) session.getAttribute("currentDeviceId") : null;

        // KIỂM SOÁT PHÂN QUYỀN THEO MÁY CHO OPERATOR VÀ REVIEWER
        if (user != null && ("OPERATOR".equals(user.getRoleCode()) || "REVIEWER".equals(user.getRoleCode()))) {
            List<Device> allowedDevices = deviceDAO.getDevicesByUserId(user.getUserId());
            if (allowedDevices == null || allowedDevices.isEmpty()) {
                // User chưa được phân công máy nào -> Không cho xem phiên nào
                req.setAttribute("sessions", new ArrayList<VendSession>());
                req.setAttribute("slots", new ArrayList<VendSlot>());
                req.setAttribute("totalSessions", 0);
                req.setAttribute("currentPage", 1);
                req.setAttribute("totalPages", 1);
                req.setAttribute("noAssignedMessage", "Tài khoản của bạn chưa được Admin phân công quản lý máy nào.");
                req.getRequestDispatcher("/WEB-INF/views/sessionList.jsp").forward(req, resp);
                return;
            }

            // Kiểm tra currentDeviceId có nằm trong danh sách được phép không
            boolean isValid = false;
            if (currentDeviceId != null) {
                for (Device d : allowedDevices) {
                    if (d.getDeviceId() == currentDeviceId) {
                        isValid = true;
                        break;
                    }
                }
            }

            // Nếu chưa chọn hoặc chọn máy không có quyền -> gán máy đầu tiên được phân công
            if (!isValid) {
                currentDeviceId = allowedDevices.get(0).getDeviceId();
                session.setAttribute("currentDeviceId", currentDeviceId);
                session.setAttribute("currentDevice", allowedDevices.get(0));
            }
        }

        String label = req.getParameter("label");
        Integer slotId = null;
        String slotStr = req.getParameter("slotId");
        if (slotStr != null && !slotStr.isEmpty()) {
            slotId = WebUtil.parseInt(slotStr, 0);
            if (slotId <= 0) slotId = null;
        }

        int page = WebUtil.parseInt(req.getParameter("page"), 1);
        if (page < 1) page = 1;

        int totalSessions = sessionDAO.count(label, slotId, currentDeviceId);
        int totalPages = (int) Math.ceil((double) totalSessions / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * PAGE_SIZE;
        List<VendSession> sessions = sessionDAO.search(label, slotId, currentDeviceId, offset, PAGE_SIZE);
        List<VendSlot> slots = slotDAO.getSlotsByDevice(currentDeviceId);

        req.setAttribute("sessions", sessions);
        req.setAttribute("slots", slots);
        req.setAttribute("totalSessions", totalSessions);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("label", label);
        req.setAttribute("slotId", slotId);

        req.getRequestDispatcher("/WEB-INF/views/sessionList.jsp").forward(req, resp);
    }
}
