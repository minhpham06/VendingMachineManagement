package controller;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import dao.VendSessionDAO;
import model.VendSession;

@WebServlet("/export")
public class ExportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final VendSessionDAO sessionDAO = new VendSessionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<VendSession> list = sessionDAO.getAllForExport();

        String fileName = "vend_sessions_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".csv";

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        OutputStream os = resp.getOutputStream();
        // Ghi UTF-8 BOM để Excel trên Windows tự động nhận diện tiếng Việt có dấu
        os.write(0xEF);
        os.write(0xBB);
        os.write(0xBF);

        PrintWriter writer = new PrintWriter(new OutputStreamWriter(os, StandardCharsets.UTF_8), true);

        // Header CSV
        writer.println("Session ID,Slot Code,Product Name,Nominal Weight (g),Tolerance (g),Device Seq,Coil Turns,Motor Time (ms),Weight Before (g),Weight After (g),Delta Weight (g),Peak Delta (g),Is Sample,Current Label,Label Source,Label Reason,Reviewer Name,Measured At");

        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        for (VendSession s : list) {
            StringBuilder sb = new StringBuilder();
            sb.append(s.getSessionId()).append(",");
            sb.append(escCsv(s.getSlotCode())).append(",");
            sb.append(escCsv(s.getProductName())).append(",");
            sb.append(s.getNominalWeight()).append(",");
            sb.append(s.getTolerance()).append(",");
            sb.append(s.getDeviceSeq()).append(",");
            sb.append(s.getCoilTurns()).append(",");
            sb.append(s.getMotorMs()).append(",");
            sb.append(s.getWeightBefore()).append(",");
            sb.append(s.getWeightAfter()).append(",");
            sb.append(String.format(Locale.US, "%.2f", s.getWeightDelta())).append(",");
            sb.append(s.getPeakDelta()).append(",");
            sb.append(s.isSample() ? "1" : "0").append(",");
            sb.append(escCsv(s.getCurrentLabel())).append(",");
            sb.append(escCsv(s.getLabelSource())).append(",");
            sb.append(escCsv(s.getLabelReason())).append(",");
            sb.append(escCsv(s.getReviewerName())).append(",");
            sb.append(s.getMeasuredAt() != null ? df.format(s.getMeasuredAt()) : "");
            writer.println(sb.toString());
        }

        writer.flush();
    }

    private String escCsv(String val) {
        if (val == null) return "";
        if (val.contains(",") || val.contains("\"") || val.contains("\n")) {
            return "\"" + val.replace("\"", "\"\"") + "\"";
        }
        return val;
    }
}
