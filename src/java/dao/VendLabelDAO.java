package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.VendLabel;
import util.DBContext;

public class VendLabelDAO {

    public List<VendLabel> getLabelsBySessionId(int sessionId) {
        List<VendLabel> list = new ArrayList<VendLabel>();
        String sql = "SELECT l.label_id, l.session_id, l.label_code, l.source, " +
                     "l.reason, l.labeled_by, u.full_name AS reviewer_name, l.labeled_at " +
                     "FROM Vend_Label l " +
                     "LEFT JOIN AppUser u ON l.labeled_by = u.user_id " +
                     "WHERE l.session_id = ? " +
                     "ORDER BY l.label_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, sessionId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapLabel(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public boolean insertLabel(int sessionId, String labelCode, String source, Integer reviewerId, String reason) {
        String sql = "INSERT INTO Vend_Label (session_id, label_code, source, labeled_by, reason) VALUES (?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, sessionId);
            ps.setString(2, labelCode);
            ps.setString(3, source);
            if (reviewerId != null && reviewerId > 0) {
                ps.setInt(4, reviewerId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setString(5, reason);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    private VendLabel mapLabel(ResultSet rs) throws SQLException {
        VendLabel l = new VendLabel();
        l.setLabelId(rs.getInt("label_id"));
        l.setSessionId(rs.getInt("session_id"));
        l.setLabelCode(rs.getString("label_code"));
        l.setSource(rs.getString("source"));
        int rId = rs.getInt("labeled_by");
        if (!rs.wasNull()) {
            l.setReviewerId(rId);
            l.setReviewerName(rs.getString("reviewer_name"));
        }
        l.setReason(rs.getString("reason"));
        l.setLabeledAt(rs.getTimestamp("labeled_at"));
        return l;
    }
}
