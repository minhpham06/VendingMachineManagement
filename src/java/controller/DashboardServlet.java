package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.AppUser;
import util.DBContext;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        AppUser me = (AppUser) session.getAttribute("user");

        // Lay thong ke so luong phien theo tung nhan
        int totalSessions = 0;
        int totalUsers = 0;
        int totalAlerts = 0;
        Map<String, Integer> labelCounts = new HashMap<String, Integer>();
        labelCounts.put("SUCCESS", 0);
        labelCounts.put("JAM", 0);
        labelCounts.put("WRONG_ITEM", 0);
        labelCounts.put("MOTOR_FAIL", 0);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();

            // 1. Dem phien theo tung nhan
            String sqlLabel = "SELECT l.label_code, COUNT(*) AS cnt " +
                             "FROM Vend_Session s " +
                             "JOIN Vend_Label l ON l.session_id = s.session_id " +
                             "WHERE l.label_id = (SELECT MAX(l2.label_id) FROM Vend_Label l2 WHERE l2.session_id = s.session_id) " +
                             "GROUP BY l.label_code";
            ps = conn.prepareStatement(sqlLabel);
            rs = ps.executeQuery();
            while (rs.next()) {
                String code = rs.getString("label_code");
                int cnt = rs.getInt("cnt");
                labelCounts.put(code, cnt);
                totalSessions += cnt;
            }
            rs.close();
            ps.close();

            // 2. Dem tong so user
            ps = conn.prepareStatement("SELECT COUNT(*) FROM AppUser");
            rs = ps.executeQuery();
            if (rs.next()) {
                totalUsers = rs.getInt(1);
            }
            rs.close();
            ps.close();

            // 3. Dem canh bao dang mo (OPEN)
            ps = conn.prepareStatement("SELECT COUNT(*) FROM Vend_Alert WHERE status = 'OPEN'");
            rs = ps.executeQuery();
            if (rs.next()) {
                totalAlerts = rs.getInt(1);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        // Tinh ti le thanh cong
        double successRate = totalSessions > 0 ? (labelCounts.get("SUCCESS") * 100.0 / totalSessions) : 0.0;

        req.setAttribute("totalSessions", totalSessions);
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("totalAlerts", totalAlerts);
        req.setAttribute("labelCounts", labelCounts);
        req.setAttribute("successRate", String.format("%.1f", successRate));
        req.setAttribute("currentUser", me);

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }
}
