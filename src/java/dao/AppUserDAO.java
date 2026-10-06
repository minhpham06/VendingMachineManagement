package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.AppUser;
import util.DBContext;
import util.PasswordUtil;

public class AppUserDAO {

    private static final String SELECT_BASE =
        "SELECT u.user_id, u.username, u.pass_hash, u.full_name, u.email, u.phone, " +
        "u.role_id, r.role_code, r.role_name, u.is_locked, u.created_at " +
        "FROM AppUser u " +
        "JOIN AppRole r ON u.role_id = r.role_id ";

    public AppUser findByUsername(String username) {
        if (username == null) return null;
        String sql = SELECT_BASE + "WHERE u.username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username.trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public AppUser findById(int userId) {
        String sql = SELECT_BASE + "WHERE u.user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    /**
     * Kiem tra dang nhap: xac thuc PBKDF2.
     */
    public AppUser authenticate(String username, String rawPassword) {
        AppUser user = findByUsername(username);
        if (user == null) {
            return null;
        }
        if (PasswordUtil.verify(rawPassword, user.getPassHash())) {
            return user;
        }
        return null;
    }

    public List<AppUser> search(String q, Integer roleId, Boolean locked, int offset, int limit) {
        List<AppUser> list = new ArrayList<AppUser>();
        StringBuilder sql = new StringBuilder(SELECT_BASE).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<Object>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append("AND (u.username LIKE ? OR u.full_name LIKE ? OR u.email LIKE ?) ");
            String pattern = "%" + q.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        if (roleId != null && roleId > 0) {
            sql.append("AND u.role_id = ? ");
            params.add(roleId);
        }
        if (locked != null) {
            sql.append("AND u.is_locked = ? ");
            params.add(locked ? 1 : 0);
        }

        sql.append("ORDER BY u.user_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
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
                list.add(mapUser(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public int count(String q, Integer roleId, Boolean locked) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM AppUser u WHERE 1=1 ");
        List<Object> params = new ArrayList<Object>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append("AND (u.username LIKE ? OR u.full_name LIKE ? OR u.email LIKE ?) ");
            String pattern = "%" + q.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        if (roleId != null && roleId > 0) {
            sql.append("AND u.role_id = ? ");
            params.add(roleId);
        }
        if (locked != null) {
            sql.append("AND u.is_locked = ? ");
            params.add(locked ? 1 : 0);
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

    public int insert(AppUser u) {
        String sql = "INSERT INTO AppUser (username, pass_hash, full_name, email, phone, role_id, is_locked) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, u.getUsername());
            ps.setString(2, u.getPassHash());
            ps.setString(3, u.getFullName());
            ps.setString(4, u.getEmail());
            ps.setString(5, u.getPhone());
            ps.setInt(6, u.getRoleId());
            ps.setBoolean(7, u.isLocked());
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

    public boolean update(AppUser u) {
        String sql = "UPDATE AppUser SET full_name = ?, email = ?, phone = ?, role_id = ?, is_locked = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPhone());
            ps.setInt(4, u.getRoleId());
            ps.setBoolean(5, u.isLocked());
            ps.setInt(6, u.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean updatePassword(int userId, String newPassHash) {
        String sql = "UPDATE AppUser SET pass_hash = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newPassHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean setLock(int userId, boolean locked) {
        String sql = "UPDATE AppUser SET is_locked = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, locked);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean delete(int userId) {
        String sql = "DELETE FROM AppUser WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    private AppUser mapUser(ResultSet rs) throws SQLException {
        AppUser u = new AppUser();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setPassHash(rs.getString("pass_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setRoleId(rs.getInt("role_id"));
        u.setRoleCode(rs.getString("role_code"));
        u.setRoleName(rs.getString("role_name"));
        u.setLocked(rs.getBoolean("is_locked"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}
