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
        "SELECT s.session_id, s.device_id, d.device_code, s.slot_id, s.device_seq, s.measured_at, s.ingested_at, " +
        "s.is_sample, s.weight_before, s.weight_after, s.weight_delta, s.coil_turns, s.motor_ms, s.settle_ms, s.peak_delta, " +
        "(SELECT TOP 1 l.label_code FROM Vend_Label l " +
        " WHERE l.session_id = s.session_id ORDER BY l.label_id DESC) AS label_code " +
        "FROM Vend_Session s " +
        "LEFT JOIN Device d ON s.device_id = d.device_id ";

    public List<VendSession> search(String label, Integer deviceId, int page, int size) {
        List<VendSession> out = new ArrayList<VendSession>();
        StringBuilder sb = new StringBuilder(SELECT_BASE).append("WHERE 1 = 1 ");
        if (label != null && !label.isEmpty()) {
            sb.append("AND EXISTS (SELECT 1 FROM Vend_Label l2 WHERE l2.session_id = s.session_id ")
              .append("AND l2.label_code = ? AND l2.label_id = ")
              .append("(SELECT MAX(l3.label_id) FROM Vend_Label l3 WHERE l3.session_id = s.session_id)) ");
        }
        if (deviceId != null && deviceId > 0) sb.append("AND s.device_id = ? ");
        sb.append("ORDER BY s.measured_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sb.toString());
            int i = 1;
            if (label != null && !label.isEmpty()) ps.setString(i++, label.trim());
            if (deviceId != null && deviceId > 0) ps.setInt(i++, deviceId.intValue());
            ps.setInt(i++, (Math.max(1, page) - 1) * size);
            ps.setInt(i++, size);
            rs = ps.executeQuery();
            while (rs.next()) out.add(map(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, cn);
        }
        return out;
    }

    public int count(String label, Integer deviceId) {
        String sql = "SELECT COUNT(*) FROM Vend_Session s WHERE 1 = 1 "
            + (label != null && !label.isEmpty()
               ? "AND EXISTS (SELECT 1 FROM Vend_Label l2 WHERE l2.session_id = s.session_id AND l2.label_code = ?) " : "")
            + (deviceId != null && deviceId > 0 ? "AND s.device_id = ? " : "");
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            int i = 1;
            if (label != null && !label.isEmpty()) ps.setString(i++, label.trim());
            if (deviceId != null && deviceId > 0) ps.setInt(i++, deviceId.intValue());
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, cn);
        }
        return 0;
    }

    public VendSession findById(int id) {
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(SELECT_BASE + "WHERE s.session_id = ?");
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBContext.close(rs, ps, cn);
        }
        return null;
    }

    private VendSession map(ResultSet rs) throws SQLException {
        VendSession o = new VendSession();
        o.setSessionId(rs.getInt("session_id"));
        o.setDeviceId(rs.getInt("device_id"));
        o.setDeviceCode(rs.getString("device_code"));
        int slot = rs.getInt("slot_id");
        if (!rs.wasNull()) o.setSlotId(slot);
        o.setDeviceSeq(rs.getInt("device_seq"));
        o.setMeasuredAt(rs.getTimestamp("measured_at"));
        o.setIngestedAt(rs.getTimestamp("ingested_at"));
        o.setSample(rs.getBoolean("is_sample"));
        o.setLabelCode(rs.getString("label_code"));
        o.setWeightBefore(rs.getDouble("weight_before"));
        o.setWeightAfter(rs.getDouble("weight_after"));
        o.setWeightDelta(rs.getDouble("weight_delta"));
        o.setCoilTurns(rs.getInt("coil_turns"));
        o.setMotorMs(rs.getInt("motor_ms"));
        o.setSettleMs(rs.getInt("settle_ms"));
        o.setPeakDelta(rs.getDouble("peak_delta"));
        return o;
    }
}
