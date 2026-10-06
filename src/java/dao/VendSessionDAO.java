package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.VendSession;
import util.DBContext;

public class VendSessionDAO {

    private static final String SELECT_BASE =
        "SELECT s.session_id, s.device_id, s.slot_id, sl.code AS slot_code, " +
        "p.name AS product_name, p.nominal_weight, p.tolerance, " +
        "s.device_seq, s.measured_at, s.ingested_at, " +
        "s.weight_before, s.weight_after, s.weight_delta, " +
        "s.coil_turns, s.motor_ms, s.settle_ms, s.peak_delta, s.is_sample, " +
        "l.label_code AS current_label, l.source AS label_source, l.reason AS label_reason, " +
        "u.full_name AS reviewer_name " +
        "FROM Vend_Session s " +
        "JOIN Vend_Slot sl ON s.slot_id = sl.slot_id " +
        "LEFT JOIN Vend_Product p ON sl.product_id = p.product_id " +
        "LEFT JOIN Vend_Label l ON l.label_id = (" +
        "    SELECT TOP 1 l2.label_id FROM Vend_Label l2 WHERE l2.session_id = s.session_id ORDER BY l2.label_id DESC" +
        ") " +
        "LEFT JOIN AppUser u ON l.labeled_by = u.user_id ";

    public List<VendSession> search(String label, Integer slotId, int offset, int limit) {
        List<VendSession> list = new ArrayList<VendSession>();
        StringBuilder sql = new StringBuilder(SELECT_BASE).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<Object>();

        if (label != null && !label.trim().isEmpty() && !"ALL".equalsIgnoreCase(label)) {
            sql.append("AND l.label_code = ? ");
            params.add(label.trim());
        }
        if (slotId != null && slotId > 0) {
            sql.append("AND s.slot_id = ? ");
            params.add(slotId);
        }

        sql.append("ORDER BY s.session_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(limit);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapSession(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public int count(String label, Integer slotId) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Vend_Session s " +
            "LEFT JOIN Vend_Label l ON l.label_id = (" +
            "    SELECT TOP 1 l2.label_id FROM Vend_Label l2 WHERE l2.session_id = s.session_id ORDER BY l2.label_id DESC" +
            ") WHERE 1=1 "
        );
        List<Object> params = new ArrayList<Object>();

        if (label != null && !label.trim().isEmpty() && !"ALL".equalsIgnoreCase(label)) {
            sql.append("AND l.label_code = ? ");
            params.add(label.trim());
        }
        if (slotId != null && slotId > 0) {
            sql.append("AND s.slot_id = ? ");
            params.add(slotId);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return 0;
    }

    public VendSession findById(int sessionId) {
        String sql = SELECT_BASE + "WHERE s.session_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, sessionId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapSession(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public int insertSession(VendSession s) {
        String sql = "INSERT INTO Vend_Session (device_id, slot_id, device_seq, weight_before, weight_after, " +
                     "weight_delta, coil_turns, motor_ms, settle_ms, peak_delta, is_sample) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, s.getDeviceId());
            ps.setInt(2, s.getSlotId());
            ps.setInt(3, s.getDeviceSeq());
            ps.setDouble(4, s.getWeightBefore());
            ps.setDouble(5, s.getWeightAfter());
            ps.setDouble(6, s.getWeightDelta());
            ps.setInt(7, s.getCoilTurns());
            ps.setInt(8, s.getMotorMs());
            ps.setInt(9, s.getSettleMs());
            ps.setDouble(10, s.getPeakDelta());
            ps.setBoolean(11, s.isSample());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return 0;
    }

    public List<VendSession> getAllForExport() {
        List<VendSession> list = new ArrayList<VendSession>();
        String sql = SELECT_BASE + "ORDER BY s.session_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapSession(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    private VendSession mapSession(ResultSet rs) throws SQLException {
        VendSession s = new VendSession();
        s.setSessionId(rs.getInt("session_id"));
        s.setDeviceId(rs.getInt("device_id"));
        s.setSlotId(rs.getInt("slot_id"));
        s.setSlotCode(rs.getString("slot_code"));
        s.setProductName(rs.getString("product_name"));
        s.setNominalWeight(rs.getDouble("nominal_weight"));
        s.setTolerance(rs.getDouble("tolerance"));
        s.setDeviceSeq(rs.getInt("device_seq"));
        s.setMeasuredAt(rs.getTimestamp("measured_at"));
        s.setIngestedAt(rs.getTimestamp("ingested_at"));
        s.setWeightBefore(rs.getDouble("weight_before"));
        s.setWeightAfter(rs.getDouble("weight_after"));
        s.setWeightDelta(rs.getDouble("weight_delta"));
        s.setCoilTurns(rs.getInt("coil_turns"));
        s.setMotorMs(rs.getInt("motor_ms"));
        s.setSettleMs(rs.getInt("settle_ms"));
        s.setPeakDelta(rs.getDouble("peak_delta"));
        s.setSample(rs.getBoolean("is_sample"));
        s.setCurrentLabel(rs.getString("current_label"));
        s.setLabelSource(rs.getString("label_source"));
        s.setLabelReason(rs.getString("label_reason"));
        s.setReviewerName(rs.getString("reviewer_name"));
        return s;
    }
}
