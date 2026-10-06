package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.VendSessionDAO;
import dao.VendSlotDAO;
import model.VendSession;
import model.VendSlot;
import util.WebUtil;

@WebServlet("/sessions")
public class VendSessionListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final int PAGE_SIZE = 15;
    private final VendSessionDAO sessionDAO = new VendSessionDAO();
    private final VendSlotDAO slotDAO = new VendSlotDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String label = req.getParameter("label");
        Integer slotId = null;
        String slotStr = req.getParameter("slotId");
        if (slotStr != null && !slotStr.isEmpty()) {
            slotId = WebUtil.parseInt(slotStr, 0);
            if (slotId <= 0) slotId = null;
        }

        int page = WebUtil.parseInt(req.getParameter("page"), 1);
        if (page < 1) page = 1;

        int totalSessions = sessionDAO.count(label, slotId);
        int totalPages = (int) Math.ceil((double) totalSessions / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * PAGE_SIZE;
        List<VendSession> sessions = sessionDAO.search(label, slotId, offset, PAGE_SIZE);
        List<VendSlot> slots = slotDAO.getAllSlots();

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
