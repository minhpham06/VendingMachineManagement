package util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Random;

/**
 * Script tự động khởi tạo và nạp dữ liệu mẫu 240 phiên thực nghiệm chuẩn UTF-8 vào VendDB.
 */
public class DatabaseSeeder {

    public static void main(String[] args) {
        System.out.println("====== BAT DAU SEED DU LIEU CHO VENDDB ======");
        Connection conn = null;
        try {
            conn = DBContext.getConnection();

            // 1. Kiem tra va cap nhat mat khau chuan PBKDF2 cho 5 user
            String passHash = PasswordUtil.hash("123456");
            String sqlPass = "UPDATE AppUser SET pass_hash = ? WHERE username IN ('admin', 'catalog_manager', 'operator', 'reviewer', 'viewer')";
            PreparedStatement psPass = conn.prepareStatement(sqlPass);
            psPass.setString(1, passHash);
            int updatedUsers = psPass.executeUpdate();
            psPass.close();
            System.out.println("[OK] Da cap nhat mat khau '123456' PBKDF2 cho " + updatedUsers + " tai khoan.");

            // 2. Kiem tra so luong phien hien tai
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM Vend_Session");
            int curSessions = 0;
            if (rs.next()) curSessions = rs.getInt(1);
            rs.close();

            if (curSessions >= 240) {
                System.out.println("[INFO] CSDL da co san " + curSessions + " phien do. Khong can seed them.");
            } else {
                System.out.println("[INFO] Dang sinh 240 phien du lieu mau chuan de tai...");
                Random rnd = new Random(42); // Co dinh seed de ket qua on dinh
                int seq = 1;

                String sqlInsertSession =
                    "INSERT INTO Vend_Session (device_id, slot_id, seq_num, motor_done, rotation_time_ms, " +
                    "weight_before_g, weight_peak_g, weight_after_g, ambient_temp_c, is_sample) " +
                    "VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?, 1)";
                PreparedStatement psSession = conn.prepareStatement(sqlInsertSession, Statement.RETURN_GENERATED_KEYS);

                String sqlInsertLabel =
                    "INSERT INTO Vend_Label (session_id, label_code, source, reason) VALUES (?, ?, 'SYSTEM', 'Auto-generated sample session')";
                PreparedStatement psLabel = conn.prepareStatement(sqlInsertLabel);

                // --- A. 120 phien SUCCESS (Slot 1 & 2) ---
                for (int i = 0; i < 120; i++) {
                    int slotId = (i % 2 == 0) ? 1 : 2;
                    double nominal = (slotId == 1) ? 25.0 : 18.0;
                    int rotTime = 1800 + rnd.nextInt(400); // 1800 - 2200ms
                    double wBefore = (rnd.nextDouble() * 2.0) - 1.0; // -1.0g den 1.0g
                    double deltaW = nominal + (rnd.nextDouble() * 2.0 - 1.0); // nominal +/- 1g
                    double wPeak = wBefore + deltaW + 10.0 + rnd.nextDouble() * 5.0; // xung luc roi
                    double wAfter = wBefore + deltaW;
                    double temp = 26.0 + rnd.nextDouble() * 4.0;

                    insertSessionWithLabel(psSession, psLabel, slotId, seq++, true, rotTime, wBefore, wPeak, wAfter, temp, "SUCCESS");
                }

                // --- B. 40 phien JAM (Khong roi hang) ---
                for (int i = 0; i < 40; i++) {
                    int slotId = (i % 2 == 0) ? 1 : 2;
                    int rotTime = 1900 + rnd.nextInt(500);
                    double wBefore = (rnd.nextDouble() * 2.0) - 1.0;
                    double deltaW = (rnd.nextDouble() * 0.4) - 0.2; // ~ 0g
                    double wPeak = wBefore + 0.5;
                    double wAfter = wBefore + deltaW;
                    double temp = 27.0 + rnd.nextDouble() * 3.0;

                    insertSessionWithLabel(psSession, psLabel, slotId, seq++, true, rotTime, wBefore, wPeak, wAfter, temp, "JAM");
                }

                // --- C. 50 phien WRONG_ITEM (Roi 2 mon / sai mon) ---
                for (int i = 0; i < 50; i++) {
                    int slotId = (i % 2 == 0) ? 1 : 2;
                    double nominal = (slotId == 1) ? 25.0 : 18.0;
                    int rotTime = 2000 + rnd.nextInt(400);
                    double wBefore = (rnd.nextDouble() * 2.0) - 1.0;
                    double deltaW = (nominal * 2.0) + (rnd.nextDouble() * 4.0 - 2.0); // Roi 2 mon ~ 50g
                    double wPeak = wBefore + deltaW + 15.0;
                    double wAfter = wBefore + deltaW;
                    double temp = 26.5 + rnd.nextDouble() * 3.5;

                    insertSessionWithLabel(psSession, psLabel, slotId, seq++, true, rotTime, wBefore, wPeak, wAfter, temp, "WRONG_ITEM");
                }

                // --- D. 30 phien MOTOR_FAIL (Motor khong quay du vong) ---
                for (int i = 0; i < 30; i++) {
                    int slotId = (i % 2 == 0) ? 1 : 2;
                    int rotTime = 4200 + rnd.nextInt(800); // Vuot nguong 4000ms
                    double wBefore = (rnd.nextDouble() * 2.0) - 1.0;
                    double deltaW = 0.0;
                    double wPeak = wBefore;
                    double wAfter = wBefore;
                    double temp = 28.0 + rnd.nextDouble() * 2.0;

                    insertSessionWithLabel(psSession, psLabel, slotId, seq++, false, rotTime, wBefore, wPeak, wAfter, temp, "MOTOR_FAIL");
                }

                psSession.close();
                psLabel.close();
                System.out.println("[OK] Da sinh thanh cong 240 phien do mau (120 SUCCESS, 40 JAM, 50 WRONG_ITEM, 30 MOTOR_FAIL).");
            }

            // 3. Them 2 canh bao mau neu chua co
            rs = st.executeQuery("SELECT COUNT(*) FROM Vend_Alert");
            int curAlerts = 0;
            if (rs.next()) curAlerts = rs.getInt(1);
            rs.close();

            if (curAlerts == 0) {
                st.executeUpdate(
                    "INSERT INTO Vend_Alert (device_id, slot_id, alert_type, severity, message, is_resolved) VALUES " +
                    "(1, 1, 'JAM_STREAK', 'CRITICAL', N'Rãnh SLOT-01 có dấu hiệu kẹt hàng liên tiếp. Vui lòng kiểm tra khay nhận.', 0), " +
                    "(1, 2, 'LOW_STOCK', 'WARNING', N'Rãnh SLOT-02 sắp hết hàng (còn dưới 3 gói). Cần nạp bổ sung.', 0)"
                );
                System.out.println("[OK] Da tao 2 canh bao mau trong Vend_Alert.");
            }
            st.close();

            System.out.println("====== HOAN TAT SEED DU LIEU VENDDB! ======");
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(null, null, conn);
        }
    }

    private static void insertSessionWithLabel(PreparedStatement psSession, PreparedStatement psLabel,
                                              int slotId, int seq, boolean motorDone, int rotTime,
                                              double wBefore, double wPeak, double wAfter, double temp,
                                              String labelCode) throws Exception {
        psSession.setInt(1, slotId);
        psSession.setInt(2, seq);
        psSession.setBoolean(3, motorDone);
        psSession.setInt(4, rotTime);
        psSession.setDouble(5, wBefore);
        psSession.setDouble(6, wPeak);
        psSession.setDouble(7, wAfter);
        psSession.setDouble(8, temp);
        psSession.executeUpdate();

        ResultSet rs = psSession.getGeneratedKeys();
        if (rs.next()) {
            int sessionId = rs.getInt(1);
            psLabel.setInt(1, sessionId);
            psLabel.setString(2, labelCode);
            psLabel.executeUpdate();
        }
        rs.close();
    }
}
