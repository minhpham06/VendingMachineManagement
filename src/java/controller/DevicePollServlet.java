package controller;

import dao.DeviceDAO;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Device;
import util.DispenseManager;

@WebServlet(name = "DevicePollServlet", urlPatterns = {"/api/device/poll"})
public class DevicePollServlet extends HttpServlet {

    private final DeviceDAO deviceDAO = new DeviceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processPoll(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processPoll(request, response);
    }

    private void processPoll(HttpServletRequest req, HttpServletResponse resp)
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
            out.print("{\"status\":\"ERROR\",\"message\":\"Invalid or unauthorized API Key\"}");
            return;
        }

        // 2. Lay lenh tra hang tu hang doi
        DispenseManager.DispenseCommand cmd = DispenseManager.pollCommand();
        if (cmd != null) {
            int turns = cmd.getTurns() > 0 ? cmd.getTurns() : 1;
            int timeoutMs = turns * 4000;
            resp.setStatus(HttpServletResponse.SC_OK);
            out.print(String.format(
                "{\"status\":\"DISPENSE\",\"order_id\":\"%s\",\"slot_code\":\"%s\",\"turns\":%d,\"timeout_ms\":%d}",
                cmd.getOrderId() != null ? cmd.getOrderId() : "",
                cmd.getSlotCode(),
                turns,
                timeoutMs
            ));
        } else {
            resp.setStatus(HttpServletResponse.SC_OK);
            out.print("{\"status\":\"IDLE\"}");
        }
    }
}