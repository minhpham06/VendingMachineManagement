package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.VendLabelDAO;
import dao.VendSessionDAO;
import model.VendLabel;
import model.VendSession;
import util.WebUtil;

@WebServlet("/session/detail")
public class VendSessionDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final VendSessionDAO sessionDAO = new VendSessionDAO();
    private final VendLabelDAO labelDAO = new VendLabelDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int sessionId = WebUtil.parseInt(req.getParameter("id"), 0);
        VendSession session = sessionDAO.findById(sessionId);

        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/sessions?error=notfound");
            return;
        }

        List<VendLabel> labelHistory = labelDAO.getLabelsBySessionId(sessionId);

        req.setAttribute("sessionData", session);
        req.setAttribute("labelHistory", labelHistory);

        req.getRequestDispatcher("/WEB-INF/views/sessionDetail.jsp").forward(req, resp);
    }
}
