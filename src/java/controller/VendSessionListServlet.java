package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.VendSessionDAO;
import model.VendSession;
import util.WebUtil;

@WebServlet("/sessions")
public class VendSessionListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int PAGE_SIZE = 20;
    private final VendSessionDAO dao = new VendSessionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String label = req.getParameter("label");
        if (label != null && label.trim().isEmpty()) label = null;

        Integer deviceId = null;
        String dev = req.getParameter("device");
        if (dev != null && !dev.isEmpty()) {
            try { deviceId = Integer.valueOf(dev); } catch (NumberFormatException ignored) { }
        }

        int page = WebUtil.parseInt(req.getParameter("page"), 1);
        if (page < 1) page = 1;

        List<VendSession> rows = dao.search(label, deviceId, page, PAGE_SIZE);
        int total = dao.count(label, deviceId);
        int pages = (total + PAGE_SIZE - 1) / PAGE_SIZE;
        if (pages < 1) pages = 1;

        req.setAttribute("rows", rows);
        req.setAttribute("page", page);
        req.setAttribute("pages", pages);
        req.setAttribute("total", total);
        req.setAttribute("label", label);

        req.getRequestDispatcher("/WEB-INF/views/sessionList.jsp").forward(req, resp);
    }
}
