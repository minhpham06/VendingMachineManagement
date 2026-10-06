package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.VendRestock;
import util.DBContext;

public class VendRestockDAO {

    public List<VendRestock> getAllRestocks() {
        List<VendRestock> list = new ArrayList<VendRestock>();
        String sql = "SELECT r.restock_id, r.code, r.slot_id, s.code AS slot_code, r.product_id, " +
                     "p.name AS product_name, r.quantity, r.restocked_by, u.full_name AS restocked_by_name, " +
                     "r.note, r.is_active, r.created_at " +
                     "FROM Vend_Restock r " +
                     "JOIN Vend_Slot s ON r.slot_id = s.slot_id " +
                     "LEFT JOIN Vend_Product p ON r.product_id = p.product_id " +
                     "JOIN AppUser u ON r.restocked_by = u.user_id " +
                     "ORDER BY r.restock_id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRestock(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return list;
    }

    public boolean insertRestock(int slotId, Integer productId, int quantity, int operatorId, String note) {
        String code = "RST-" + System.currentTimeMillis() % 1000000;
        String sqlInsert = "INSERT INTO Vend_Restock (code, slot_id, product_id, quantity, restocked_by, note, is_active) VALUES (?, ?, ?, ?, ?, ?, 1)";
        String sqlUpdateSlot = "UPDATE Vend_Slot SET current_stock = current_stock + ? WHERE slot_id = ?";
        Connection conn = null;
        PreparedStatement psInsert = null;
        PreparedStatement psUpdate = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            psInsert = conn.prepareStatement(sqlInsert);
            psInsert.setString(1, code);
            psInsert.setInt(2, slotId);
            if (productId != null && productId > 0) {
                psInsert.setInt(3, productId);
            } else {
                psInsert.setNull(3, java.sql.Types.INTEGER);
            }
            psInsert.setInt(4, quantity);
            psInsert.setInt(5, operatorId);
            psInsert.setString(6, note);
            psInsert.executeUpdate();

            psUpdate = conn.prepareStatement(sqlUpdateSlot);
            psUpdate.setInt(1, quantity);
            psUpdate.setInt(2, slotId);
            psUpdate.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException ex) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            ex.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
            }
            if (psInsert != null) try { psInsert.close(); } catch (SQLException ignored) {}
            if (psUpdate != null) try { psUpdate.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    private VendRestock mapRestock(ResultSet rs) throws SQLException {
        VendRestock r = new VendRestock();
        r.setRestockId(rs.getInt("restock_id"));
        r.setCode(rs.getString("code"));
        r.setSlotId(rs.getInt("slot_id"));
        r.setSlotCode(rs.getString("slot_code"));
        int pId = rs.getInt("product_id");
        if (!rs.wasNull()) {
            r.setProductId(pId);
            r.setProductName(rs.getString("product_name"));
        }
        r.setQuantity(rs.getInt("quantity"));
        r.setRestockedBy(rs.getInt("restocked_by"));
        r.setRestockedByName(rs.getString("restocked_by_name"));
        r.setNote(rs.getString("note"));
        r.setActive(rs.getBoolean("is_active"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }
}
