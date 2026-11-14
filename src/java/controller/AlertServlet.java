package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.VendAlertDAO;
import dao.VendSlotDAO;
import model.AppUser;
import model.VendAlert;
import util.WebUtil;

@WebServlet(urlPatterns = {
    "/alerts",
    "/alert/resolve",
    "/alert/test-email"
})
public class AlertServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final VendAlertDAO alertDAO = new VendAlertDAO();
    private final VendSlotDAO slotDAO = new VendSlotDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();
        if ("/alert/resolve".equals(path)) {
            doResolve(req, resp);
            return;
        } else if ("/alert/test-email".equals(path)) {
            doTestEmail(req, resp);
            return;
        }

        String filter = req.getParameter("filter");
        if (filter == null || filter.trim().isEmpty()) {
            filter = "all";
        }

        HttpSession session = req.getSession(false);
        Integer currentDeviceId = (session != null) ? (Integer) session.getAttribute("currentDeviceId") : null;

        List<VendAlert> alerts = alertDAO.getAllAlerts(filter, currentDeviceId);
        int totalCount = alertDAO.countTotalAlerts(currentDeviceId);
        int unresolvedCount = alertDAO.countUnresolvedAlerts(currentDeviceId);
        int resolvedCount = alertDAO.countResolvedAlerts(currentDeviceId);

        req.setAttribute("alerts", alerts);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("unresolvedCount", unresolvedCount);
        req.setAttribute("resolvedCount", resolvedCount);
        req.setAttribute("filter", filter.toLowerCase());
        req.setAttribute("resolvedId", req.getParameter("resolvedId"));

        req.getRequestDispatcher("/WEB-INF/views/alerts.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doResolve(req, resp);
    }

    private void doResolve(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        AppUser me = (AppUser) session.getAttribute("user");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int alertId = WebUtil.parseInt(req.getParameter("id"), 0);
        String note = req.getParameter("note");
        String filter = req.getParameter("filter");
        if (filter == null || filter.trim().isEmpty()) {
            filter = "all";
        }
        boolean unsuspendSlot = "1".equals(req.getParameter("unsuspendSlot")) 
                || "true".equalsIgnoreCase(req.getParameter("unsuspendSlot"));

        if (alertId > 0) {
            VendAlert alert = alertDAO.findById(alertId);
            if (note == null || note.trim().isEmpty()) {
                note = "Inspected and resolved by " + me.getFullName();
            }
            alertDAO.resolveAlert(alertId, me.getUserId(), note.trim());

            if (unsuspendSlot) {
                if (alert != null && alert.getSlotId() != null && alert.getSlotId() > 0) {
                    slotDAO.setSuspended(alert.getSlotId(), false);
                }
            }

            // Gửi email xác nhận sự cố đã được xử lý thành công cho nhân viên
            try {
                String devCode = (alert != null && alert.getDeviceCode() != null) ? alert.getDeviceCode() : "Vend-01";
                String devName = (alert != null && alert.getMachineName() != null) ? alert.getMachineName() : "Main Machine";
                String slotCode = (alert != null && alert.getSlotCode() != null) ? alert.getSlotCode() : "N/A";
                String ruleCode = (alert != null && alert.getRuleCode() != null) ? alert.getRuleCode() : "INCIDENT";

                util.EmailService.sendResolutionNotification(
                    util.EmailService.DEFAULT_OPERATOR_EMAIL,
                    util.EmailService.DEFAULT_OPERATOR_NAME,
                    alertId,
                    devCode,
                    devName,
                    slotCode,
                    ruleCode,
                    me.getFullName(),
                    note.trim(),
                    unsuspendSlot
                );
            } catch (Throwable ex) {
                System.err.println("[ALERT RESOLVE EMAIL ERROR] " + ex.getMessage());
                ex.printStackTrace();
            }
        }

        // Tu dong chuyen huong sang tab 'resolved' neu nguoi dung thao tac tu 'open'
        // de lap tuc nhin thay ban ghi cua minh duoc cap nhat vao lich su va co highlight
        String redirectFilter = "open".equalsIgnoreCase(filter) ? "resolved" : filter;
        resp.sendRedirect(req.getContextPath() + "/alerts?filter=" + redirectFilter + "&success=resolved&resolvedId=" + alertId);
    }

    private void doTestEmail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        AppUser me = (AppUser) session.getAttribute("user");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            // Gửi email thử nghiệm cảnh báo đến nhân viên Lê Vận Hành
            util.EmailService.sendAlertNotification(
                util.EmailService.DEFAULT_OPERATOR_EMAIL,
                util.EmailService.DEFAULT_OPERATOR_NAME,
                "Vend-01",
                "Main Hardware Vending Machine",
                "Alpha Building - Central Lobby",
                "S-02",
                "JAM_STREAK",
                "CRITICAL",
                "Live system test: Slot S-02 has reported a consecutive item jam streak. Machine coil is temporarily locked for inspection."
            );
        } catch (Throwable t) {
            System.err.println("[TEST EMAIL ERROR] " + t.getMessage());
            t.printStackTrace();
        }

        resp.sendRedirect(req.getContextPath() + "/alerts?success=test_sent");
    }
}
