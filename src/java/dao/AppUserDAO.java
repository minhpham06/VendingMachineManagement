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
     * Kiem tra dang nhap.
     * Tra ve AppUser neu thanh cong.
     * Neu sai mat khau hoac khong tim thay: tra ve null.
     */
    public AppUser authenticate(String username, String plainPassword) {
        AppUser user = findByUsername(username);
        if (user == null) {
            return null;
        }
        if (PasswordUtil.verify(plainPassword, user.getPassHash())) {
            return user;
        }
        return null;
    }

    public List<AppUser> searchUsers(String query, Integer roleId, Boolean locked, int page, int pageSize) {
        List<AppUser> list = new ArrayList<AppUser>();
        StringBuilder sql = new StringBuilder(SELECT_BASE).append("WHERE 1 = 1 ");

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (u.username LIKE ? OR u.full_name LIKE ? OR u.email LIKE ?) ");
        }
        if (roleId != null && roleId > 0) {
            sql.append("AND u.role_id = ? ");
        }
        if (locked != null) {
            sql.append("AND u.is_locked = ? ");
        }

        sql.append("ORDER BY u.user_id ASC ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (query != null && !query.trim().isEmpty()) {
                String pattern = "%" + query.trim() + "%";
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
            }
            if (roleId != null && roleId > 0) {
                ps.setInt(idx++, roleId);
            }
            if (locked != null) {
                ps.setBoolean(idx++, locked);
            }
            ps.setInt(idx++, (Math.max(1, page) - 1) * pageSize);
            ps.setInt(idx++, pageSize);

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

    public int countUsers(String query, Integer roleId, Boolean locked) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM AppUser u WHERE 1 = 1 ");

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (u.username LIKE ? OR u.full_name LIKE ? OR u.email LIKE ?) ");
        }
        if (roleId != null && roleId > 0) {
            sql.append("AND u.role_id = ? ");
        }
        if (locked != null) {
            sql.append("AND u.is_locked = ? ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (query != null && !query.trim().isEmpty()) {
                String pattern = "%" + query.trim() + "%";
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
            }
            if (roleId != null && roleId > 0) {
                ps.setInt(idx++, roleId);
            }
            if (locked != null) {
                ps.setBoolean(idx++, locked);
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

    public boolean isUsernameExists(String username, Integer excludeUserId) {
        String sql = "SELECT user_id FROM AppUser WHERE username = ?";
        if (excludeUserId != null) {
            sql += " AND user_id <> ?";
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username.trim());
            if (excludeUserId != null) {
                ps.setInt(2, excludeUserId);
            }
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return false;
    }

    public int insert(AppUser u, String plainPassword) {
        String sql = "INSERT INTO AppUser(username, pass_hash, full_name, email, phone, role_id, is_locked) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, u.getUsername().trim());
            ps.setString(2, PasswordUtil.hash(plainPassword));
            ps.setString(3, u.getFullName().trim());
            ps.setString(4, u.getEmail() != null ? u.getEmail().trim() : null);
            ps.setString(5, u.getPhone() != null ? u.getPhone().trim() : null);
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
        return -1;
    }

    public boolean update(AppUser u) {
        String sql = "UPDATE AppUser SET full_name = ?, email = ?, phone = ?, role_id = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, u.getFullName().trim());
            ps.setString(2, u.getEmail() != null ? u.getEmail().trim() : null);
            ps.setString(3, u.getPhone() != null ? u.getPhone().trim() : null);
            ps.setInt(4, u.getRoleId());
            ps.setInt(5, u.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(ps, conn);
        }
        return false;
    }

    public boolean toggleLock(int userId, boolean locked) {
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
        } finally {
            DBContext.close(ps, conn);
        }
        return false;
    }

    public boolean resetPassword(int userId, String defaultPlainPassword) {
        String sql = "UPDATE AppUser SET pass_hash = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, PasswordUtil.hash(defaultPlainPassword));
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(ps, conn);
        }
        return false;
    }

    public boolean changePassword(int userId, String oldPlainPassword, String newPlainPassword) {
        AppUser u = findById(userId);
        if (u == null) return false;
        if (!PasswordUtil.verify(oldPlainPassword, u.getPassHash())) {
            return false;
        }
        return resetPassword(userId, newPlainPassword);
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
        } finally {
            DBContext.close(ps, conn);
        }
        return false;
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
