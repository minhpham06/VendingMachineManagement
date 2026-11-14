package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.AppUser;
import model.Device;
import model.UserDeviceAssignment;
import util.DBContext;

public class DeviceAssignmentDAO {

    public List<AppUser> getStaffAssignedToDevice(int deviceId, String roleCode) {
        List<AppUser> list = new ArrayList<AppUser>();
        StringBuilder sql = new StringBuilder(
            "SELECT u.user_id, u.username, u.full_name, u.email, u.phone, r.role_code " +
            "FROM User_Device_Assignment a " +
            "JOIN AppUser u ON a.user_id = u.user_id " +
            "JOIN AppRole r ON u.role_id = r.role_id " +
            "WHERE a.device_id = ? "
        );
        if (roleCode != null && !roleCode.isEmpty()) {
            sql.append("AND r.role_code = ? ");
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            ps.setInt(1, deviceId);
            if (roleCode != null && !roleCode.isEmpty()) {
                ps.setString(2, roleCode);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                AppUser u = new AppUser();
                u.setUserId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                u.setPhone(rs.getString("phone"));
                u.setRoleCode(rs.getString("role_code"));
                list.add(u);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public List<Integer> getAssignedDeviceIds(int userId) {
        List<Integer> list = new ArrayList<Integer>();
        String sql = "SELECT device_id FROM User_Device_Assignment WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("device_id"));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public boolean isUserAssignedToDevice(int userId, int deviceId) {
        String sql = "SELECT 1 FROM User_Device_Assignment WHERE user_id = ? AND device_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, deviceId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return false;
    }

    public Map<Integer, List<Device>> getAssignmentsGroupedByUser() {
        Map<Integer, List<Device>> map = new HashMap<Integer, List<Device>>();
        String sql = "SELECT a.user_id, d.device_id, d.device_code, d.machine_name, d.location_name, d.is_hardware_demo " +
                     "FROM User_Device_Assignment a " +
                     "JOIN Device d ON a.device_id = d.device_id " +
                     "ORDER BY a.user_id, d.device_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                int uid = rs.getInt("user_id");
                Device d = new Device();
                d.setDeviceId(rs.getInt("device_id"));
                d.setDeviceCode(rs.getString("device_code"));
                d.setMachineName(rs.getString("machine_name"));
                d.setLocationName(rs.getString("location_name"));
                d.setHardwareDemo(rs.getBoolean("is_hardware_demo"));

                if (!map.containsKey(uid)) {
                    map.put(uid, new ArrayList<Device>());
                }
                map.get(uid).add(d);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return map;
    }

    public boolean assignDevices(int userId, List<Integer> deviceIds, int assignedBy) {
        Connection conn = null;
        PreparedStatement psDelete = null;
        PreparedStatement psInsert = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 1. Xóa các phân công cũ của user này
            String deleteSql = "DELETE FROM User_Device_Assignment WHERE user_id = ?";
            psDelete = conn.prepareStatement(deleteSql);
            psDelete.setInt(1, userId);
            psDelete.executeUpdate();

            // 2. Thêm các phân công mới
            if (deviceIds != null && !deviceIds.isEmpty()) {
                String insertSql = "INSERT INTO User_Device_Assignment(user_id, device_id, assigned_by) VALUES (?, ?, ?)";
                psInsert = conn.prepareStatement(insertSql);
                for (Integer devId : deviceIds) {
                    if (devId != null && devId > 0) {
                        psInsert.setInt(1, userId);
                        psInsert.setInt(2, devId);
                        psInsert.setInt(3, assignedBy);
                        psInsert.addBatch();
                    }
                }
                psInsert.executeBatch();
            }

            conn.commit();
            return true;
        } catch (SQLException ex) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            ex.printStackTrace();
        } finally {
            DBContext.close(null, psDelete, null);
            DBContext.close(null, psInsert, conn);
        }
        return false;
    }
}
