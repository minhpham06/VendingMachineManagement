package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.AppRole;
import util.DBContext;

public class AppRoleDAO {

    public List<AppRole> getAllRoles() {
        List<AppRole> list = new ArrayList<AppRole>();
        String sql = "SELECT role_id, role_code, role_name, description FROM AppRole ORDER BY role_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                AppRole r = new AppRole();
                r.setRoleId(rs.getInt("role_id"));
                r.setRoleCode(rs.getString("role_code"));
                r.setRoleName(rs.getString("role_name"));
                r.setDescription(rs.getString("description"));
                list.add(r);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public AppRole findById(int id) {
        String sql = "SELECT role_id, role_code, role_name, description FROM AppRole WHERE role_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                AppRole r = new AppRole();
                r.setRoleId(rs.getInt("role_id"));
                r.setRoleCode(rs.getString("role_code"));
                r.setRoleName(rs.getString("role_name"));
                r.setDescription(rs.getString("description"));
                return r;
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public int countUsersByRoleId(int roleId) {
        String sql = "SELECT COUNT(*) FROM AppUser WHERE role_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roleId);
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
}
