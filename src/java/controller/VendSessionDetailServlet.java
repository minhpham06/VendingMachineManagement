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
import dao.VendLabelDAO;
import dao.VendSessionDAO;
import model.AppUser;
import model.VendLabel;
import model.VendSession;
import util.WebUtil;

@WebServlet("/session/detail")
public class VendSessionDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final VendSessionDAO sessionDAO = new VendSessionDAO();
    private final VendLabelDAO labelDAO = new VendLabelDAO();
    private final DeviceAssignmentDAO assignmentDAO = new DeviceAssignmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        AppUser user = (session != null) ? (AppUser) session.getAttribute("user") : null;

        int sessionId = WebUtil.parseInt(req.getParameter("id"), 0);
        VendSession sessionData = sessionDAO.findById(sessionId);

        if (sessionData == null) {
            resp.sendRedirect(req.getContextPath() + "/sessions?error=notfound");
            return;
        }

        // KIỂM TRA PHÂN QUYỀN MÁY CHO OPERATOR VÀ REVIEWER
        if (user != null && ("OPERATOR".equals(user.getRoleCode()) || "REVIEWER".equals(user.getRoleCode()))) {
            boolean hasPermission = assignmentDAO.isUserAssignedToDevice(user.getUserId(), sessionData.getDeviceId());
            if (!hasPermission) {
                // Không có quyền xem phiên của máy này -> Chặn 403
                req.setAttribute("errorMessage", "Bạn không có quyền truy cập dữ liệu phiên của máy bán hàng này.");
                req.getRequestDispatcher("/WEB-INF/views/403.jsp").forward(req, resp);
                return;
            }
        }

        List<VendLabel> labelHistory = labelDAO.getLabelsBySessionId(sessionId);

        req.setAttribute("sessionData", sessionData);
        req.setAttribute("labelHistory", labelHistory);

        req.getRequestDispatcher("/WEB-INF/views/sessionDetail.jsp").forward(req, resp);
    }
}
