package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.VendRestockDAO;
import dao.VendSlotDAO;
import model.AppUser;
import model.VendRestock;
import model.VendSlot;
import util.WebUtil;

@WebServlet(urlPatterns = {
    "/master/restocks",
    "/master/restock/create"
})
public class RestockServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final VendRestockDAO restockDAO = new VendRestockDAO();
    private final VendSlotDAO slotDAO = new VendSlotDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        if ("/master/restock/create".equals(path)) {
            showCreateForm(req, resp);
        } else {
            showList(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        if ("/master/restock/create".equals(path)) {
            doCreate(req, resp);
        } else {
            showList(req, resp);
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer currentDeviceId = (session != null) ? (Integer) session.getAttribute("currentDeviceId") : null;
        List<VendRestock> restocks = restockDAO.getAllRestocks(currentDeviceId);
        req.setAttribute("restocks", restocks);
        req.getRequestDispatcher("/WEB-INF/views/restocks.jsp").forward(req, resp);
    }

    private void showCreateForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Integer currentDeviceId = (session != null) ? (Integer) session.getAttribute("currentDeviceId") : null;
        List<VendSlot> slots = slotDAO.getSlotsByDevice(currentDeviceId);
        req.setAttribute("slots", slots);
        req.getRequestDispatcher("/WEB-INF/views/restock_form.jsp").forward(req, resp);
    }

    private void doCreate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        AppUser me = (AppUser) session.getAttribute("user");
        if (me == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int slotId = WebUtil.parseInt(req.getParameter("slotId"), 0);
        int quantity = WebUtil.parseInt(req.getParameter("quantity"), 0);
        String note = req.getParameter("note");

        VendSlot slot = slotDAO.findById(slotId);
        if (slot == null || quantity <= 0) {
            req.setAttribute("errorMessage", "Please select a Slot and enter a valid Restock Quantity (> 0).");
            req.setAttribute("slots", slotDAO.getAllSlots());
            req.setAttribute("selectedSlotId", slotId);
            req.setAttribute("selectedQuantity", quantity);
            req.setAttribute("selectedNote", note);
            req.getRequestDispatcher("/WEB-INF/views/restock_form.jsp").forward(req, resp);
            return;
        }

        // Check if slot is suspended or inactive
        if (slot.isSuspended() || !slot.isActive()) {
            req.setAttribute("errorMessage", "Cannot restock! Slot " + slot.getCode() + 
                             " is currently LOCKED (Suspended). Please unlock the slot before restocking.");
            req.setAttribute("slots", slotDAO.getAllSlots());
            req.setAttribute("selectedSlotId", slotId);
            req.setAttribute("selectedQuantity", quantity);
            req.setAttribute("selectedNote", note);
            req.getRequestDispatcher("/WEB-INF/views/restock_form.jsp").forward(req, resp);
            return;
        }

        // Check capacity limit
        int maxCanAdd = slot.getCapacity() - slot.getCurrentStock();
        if (slot.getCurrentStock() + quantity > slot.getCapacity()) {
            req.setAttribute("errorMessage", "Cannot restock " + quantity + " units! Slot " + slot.getCode() + 
                             " currently has " + slot.getCurrentStock() + "/" + slot.getCapacity() + 
                             " units (can only restock up to " + Math.max(0, maxCanAdd) + " more).");
            req.setAttribute("slots", slotDAO.getAllSlots());
            req.setAttribute("selectedSlotId", slotId);
            req.setAttribute("selectedQuantity", quantity);
            req.setAttribute("selectedNote", note);
            req.getRequestDispatcher("/WEB-INF/views/restock_form.jsp").forward(req, resp);
            return;
        }

        if (restockDAO.insertRestock(slotId, slot.getProductId(), quantity, me.getUserId(), note != null ? note.trim() : null)) {
            resp.sendRedirect(req.getContextPath() + "/master/restocks?success=created");
        } else {
            req.setAttribute("errorMessage", "Failed to create restock record.");
            req.setAttribute("slots", slotDAO.getAllSlots());
            req.setAttribute("selectedSlotId", slotId);
            req.setAttribute("selectedQuantity", quantity);
            req.setAttribute("selectedNote", note);
            req.getRequestDispatcher("/WEB-INF/views/restock_form.jsp").forward(req, resp);
        }
    }
}
