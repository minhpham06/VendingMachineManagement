package controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.VendProductDAO;
import model.VendProduct;
import util.WebUtil;

@WebServlet(urlPatterns = {
    "/master/products",
    "/master/product/create",
    "/master/product/edit",
    "/master/product/delete"
})
public class ProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final VendProductDAO productDAO = new VendProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        if ("/master/product/create".equals(path)) {
            showCreateForm(req, resp);
        } else if ("/master/product/edit".equals(path)) {
            showEditForm(req, resp);
        } else if ("/master/product/delete".equals(path)) {
            handleDelete(req, resp);
        } else {
            showList(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        if ("/master/product/create".equals(path)) {
            doCreate(req, resp);
        } else if ("/master/product/edit".equals(path)) {
            doEdit(req, resp);
        } else {
            showList(req, resp);
        }
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<VendProduct> products = productDAO.getAllProducts(null);
        req.setAttribute("products", products);
        req.getRequestDispatcher("/WEB-INF/views/products.jsp").forward(req, resp);
    }

    private void showCreateForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/product_form.jsp").forward(req, resp);
    }

    private void doCreate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String code = req.getParameter("code");
        String name = req.getParameter("name");
        double weight = WebUtil.parseDouble(req.getParameter("nominalWeight"), -1);
        double tolerance = WebUtil.parseDouble(req.getParameter("tolerance"), 3.0);
        double price = WebUtil.parseDouble(req.getParameter("price"), 0);
        String note = req.getParameter("note");
        boolean active = "1".equals(req.getParameter("isActive"));

        if (name == null || name.trim().isEmpty() || weight <= 0) {
            req.setAttribute("errorMessage", "Tên mặt hàng và Khối lượng danh định (>0) là bắt buộc.");
            req.getRequestDispatcher("/WEB-INF/views/product_form.jsp").forward(req, resp);
            return;
        }

        if (code == null || code.trim().isEmpty()) {
            code = "PRD-" + System.currentTimeMillis() % 100000;
        }

        VendProduct p = new VendProduct();
        p.setCode(code.trim());
        p.setName(name.trim());
        p.setNominalWeight(weight);
        p.setTolerance(tolerance);
        p.setPrice(price);
        p.setNote(note != null ? note.trim() : null);
        p.setActive(active);

        int id = productDAO.insert(p);
        if (id > 0) {
            resp.sendRedirect(req.getContextPath() + "/master/products?success=created");
        } else {
            req.setAttribute("errorMessage", "Lỗi thêm sản phẩm.");
            req.getRequestDispatcher("/WEB-INF/views/product_form.jsp").forward(req, resp);
        }
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = WebUtil.parseInt(req.getParameter("id"), 0);
        VendProduct p = productDAO.findById(id);
        if (p == null) {
            resp.sendRedirect(req.getContextPath() + "/master/products?error=notfound");
            return;
        }
        req.setAttribute("product", p);
        req.getRequestDispatcher("/WEB-INF/views/product_form.jsp").forward(req, resp);
    }

    private void doEdit(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = WebUtil.parseInt(req.getParameter("id"), 0);
        VendProduct p = productDAO.findById(id);
        if (p == null) {
            resp.sendRedirect(req.getContextPath() + "/master/products?error=notfound");
            return;
        }

        String code = req.getParameter("code");
        String name = req.getParameter("name");
        double weight = WebUtil.parseDouble(req.getParameter("nominalWeight"), -1);
        double tolerance = WebUtil.parseDouble(req.getParameter("tolerance"), 3.0);
        double price = WebUtil.parseDouble(req.getParameter("price"), 0);
        String note = req.getParameter("note");
        boolean active = "1".equals(req.getParameter("isActive"));

        if (name == null || name.trim().isEmpty() || weight <= 0) {
            req.setAttribute("errorMessage", "Tên mặt hàng và Khối lượng danh định (>0) là bắt buộc.");
            req.setAttribute("product", p);
            req.getRequestDispatcher("/WEB-INF/views/product_form.jsp").forward(req, resp);
            return;
        }

        if (code != null && !code.trim().isEmpty()) {
            p.setCode(code.trim());
        }
        p.setName(name.trim());
        p.setNominalWeight(weight);
        p.setTolerance(tolerance);
        p.setPrice(price);
        p.setNote(note != null ? note.trim() : null);
        p.setActive(active);

        if (productDAO.update(p)) {
            resp.sendRedirect(req.getContextPath() + "/master/products?success=updated");
        } else {
            req.setAttribute("errorMessage", "Lỗi cập nhật sản phẩm.");
            req.setAttribute("product", p);
            req.getRequestDispatcher("/WEB-INF/views/product_form.jsp").forward(req, resp);
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = WebUtil.parseInt(req.getParameter("id"), 0);
        if (productDAO.delete(id)) {
            resp.sendRedirect(req.getContextPath() + "/master/products?success=deleted");
        } else {
            resp.sendRedirect(req.getContextPath() + "/master/products?error=fk_constraint");
        }
    }
}
