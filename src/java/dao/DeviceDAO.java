package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Device;
import util.DBContext;

public class DeviceDAO {

    private static final String SELECT_BASE =
        "SELECT device_id, device_code, api_key, mac_address, status, " +
        "machine_name, location_name, is_hardware_demo, created_at " +
        "FROM Device ";

    public Device findByApiKey(String apiKey) {
        if (apiKey == null) return null;
        String sql = SELECT_BASE + "WHERE api_key = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, apiKey.trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapDevice(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public Device findById(int deviceId) {
        String sql = SELECT_BASE + "WHERE device_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, deviceId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapDevice(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public List<Device> getAllDevices() {
        List<Device> list = new ArrayList<Device>();
        String sql = SELECT_BASE + "ORDER BY device_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapDevice(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public List<Device> getDevicesByUserId(int userId) {
        List<Device> list = new ArrayList<Device>();
        String sql = "SELECT d.device_id, d.device_code, d.api_key, d.mac_address, d.status, " +
                     "d.machine_name, d.location_name, d.is_hardware_demo, d.created_at " +
                     "FROM Device d " +
                     "JOIN User_Device_Assignment a ON d.device_id = a.device_id " +
                     "WHERE a.user_id = ? " +
                     "ORDER BY d.device_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapDevice(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    private Device mapDevice(ResultSet rs) throws SQLException {
        Device d = new Device();
        d.setDeviceId(rs.getInt("device_id"));
        d.setDeviceCode(rs.getString("device_code"));
        d.setApiKey(rs.getString("api_key"));
        d.setMacAddress(rs.getString("mac_address"));
        d.setStatus(rs.getString("status"));
        try {
            d.setMachineName(rs.getString("machine_name"));
            d.setLocationName(rs.getString("location_name"));
            d.setHardwareDemo(rs.getBoolean("is_hardware_demo"));
        } catch (SQLException ignored) {
            // Trường hợp chạy với schema cũ tạm thời chưa có cột
        }
        d.setCreatedAt(rs.getTimestamp("created_at"));
        return d;
    }
}
