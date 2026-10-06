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

    public Device findByApiKey(String apiKey) {
        if (apiKey == null) return null;
        String sql = "SELECT device_id, device_code, api_key, mac_address, status, created_at " +
                     "FROM Device WHERE api_key = ?";
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

    public List<Device> getAllDevices() {
        List<Device> list = new ArrayList<Device>();
        String sql = "SELECT device_id, device_code, api_key, mac_address, status, created_at FROM Device ORDER BY device_id ASC";
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

    private Device mapDevice(ResultSet rs) throws SQLException {
        Device d = new Device();
        d.setDeviceId(rs.getInt("device_id"));
        d.setDeviceCode(rs.getString("device_code"));
        d.setApiKey(rs.getString("api_key"));
        d.setMacAddress(rs.getString("mac_address"));
        d.setStatus(rs.getString("status"));
        d.setCreatedAt(rs.getTimestamp("created_at"));
        return d;
    }
}
