package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.VendProduct;
import util.DBContext;

public class VendProductDAO {

    public List<VendProduct> getAllProducts(Boolean onlyActive) {
        List<VendProduct> list = new ArrayList<VendProduct>();
        StringBuilder sql = new StringBuilder("SELECT product_id, code, name, nominal_weight, tolerance, price, note, is_active, created_at FROM Vend_Product ");
        if (Boolean.TRUE.equals(onlyActive)) {
            sql.append("WHERE is_active = 1 ");
        }
        sql.append("ORDER BY product_id ASC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql.toString());
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public VendProduct findById(int id) {
        String sql = "SELECT product_id, code, name, nominal_weight, tolerance, price, note, is_active, created_at FROM Vend_Product WHERE product_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapProduct(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public int insert(VendProduct p) {
        String sql = "INSERT INTO Vend_Product (code, name, nominal_weight, tolerance, price, note, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, p.getCode());
            ps.setString(2, p.getName());
            ps.setDouble(3, p.getNominalWeight());
            ps.setDouble(4, p.getTolerance());
            ps.setDouble(5, p.getPrice());
            ps.setString(6, p.getNote());
            ps.setBoolean(7, p.isActive());
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

    public boolean update(VendProduct p) {
        String sql = "UPDATE Vend_Product SET code = ?, name = ?, nominal_weight = ?, tolerance = ?, price = ?, note = ?, is_active = ? WHERE product_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, p.getCode());
            ps.setString(2, p.getName());
            ps.setDouble(3, p.getNominalWeight());
            ps.setDouble(4, p.getTolerance());
            ps.setDouble(5, p.getPrice());
            ps.setString(6, p.getNote());
            ps.setBoolean(7, p.isActive());
            ps.setInt(8, p.getProductId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM Vend_Product WHERE product_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    private VendProduct mapProduct(ResultSet rs) throws SQLException {
        VendProduct p = new VendProduct();
        p.setProductId(rs.getInt("product_id"));
        p.setCode(rs.getString("code"));
        p.setName(rs.getString("name"));
        p.setNominalWeight(rs.getDouble("nominal_weight"));
        p.setTolerance(rs.getDouble("tolerance"));
        p.setPrice(rs.getDouble("price"));
        p.setNote(rs.getString("note"));
        p.setActive(rs.getBoolean("is_active"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }
}
