package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.VendProductDAO;
import dao.VendSlotDAO;
import model.VendProduct;
import model.VendSlot;
import util.WebUtil;

@WebServlet(urlPatterns = {
    "/master/slots",
    "/master/slot/edit",
    "/master/slot/toggle"
})
public class SlotServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final VendSlotDAO slotDAO = new VendSlotDAO();
    private final VendProductDAO productDAO = new VendProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        if ("/master/slot/edit".equals(path)) {
            showEditForm(req, resp);
        } else if ("/master/slot/toggle".equals(path)) {
            toggleStatus(req, resp);
        } else {
            showList(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        if ("/master/slot/edit".equals(path)) {
            doEdit(req, resp);
        } else {
            showList(req, resp);
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<VendSlot> slots = slotDAO.getAllSlots();
        req.setAttribute("slots", slots);
        req.getRequestDispatcher("/WEB-INF/views/slots.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = WebUtil.parseInt(req.getParameter("id"), 0);
        VendSlot slot = slotDAO.findById(id);
        if (slot == null) {
            resp.sendRedirect(req.getContextPath() + "/master/slots?error=notfound");
            return;
        }
        List<VendProduct> products = productDAO.getAllProducts(true);
        req.setAttribute("slot", slot);
        req.setAttribute("products", products);
        req.getRequestDispatcher("/WEB-INF/views/slot_form.jsp").forward(req, resp);
    }

    private void doEdit(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int slotId = WebUtil.parseInt(req.getParameter("id"), 0);
        VendSlot slot = slotDAO.findById(slotId);
        if (slot == null) {
            resp.sendRedirect(req.getContextPath() + "/master/slots?error=notfound");
            return;
        }

        Integer productId = WebUtil.parseInt(req.getParameter("productId"), 0);
        if (productId <= 0) productId = null;
        int capacity = WebUtil.parseInt(req.getParameter("capacity"), 10);
        int currentStock = WebUtil.parseInt(req.getParameter("currentStock"), 0);
        boolean isSuspended = "1".equals(req.getParameter("isSuspended"));

        if (slotDAO.update(slotId, productId, capacity, currentStock, isSuspended)) {
            resp.sendRedirect(req.getContextPath() + "/master/slots?success=updated");
        } else {
            req.setAttribute("errorMessage", "Lỗi cập nhật cấu hình rãnh.");
            req.setAttribute("slot", slot);
            req.setAttribute("products", productDAO.getAllProducts(true));
            req.getRequestDispatcher("/WEB-INF/views/slot_form.jsp").forward(req, resp);
        }
    }

    private void toggleStatus(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int slotId = WebUtil.parseInt(req.getParameter("id"), 0);
        VendSlot slot = slotDAO.findById(slotId);
        if (slot != null) {
            slotDAO.setSuspended(slotId, !slot.isSuspended());
        }
        resp.sendRedirect(req.getContextPath() + "/master/slots?success=toggled");
    }
}
