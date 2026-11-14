package controller;

import dao.DeviceDAO;
import dao.VendAlertDAO;
import dao.VendLabelDAO;
import dao.VendProductDAO;
import dao.VendSessionDAO;
import dao.VendSlotDAO;
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
import model.Device;
import model.VendAlert;
import model.VendProduct;
import model.VendSession;
import model.VendSlot;
import util.DBContext;
import util.VendRuleEngine;
import util.WebUtil;

@WebServlet(name = "IngestServlet", urlPatterns = {"/api/ingest"})
public class IngestServlet extends HttpServlet {

    private final DeviceDAO deviceDAO = new DeviceDAO();
    private final VendSlotDAO slotDAO = new VendSlotDAO();
    private final VendProductDAO productDAO = new VendProductDAO();
    private final VendSessionDAO sessionDAO = new VendSessionDAO();
    private final VendLabelDAO labelDAO = new VendLabelDAO();
    private final VendAlertDAO alertDAO = new VendAlertDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processIngest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processIngest(request, response);
    }

    private void processIngest(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        PrintWriter out = resp.getWriter();

        // 1. Kiem tra X-API-Key
        String apiKey = req.getHeader("X-API-Key");
        if (apiKey == null || apiKey.trim().isEmpty()) {
            apiKey = req.getParameter("api_key");
        }

        Device device = deviceDAO.findByApiKey(apiKey);
        if (device == null || !"ACTIVE".equalsIgnoreCase(device.getStatus())) {
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

        // 3. Lay thong so san pham va tinh tong nominalWeight theo so turns
        int turns = (coilTurns > 0) ? coilTurns : 1;
        double nominalWeight = 25.0 * turns;
        double tolerance = 3.0 * turns;
        if (slot.getProductId() != null && slot.getProductId() > 0) {
            VendProduct prod = productDAO.findById(slot.getProductId());
            if (prod != null) {
                nominalWeight = prod.getNominalWeight() * turns;
                tolerance = prod.getTolerance() * turns;
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
            // Neu trung device_seq voi du lieu cu (vi du khi ESP32 khoi dong lai), tu dong tang len maxSeq + 1
            int nextSeq = sessionDAO.getMaxSeq(device.getDeviceId()) + 1;
            session.setDeviceSeq(nextSeq);
            newSessionId = sessionDAO.insertSession(session);
        }

        if (newSessionId <= 0) {
            resp.setStatus(HttpServletResponse.SC_CONFLICT);
            logRejected(device.getDeviceId(), "Duplicate packet seq_num=" + seqNum);
            out.print("{\"status\":\"ERROR\",\"message\":\"Duplicate packet or database insert failed\"}");
            return;
        }

        // 5. Phan loai nhan tu dong (danh gia thoi gian quay theo tung vong de tranh bao MOTOR_FAIL khi mua nhieu mon)
        boolean motorDone = (coilTurns >= 1);
        int timePerTurn = (turns > 0) ? (motorMs / turns) : motorMs;
        String labelCode = VendRuleEngine.classifySession(motorDone, timePerTurn, weightBefore, weightAfter, nominalWeight, tolerance);
        labelDAO.insertLabel(newSessionId, labelCode, "SYSTEM", null, "Auto-classified by VendRuleEngine");

        // Giam ton kho
        if (VendRuleEngine.LABEL_SUCCESS.equals(labelCode)) {
            slotDAO.updateStock(slot.getSlotId(), -turns);
        } else if (VendRuleEngine.LABEL_WRONG_ITEM.equals(labelCode)) {
            slotDAO.updateStock(slot.getSlotId(), -2);
        }

        // 6. Chay 4 Luat canh bao thong minh
        runAlertEngine(slot, newSessionId, labelCode, weightBefore, motorMs, turns);

        resp.setStatus(HttpServletResponse.SC_OK);
        out.print("{\"status\":\"OK\",\"session_id\":" + newSessionId + ",\"label\":\"" + labelCode + "\"}");
    }

    private void runAlertEngine(VendSlot slot, int sessionId, String labelCode, double weightBefore, int motorMs, int turns) {
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
                    alert.setMessage("Ranh " + slot.getCode() + " bi ket " + recentJams + " lan lien tiep. He thong da tu dong khoa ranh.");
                    triggerAlert(alert, slot);

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
                alert.setMessage("Ranh " + slot.getCode() + " chi con " + updatedSlot.getCurrentStock() + " san pham. Can nap them hang.");
                triggerAlert(alert, slot);
            }

            // Luat 3: Troi dat can nang (|weight_before| > 5g)
            if (Math.abs(weightBefore) > 5.0) {
                VendAlert alert = new VendAlert();
                alert.setSlotId(slot.getSlotId());
                alert.setSessionId(sessionId);
                alert.setRuleCode("WEIGHT_DRIFT");
                alert.setSeverity("WARNING");
                alert.setMessage("Cam bien khay co hien tuong troi dat khoi luong nghi (Weight Before = " + weightBefore + "g). Can kiem tra.");
                triggerAlert(alert, slot);
            }

            // Luat 4: Canh bao mon dong co (thoi gian quay moi vong > 3500ms)
            int checkMotorMs = (turns > 0) ? (motorMs / turns) : motorMs;
            if (checkMotorMs > 3500) {
                VendAlert alert = new VendAlert();
                alert.setSlotId(slot.getSlotId());
                alert.setSessionId(sessionId);
                alert.setRuleCode("MOTOR_WEAR");
                alert.setSeverity("WARNING");
                alert.setMessage("Thoi gian quay cua dong co ranh " + slot.getCode() + " tang bat thuong (" + checkMotorMs + "ms/vong). Can bao tri dong co.");
                triggerAlert(alert, slot);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private void triggerAlert(VendAlert alert, VendSlot slot) {
        alertDAO.insertAlert(alert);
        try {
            Device dev = (slot.getDeviceId() != null) ? deviceDAO.findById(slot.getDeviceId()) : null;
            String devCode = (dev != null && dev.getDeviceCode() != null) ? dev.getDeviceCode() : "Vend-01";
            String devName = (dev != null && dev.getMachineName() != null) ? dev.getMachineName() : "Main Machine";
            String loc = (dev != null && dev.getLocationName() != null) ? dev.getLocationName() : "Main Store Area";

            util.EmailService.sendAlertNotification(
                util.EmailService.DEFAULT_OPERATOR_EMAIL,
                util.EmailService.DEFAULT_OPERATOR_NAME,
                devCode,
                devName,
                loc,
                slot.getCode(),
                alert.getRuleCode(),
                alert.getSeverity(),
                alert.getMessage()
            );
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
        System.err.println("[REJECTED PACKET] Device: " + deviceId + " | Reason: " + reason);
    }
}