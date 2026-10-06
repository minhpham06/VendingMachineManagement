package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Ket noi CSDL SQL Server (VendDB).
 * Su dung sqljdbc4.jar
 */
public class DBContext {

    private static final String URL =
        "jdbc:sqlserver://localhost:1433;databaseName=VendDB;encrypt=false";
    private static final String USER = "sa";
    private static final String PASS = "123456";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("sqljdbc4.jar is missing from project libraries", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    public static void close(ResultSet rs, Statement st, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) { }
        try { if (st != null) st.close(); } catch (SQLException ignored) { }
        try { if (cn != null) cn.close(); } catch (SQLException ignored) { }
    }

    public static void close(PreparedStatement ps, Connection cn) {
        close(null, ps, cn);
    }
}
