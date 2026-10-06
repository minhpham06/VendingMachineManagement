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
        List<VendRestock> restocks = restockDAO.getAllRestocks();
        req.setAttribute("restocks", restocks);
        req.getRequestDispatcher("/WEB-INF/views/restocks.jsp").forward(req, resp);
    }

    private void showCreateForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<VendSlot> slots = slotDAO.getAllSlots();
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
            req.setAttribute("errorMessage", "Vui lòng chọn Rãnh và nhập Số lượng nạp hợp lệ (> 0).");
            req.setAttribute("slots", slotDAO.getAllSlots());
            req.setAttribute("selectedSlotId", slotId);
            req.setAttribute("selectedQuantity", quantity);
            req.setAttribute("selectedNote", note);
            req.getRequestDispatcher("/WEB-INF/views/restock_form.jsp").forward(req, resp);
            return;
        }

        // Kiểm tra nạp vượt quá sức chứa tối đa của rãnh
        int maxCanAdd = slot.getCapacity() - slot.getCurrentStock();
        if (slot.getCurrentStock() + quantity > slot.getCapacity()) {
            req.setAttribute("errorMessage", "Không thể nạp " + quantity + " gói! Rãnh " + slot.getCode() + 
                             " hiện có " + slot.getCurrentStock() + "/" + slot.getCapacity() + 
                             " gói (chỉ có thể nạp thêm tối đa " + Math.max(0, maxCanAdd) + " gói).");
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
            req.setAttribute("errorMessage", "Lỗi tạo phiếu nạp hàng.");
            req.setAttribute("slots", slotDAO.getAllSlots());
            req.setAttribute("selectedSlotId", slotId);
            req.setAttribute("selectedQuantity", quantity);
            req.setAttribute("selectedNote", note);
            req.getRequestDispatcher("/WEB-INF/views/restock_form.jsp").forward(req, resp);
        }
    }
}
