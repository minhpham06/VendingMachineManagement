package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DBContext;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int totalSessions = 0;
        int totalAlerts = 0;
        int totalProducts = 0;
        int totalSlots = 0;

        Map<String, Integer> labelCounts = new HashMap<String, Integer>();
        labelCounts.put("SUCCESS", 0);
        labelCounts.put("JAM", 0);
        labelCounts.put("WRONG_ITEM", 0);
        labelCounts.put("MOTOR_FAIL", 0);

        List<Map<String, Object>> productStats = new ArrayList<Map<String, Object>>();
        List<Double> deltaWeights = new ArrayList<Double>();

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();

            // 1. Dem phien theo tung nhan
            String sqlLabel = "SELECT l.label_code, COUNT(*) AS cnt " +
                             "FROM Vend_Session s " +
                             "JOIN Vend_Label l ON l.label_id = (" +
                             "    SELECT TOP 1 l2.label_id FROM Vend_Label l2 WHERE l2.session_id = s.session_id ORDER BY l2.label_id DESC" +
                             ") " +
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

            // 2. Dem so canh bao chua xu ly (status = 'OPEN')
            String sqlAlert = "SELECT COUNT(*) FROM Vend_Alert WHERE status = 'OPEN'";
            ps = conn.prepareStatement(sqlAlert);
            rs = ps.executeQuery();
            if (rs.next()) {
                totalAlerts = rs.getInt(1);
            }
            rs.close();
            ps.close();

            // 3. Dem so mat hang va so ranh
            String sqlCount = "SELECT (SELECT COUNT(*) FROM Vend_Product), (SELECT COUNT(*) FROM Vend_Slot)";
            ps = conn.prepareStatement(sqlCount);
            rs = ps.executeQuery();
            if (rs.next()) {
                totalProducts = rs.getInt(1);
                totalSlots = rs.getInt(2);
            }
            rs.close();
            ps.close();

            // 4. Thong ke ty le ket theo mat hang
            String sqlProdStat =
                "SELECT p.name AS product_name, " +
                "       COUNT(s.session_id) AS total_runs, " +
                "       SUM(CASE WHEN l.label_code = 'JAM' THEN 1 ELSE 0 END) AS jam_count, " +
                "       SUM(CASE WHEN l.label_code = 'SUCCESS' THEN 1 ELSE 0 END) AS success_count " +
                "FROM Vend_Product p " +
                "JOIN Vend_Slot sl ON sl.product_id = p.product_id " +
                "LEFT JOIN Vend_Session s ON s.slot_id = sl.slot_id " +
                "LEFT JOIN Vend_Label l ON l.label_id = (SELECT TOP 1 l2.label_id FROM Vend_Label l2 WHERE l2.session_id = s.session_id ORDER BY l2.label_id DESC) " +
                "GROUP BY p.name";
            ps = conn.prepareStatement(sqlProdStat);
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<String, Object>();
                map.put("name", rs.getString("product_name"));
                int total = rs.getInt("total_runs");
                int jam = rs.getInt("jam_count");
                int succ = rs.getInt("success_count");
                map.put("total", total);
                map.put("jam", jam);
                map.put("success", succ);
                map.put("jamRate", total > 0 ? (double) jam / total * 100.0 : 0.0);
                productStats.add(map);
            }
            rs.close();
            ps.close();

            // 5. Lay mau 100 do lech can nang (weight_delta) cho bieu do phan bo
            String sqlDelta = "SELECT TOP 100 weight_delta FROM Vend_Session ORDER BY session_id DESC";
            ps = conn.prepareStatement(sqlDelta);
            rs = ps.executeQuery();
            while (rs.next()) {
                deltaWeights.add(rs.getDouble("weight_delta"));
            }

        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }

        req.setAttribute("totalSessions", totalSessions);
        req.setAttribute("totalAlerts", totalAlerts);
        req.setAttribute("totalProducts", totalProducts);
        req.setAttribute("totalSlots", totalSlots);
        req.setAttribute("labelCounts", labelCounts);
        req.setAttribute("productStats", productStats);
        req.setAttribute("deltaWeights", deltaWeights);

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }
}
