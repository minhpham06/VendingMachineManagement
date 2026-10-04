package controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.AppRoleDAO;
import model.AppRole;

@WebServlet("/admin/roles")
public class RoleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AppRoleDAO roleDAO = new AppRoleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<AppRole> roles = roleDAO.getAllRoles();
        Map<Integer, Integer> userCounts = new HashMap<Integer, Integer>();

        for (AppRole r : roles) {
            int count = roleDAO.countUsersByRoleId(r.getRoleId());
            userCounts.put(r.getRoleId(), count);
        }

        req.setAttribute("roles", roles);
        req.setAttribute("userCounts", userCounts);

        req.getRequestDispatcher("/WEB-INF/views/roles.jsp").forward(req, resp);
    }
}
