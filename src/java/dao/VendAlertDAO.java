package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.VendAlert;
import util.DBContext;

public class VendAlertDAO {

    private static final String SELECT_BASE =
        "SELECT a.alert_id, a.session_id, a.slot_id, sl.code AS slot_code, " +
        "ISNULL(sl.is_suspended, 0) AS slot_suspended, " +
        "a.rule_code, a.severity, a.message, a.status, " +
        "a.handled_by, u.full_name AS handler_name, a.handled_note, a.created_at, " +
        "COALESCE(d1.device_code, d2.device_code, 'Vend-01') AS device_code, " +
        "COALESCE(d1.machine_name, d2.machine_name, 'Main Machine') AS machine_name " +
        "FROM Vend_Alert a " +
        "LEFT JOIN Vend_Slot sl ON a.slot_id = sl.slot_id " +
        "LEFT JOIN Device d1 ON sl.device_id = d1.device_id " +
        "LEFT JOIN Vend_Session ses ON a.session_id = ses.session_id " +
        "LEFT JOIN Device d2 ON ses.device_id = d2.device_id " +
        "LEFT JOIN AppUser u ON a.handled_by = u.user_id ";

    public List<VendAlert> getAllAlerts(Boolean onlyUnresolved) {
        return getAllAlerts(Boolean.TRUE.equals(onlyUnresolved) ? "OPEN" : "ALL", null);
    }

    public List<VendAlert> getAllAlerts(Boolean onlyUnresolved, Integer deviceId) {
        return getAllAlerts(Boolean.TRUE.equals(onlyUnresolved) ? "OPEN" : "ALL", deviceId);
    }

    public List<VendAlert> getAllAlerts(String statusFilter, Integer deviceId) {
        List<VendAlert> list = new ArrayList<VendAlert>();
        StringBuilder sql = new StringBuilder(SELECT_BASE).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<Object>();

        if ("OPEN".equalsIgnoreCase(statusFilter) || "UNRESOLVED".equalsIgnoreCase(statusFilter)) {
            sql.append("AND a.status = 'OPEN' ");
        } else if ("RESOLVED".equalsIgnoreCase(statusFilter)) {
            sql.append("AND a.status = 'RESOLVED' ");
        }

        if (deviceId != null && deviceId > 0) {
            sql.append("AND (sl.device_id = ? OR a.session_id IN (SELECT session_id FROM Vend_Session WHERE device_id = ?)) ");
            params.add(deviceId);
            params.add(deviceId);
        }

        sql.append("ORDER BY CASE WHEN a.status = 'OPEN' THEN 0 ELSE 1 END, a.alert_id DESC");

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
                list.add(mapAlert(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public VendAlert findById(int alertId) {
        String sql = SELECT_BASE + "WHERE a.alert_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, alertId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapAlert(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public int countUnresolvedAlerts() {
        return countUnresolvedAlerts(null);
    }

    public int countUnresolvedAlerts(Integer deviceId) {
        return countAlertsByStatus("OPEN", deviceId);
    }

    public int countResolvedAlerts(Integer deviceId) {
        return countAlertsByStatus("RESOLVED", deviceId);
    }

    public int countTotalAlerts(Integer deviceId) {
        return countAlertsByStatus(null, deviceId);
    }

    private int countAlertsByStatus(String status, Integer deviceId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Vend_Alert a " +
                                              "LEFT JOIN Vend_Slot sl ON a.slot_id = sl.slot_id " +
                                              "WHERE 1=1 ");
        List<Object> params = new ArrayList<Object>();
        if (status != null && !status.isEmpty()) {
            sql.append("AND a.status = ? ");
            params.add(status);
        }
        if (deviceId != null && deviceId > 0) {
            sql.append("AND (sl.device_id = ? OR a.session_id IN (SELECT session_id FROM Vend_Session WHERE device_id = ?)) ");
            params.add(deviceId);
            params.add(deviceId);
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

    public boolean insertAlert(VendAlert a) {
        String sql = "INSERT INTO Vend_Alert (session_id, slot_id, rule_code, severity, message, status) " +
                     "VALUES (?, ?, ?, ?, ?, 'OPEN')";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            if (a.getSessionId() != null && a.getSessionId() > 0) {
                ps.setInt(1, a.getSessionId());
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            if (a.getSlotId() != null && a.getSlotId() > 0) {
                ps.setInt(2, a.getSlotId());
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, a.getRuleCode());
            ps.setString(4, a.getSeverity());
            ps.setString(5, a.getMessage());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean resolveAlert(int alertId, int userId, String note) {
        String sql = "UPDATE Vend_Alert SET status = 'RESOLVED', handled_by = ?, handled_note = ? WHERE alert_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, note);
            ps.setInt(3, alertId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    private VendAlert mapAlert(ResultSet rs) throws SQLException {
        VendAlert a = new VendAlert();
        a.setAlertId(rs.getInt("alert_id"));
        int sesId = rs.getInt("session_id");
        if (!rs.wasNull()) a.setSessionId(sesId);
        int sId = rs.getInt("slot_id");
        if (!rs.wasNull()) {
            a.setSlotId(sId);
            a.setSlotCode(rs.getString("slot_code"));
        }
        a.setSlotSuspended(rs.getBoolean("slot_suspended"));
        a.setRuleCode(rs.getString("rule_code"));
        a.setSeverity(rs.getString("severity"));
        a.setMessage(rs.getString("message"));
        a.setStatus(rs.getString("status"));
        int rBy = rs.getInt("handled_by");
        if (!rs.wasNull()) {
            a.setHandledBy(rBy);
            a.setHandlerName(rs.getString("handler_name"));
        }
        a.setHandledNote(rs.getString("handled_note"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setDeviceCode(rs.getString("device_code"));
        a.setMachineName(rs.getString("machine_name"));
        return a;
    }
}
