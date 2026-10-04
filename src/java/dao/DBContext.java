package dao;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * Bridge class tro toi util.DBContext de dam bao tuong thich ma nguon.
 */
public class DBContext {

    public static Connection getConnection() throws SQLException {
        return util.DBContext.getConnection();
    }

    public static void close(java.sql.ResultSet rs, java.sql.Statement st, Connection cn) {
        util.DBContext.close(rs, st, cn);
    }

    public static void close(java.sql.PreparedStatement ps, Connection cn) {
        util.DBContext.close(ps, cn);
    }
}
