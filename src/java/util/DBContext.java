package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * DBContext ket noi co so du lieu VendDB tren SQL Server.
 * Ho tro ket noi truc tiep cong 1433 hoac thong qua instance name PHAMSIMINH.
 */
public class DBContext {

    private static final String USER = "sa";
    private static final String PASS = "123456";

    // Danh sach URL du phong de dam bao chay duoc tren ca may thi lan may ca nhan
    private static final String[] CANDIDATE_URLS = new String[] {
        "jdbc:sqlserver://localhost:1433;databaseName=VendDB;encrypt=false",
        "jdbc:sqlserver://localhost\\PHAMSIMINH:1433;databaseName=VendDB;encrypt=false",
        "jdbc:sqlserver://127.0.0.1:1433;databaseName=VendDB;encrypt=false",
        "jdbc:sqlserver://localhost;instanceName=PHAMSIMINH;databaseName=VendDB;encrypt=false"
    };

    private static String workingUrl = null;

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Khong tim thay driver com.microsoft.sqlserver.jdbc.SQLServerDriver. Kiem tra sqljdbc4.jar trong lib.", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        if (workingUrl != null) {
            try {
                return DriverManager.getConnection(workingUrl, USER, PASS);
            } catch (SQLException ex) {
                // Neu url cu loi dot ngot, reset lai de tim lai
                workingUrl = null;
            }
        }

        SQLException lastEx = null;
        for (String url : CANDIDATE_URLS) {
            try {
                Connection conn = DriverManager.getConnection(url, USER, PASS);
                workingUrl = url;
                return conn;
            } catch (SQLException ex) {
                lastEx = ex;
            }
        }

        throw (lastEx != null) ? lastEx : new SQLException("Khong the ket noi toi CSDL VendDB tren bat ky URL nao.");
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
