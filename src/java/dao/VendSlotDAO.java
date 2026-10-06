package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.VendSlot;
import util.DBContext;

public class VendSlotDAO {

    private static final String SELECT_BASE =
        "SELECT s.slot_id, s.code, s.name, s.product_id, " +
        "p.name AS product_name, p.nominal_weight, p.tolerance, p.price, " +
        "s.capacity, s.current_stock, s.is_suspended, s.note, s.is_active, s.created_at " +
        "FROM Vend_Slot s " +
        "LEFT JOIN Vend_Product p ON s.product_id = p.product_id ";

    public List<VendSlot> getAllSlots() {
        List<VendSlot> list = new ArrayList<VendSlot>();
        String sql = SELECT_BASE + "ORDER BY s.slot_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapSlot(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public VendSlot findById(int slotId) {
        String sql = SELECT_BASE + "WHERE s.slot_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, slotId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapSlot(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public VendSlot findByCode(String slotCode) {
        String sql = SELECT_BASE + "WHERE s.code = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, slotCode);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapSlot(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return null;
    }

    public boolean update(int slotId, Integer productId, int capacity, int currentStock, boolean isSuspended) {
        String sql = "UPDATE Vend_Slot SET product_id = ?, capacity = ?, current_stock = ?, is_suspended = ? WHERE slot_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            if (productId != null && productId > 0) {
                ps.setInt(1, productId);
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setInt(2, capacity);
            ps.setInt(3, currentStock);
            ps.setBoolean(4, isSuspended);
            ps.setInt(5, slotId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean updateStock(int slotId, int deltaQty) {
        String sql = "UPDATE Vend_Slot SET current_stock = CASE WHEN (current_stock + ?) < 0 THEN 0 ELSE (current_stock + ?) END WHERE slot_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, deltaQty);
            ps.setInt(2, deltaQty);
            ps.setInt(3, slotId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    public boolean setSuspended(int slotId, boolean isSuspended) {
        String sql = "UPDATE Vend_Slot SET is_suspended = ? WHERE slot_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, isSuspended);
            ps.setInt(2, slotId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            DBContext.close(null, ps, conn);
        }
    }

    private VendSlot mapSlot(ResultSet rs) throws SQLException {
        VendSlot s = new VendSlot();
        s.setSlotId(rs.getInt("slot_id"));
        s.setCode(rs.getString("code"));
        s.setName(rs.getString("name"));
        int pId = rs.getInt("product_id");
        if (!rs.wasNull()) {
            s.setProductId(pId);
            s.setProductName(rs.getString("product_name"));
            s.setNominalWeight(rs.getDouble("nominal_weight"));
            s.setTolerance(rs.getDouble("tolerance"));
            s.setPrice(rs.getDouble("price"));
        }
        s.setCapacity(rs.getInt("capacity"));
        s.setCurrentStock(rs.getInt("current_stock"));
        s.setSuspended(rs.getBoolean("is_suspended"));
        s.setNote(rs.getString("note"));
        s.setActive(rs.getBoolean("is_active"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        return s;
    }
}
