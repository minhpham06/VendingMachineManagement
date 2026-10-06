package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.VendLabelDAO;
import dao.VendSessionDAO;
import model.AppUser;
import model.VendSession;
import util.WebUtil;

@WebServlet("/label/correct")
public class LabelReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final VendLabelDAO labelDAO = new VendLabelDAO();
    private final VendSessionDAO sessionDAO = new VendSessionDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        AppUser me = (AppUser) session.getAttribute("user");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int sessionId = WebUtil.parseInt(req.getParameter("sessionId"), 0);
        String newLabel = req.getParameter("newLabel");
        String reason = req.getParameter("reason");

        VendSession s = sessionDAO.findById(sessionId);
        if (s == null) {
            resp.sendRedirect(req.getContextPath() + "/sessions?error=notfound");
            return;
        }

        if (newLabel == null || newLabel.trim().isEmpty() || reason == null || reason.trim().length() < 5) {
            req.setAttribute("errorMessage", "Vui lòng chọn nhãn mới và nhập lý do sửa tối thiểu 5 ký tự.");
            req.setAttribute("sessionData", s);
            req.setAttribute("labelHistory", labelDAO.getLabelsBySessionId(sessionId));
            req.getRequestDispatcher("/WEB-INF/views/sessionDetail.jsp").forward(req, resp);
            return;
        }

        boolean ok = labelDAO.insertLabel(sessionId, newLabel.trim(), "REVIEWER", me.getUserId(), reason.trim());
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/session/detail?id=" + sessionId + "&success=corrected");
        } else {
            req.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu khi sửa nhãn.");
            req.setAttribute("sessionData", s);
            req.setAttribute("labelHistory", labelDAO.getLabelsBySessionId(sessionId));
            req.getRequestDispatcher("/WEB-INF/views/sessionDetail.jsp").forward(req, resp);
        }
    }
}
