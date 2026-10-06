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
import model.AppUser;
import model.VendAlert;
import util.WebUtil;

@WebServlet(urlPatterns = {
    "/alerts",
    "/alert/resolve"
})
public class AlertServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final VendAlertDAO alertDAO = new VendAlertDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();
        if ("/alert/resolve".equals(path)) {
            doResolve(req, resp);
            return;
        }

        String filter = req.getParameter("filter");
        Boolean onlyUnresolved = !"all".equalsIgnoreCase(filter);

        List<VendAlert> alerts = alertDAO.getAllAlerts(onlyUnresolved);
        int unresolvedCount = alertDAO.countUnresolvedAlerts();

        req.setAttribute("alerts", alerts);
        req.setAttribute("unresolvedCount", unresolvedCount);
        req.setAttribute("filter", filter);

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
        if (note == null || note.trim().isEmpty()) {
            note = "Đã kiểm tra và xử lý bởi " + me.getFullName();
        }

        if (alertId > 0) {
            alertDAO.resolveAlert(alertId, me.getUserId(), note.trim());
        }

        resp.sendRedirect(req.getContextPath() + "/alerts?success=resolved");
    }
}
