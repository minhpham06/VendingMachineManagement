package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.DeviceDAO;
import dao.VendAlertDAO;
import dao.VendLabelDAO;
import dao.VendProductDAO;
import dao.VendSessionDAO;
import dao.VendSlotDAO;
import model.Device;
import model.VendAlert;
import model.VendProduct;
import model.VendSession;
import model.VendSlot;
import util.DBContext;
import util.VendRuleEngine;
import util.WebUtil;

@WebServlet("/api/ingest")
public class IngestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final DeviceDAO deviceDAO = new DeviceDAO();
    private final VendSlotDAO slotDAO = new VendSlotDAO();
    private final VendProductDAO productDAO = new VendProductDAO();
    private final VendSessionDAO sessionDAO = new VendSessionDAO();
    private final VendLabelDAO labelDAO = new VendLabelDAO();
    private final VendAlertDAO alertDAO = new VendAlertDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        // 1. Kiem tra X-API-Key
        String apiKey = req.getHeader("X-API-Key");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            apiKey = req.getParameter("api_key");
        }

        Device device = deviceDAO.findByApiKey(apiKey);
        if (device == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            logRejected(null, "Invalid or missing X-API-Key: " + apiKey);
            out.print("{\"status\":\"ERROR\",\"message\":\"Invalid API Key\"}");
            return;
        }

        // 2. Parse tham so
        String slotCode = req.getParameter("slot_code");
        int slotId = WebUtil.parseInt(req.getParameter("slot_id"), 0);
        int seqNum = WebUtil.parseInt(req.getParameter("seq_num"), -1);
        int coilTurns = WebUtil.parseInt(req.getParameter("coil_turns"), 1);
        int motorMs = WebUtil.parseInt(req.getParameter("motor_ms"), 0);
        int settleMs = WebUtil.parseInt(req.getParameter("settle_ms"), 0);
        double weightBefore = WebUtil.parseDouble(req.getParameter("weight_before"), 0.0);
        double weightAfter = WebUtil.parseDouble(req.getParameter("weight_after"), 0.0);
        double weightDelta = WebUtil.parseDouble(req.getParameter("weight_delta"), weightAfter - weightBefore);
        double peakDelta = WebUtil.parseDouble(req.getParameter("peak_delta"), weightDelta + 10.0);

        VendSlot slot = null;
        if (slotId > 0) {
            slot = slotDAO.findById(slotId);
        } else if (slotCode != null && !slotCode.isEmpty()) {
            slot = slotDAO.findByCode(slotCode.trim());
        }

        if (slot == null || seqNum < 0) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            logRejected(device.getDeviceId(), "Invalid slot or seq_num. seq_num=" + seqNum);
            out.print("{\"status\":\"ERROR\",\"message\":\"Invalid slot or sequence number\"}");
            return;
        }

        // 3. Lay thong so san pham
        double nominalWeight = 25.0;
        double tolerance = 3.0;
        if (slot.getProductId() != null && slot.getProductId() > 0) {
            VendProduct prod = productDAO.findById(slot.getProductId());
            if (prod != null) {
                nominalWeight = prod.getNominalWeight();
                tolerance = prod.getTolerance();
            }
        }

        // 4. Luu Session
        VendSession session = new VendSession();
        session.setDeviceId(device.getDeviceId());
        session.setSlotId(slot.getSlotId());
        session.setDeviceSeq(seqNum);
        session.setWeightBefore(weightBefore);
        session.setWeightAfter(weightAfter);
        session.setWeightDelta(weightDelta);
        session.setCoilTurns(coilTurns);
        session.setMotorMs(motorMs);
        session.setSettleMs(settleMs);
        session.setPeakDelta(peakDelta);
        session.setSample(false);

        int newSessionId = sessionDAO.insertSession(session);
        if (newSessionId <= 0) {
            resp.setStatus(HttpServletResponse.SC_CONFLICT);
            logRejected(device.getDeviceId(), "Duplicate packet seq_num=" + seqNum);
            out.print("{\"status\":\"ERROR\",\"message\":\"Duplicate packet or database insert failed\"}");
            return;
        }

        // 5. Phan loai nhan tu dong
        boolean motorDone = (coilTurns >= 1);
        String labelCode = VendRuleEngine.classifySession(motorDone, motorMs, weightBefore, weightAfter, nominalWeight, tolerance);
        labelDAO.insertLabel(newSessionId, labelCode, "SYSTEM", null, "Auto-classified by VendRuleEngine");

        // Giam ton kho
        if (VendRuleEngine.LABEL_SUCCESS.equals(labelCode)) {
            slotDAO.updateStock(slot.getSlotId(), -1);
        } else if (VendRuleEngine.LABEL_WRONG_ITEM.equals(labelCode)) {
            slotDAO.updateStock(slot.getSlotId(), -2);
        }

        // 6. Chay 4 Luat canh bao thong minh
        runAlertEngine(slot, newSessionId, labelCode, weightBefore, motorMs);

        resp.setStatus(HttpServletResponse.SC_OK);
        out.print("{\"status\":\"OK\",\"session_id\":" + newSessionId + ",\"label\":\"" + labelCode + "\"}");
    }

    private void runAlertEngine(VendSlot slot, int sessionId, String labelCode, double weightBefore, int motorMs) {
        try {
            // Luat 1: Ket hang lien tiep (JAM Streak >= 2)
            if (VendRuleEngine.LABEL_JAM.equals(labelCode)) {
                int recentJams = countConsecutiveJams(slot.getSlotId());
                if (recentJams >= 2) {
                    VendAlert alert = new VendAlert();
                    alert.setSlotId(slot.getSlotId());
                    alert.setSessionId(sessionId);
                    alert.setRuleCode("JAM_STREAK");
                    alert.setSeverity("CRITICAL");
                    alert.setMessage("Rãnh " + slot.getCode() + " bị kẹt " + recentJams + " lần liên tiếp. Hệ thống đã tự động khóa rãnh.");
                    alertDAO.insertAlert(alert);

                    // Tu dong khoa ranh
                    slotDAO.setSuspended(slot.getSlotId(), true);
                }
            }

            // Luat 2: Canh bao sap het hang (current_stock <= 2)
            VendSlot updatedSlot = slotDAO.findById(slot.getSlotId());
            if (updatedSlot != null && updatedSlot.getCurrentStock() <= 2) {
                VendAlert alert = new VendAlert();
                alert.setSlotId(slot.getSlotId());
                alert.setSessionId(sessionId);
                alert.setRuleCode("LOW_STOCK");
                alert.setSeverity("WARNING");
                alert.setMessage("Rãnh " + slot.getCode() + " chỉ còn " + updatedSlot.getCurrentStock() + " sản phẩm. Cần nạp thêm hàng.");
                alertDAO.insertAlert(alert);
            }

            // Luat 3: Troi dat can nang (|weight_before| > 5g)
            if (Math.abs(weightBefore) > 5.0) {
                VendAlert alert = new VendAlert();
                alert.setSlotId(slot.getSlotId());
                alert.setSessionId(sessionId);
                alert.setRuleCode("WEIGHT_DRIFT");
                alert.setSeverity("WARNING");
                alert.setMessage("Cảm biến khay có hiện tượng trôi dạt khối lượng nghỉ (Weight Before = " + weightBefore + "g). Cần kiểm tra.");
                alertDAO.insertAlert(alert);
            }

            // Luat 4: Canh bao mon dong co (motor_ms > 3500ms)
            if (motorMs > 3500) {
                VendAlert alert = new VendAlert();
                alert.setSlotId(slot.getSlotId());
                alert.setSessionId(sessionId);
                alert.setRuleCode("MOTOR_WEAR");
                alert.setSeverity("WARNING");
                alert.setMessage("Thời gian quay của động cơ rãnh " + slot.getCode() + " tăng bất thường (" + motorMs + "ms). Cần bảo trì động cơ.");
                alertDAO.insertAlert(alert);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private int countConsecutiveJams(int slotId) {
        String sql = "SELECT TOP 2 l.label_code FROM Vend_Session s " +
                     "JOIN Vend_Label l ON l.label_id = (SELECT TOP 1 l2.label_id FROM Vend_Label l2 WHERE l2.session_id = s.session_id ORDER BY l2.label_id DESC) " +
                     "WHERE s.slot_id = ? ORDER BY s.session_id DESC";
        int jamCount = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, slotId);
            rs = ps.executeQuery();
            while (rs.next()) {
                if ("JAM".equalsIgnoreCase(rs.getString("label_code"))) {
                    jamCount++;
                } else {
                    break;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            DBContext.close(rs, ps, conn);
        }
        return jamCount;
    }

    private void logRejected(Integer deviceId, String reason) {
        // Log rejected
        System.err.println("[REJECTED PACKET] Device: " + deviceId + " | Reason: " + reason);
    }
}
