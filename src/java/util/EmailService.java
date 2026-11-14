package util;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;
import java.util.concurrent.CompletableFuture;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.Multipart;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

public class EmailService {

    // Cấu hình SMTP Gmail theo thông tin được cung cấp
    public static final String SMTP_HOST = "smtp.gmail.com";
    public static final String SMTP_PORT = "587";
    public static final String SENDER_EMAIL = "phamsiminh101206@gmail.com";
    public static final String SENDER_APP_PASSWORD = "vuanhzhhkdwapkcr"; // App password 16 ký tự không dấu cách
    public static final String SENDER_NAME = "VendDB Alert Engine";

    // Email nhận mặc định của nhân viên Lê Vận Hành
    public static final String DEFAULT_OPERATOR_EMAIL = "duongthethinhforwork@gmail.com";
    public static final String DEFAULT_OPERATOR_NAME = "Duong The Thinh";

    private static Session getMailSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.mime.charset", "UTF-8");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_APP_PASSWORD);
            }
        });
    }

    /**
     * Gửi HTML Email chạy ngầm (Asynchronous) đảm bảo 100% chuẩn mã hóa tiếng Việt UTF-8
     */
    public static void sendHtmlEmailAsync(final String toEmail, final String subject, final String htmlBody) {
        CompletableFuture.runAsync(() -> {
            try {
                String targetEmail = (toEmail != null && !toEmail.trim().isEmpty()) ? toEmail.trim() : DEFAULT_OPERATOR_EMAIL;
                Session session = getMailSession();
                MimeMessage message = new MimeMessage(session);

                message.setFrom(new InternetAddress(SENDER_EMAIL, SENDER_NAME, "UTF-8"));
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(targetEmail));
                message.setSubject(subject, "UTF-8");

                // Thiết lập chuẩn MIME HTML UTF-8 kèm Quoted-Printable (chống lỗi font ? và chống bị Gmail phân loại vào Spam)
                message.setContent(htmlBody, "text/html; charset=UTF-8");
                message.setHeader("Content-Type", "text/html; charset=UTF-8");
                message.setHeader("Content-Transfer-Encoding", "quoted-printable");
                message.saveChanges();

                Transport.send(message);
                System.out.println("[EMAIL SUCCESS] Sent to " + targetEmail + " | Subject: " + subject);
            } catch (Throwable ex) {
                System.err.println("[EMAIL ERROR] Failed to send email to " + toEmail + ": " + ex.getMessage());
                ex.printStackTrace();
            }
        });
    }

    /**
     * Gửi email cảnh báo sự cố máy bán hàng cho nhân viên vận hành
     */
    public static void sendAlertNotification(String staffEmail, String staffName, 
                                             String machineCode, String machineName, String location,
                                             String slotCode, String ruleCode, String severity, String alertMessage) {
        String recipient = (staffEmail != null && !staffEmail.trim().isEmpty()) ? staffEmail : DEFAULT_OPERATOR_EMAIL;
        String name = (staffName != null && !staffName.trim().isEmpty()) ? staffName : DEFAULT_OPERATOR_NAME;
        String machine = (machineCode != null ? machineCode : "Vend-01") + (machineName != null ? " (" + machineName + ")" : "");
        String loc = (location != null && !location.trim().isEmpty()) ? location : "Main Store Area";
        String slot = (slotCode != null && !slotCode.trim().isEmpty()) ? slotCode : "N/A";

        String subject = "[VENDDB ALERT] " + severity + " Issue Detected: " + machineCode + " - Slot " + slot;
        String html = buildAlertEmailHtml(name, machine, loc, slot, ruleCode, severity, alertMessage);

        sendHtmlEmailAsync(recipient, subject, html);
    }

    /**
     * Gửi email xác nhận sự cố đã được xử lý thành công
     */
    public static void sendResolutionNotification(String staffEmail, String staffName,
                                                  int alertId, String machineCode, String machineName,
                                                  String slotCode, String ruleCode, String handlerName, 
                                                  String handledNote, boolean slotUnlocked) {
        String recipient = (staffEmail != null && !staffEmail.trim().isEmpty()) ? staffEmail : DEFAULT_OPERATOR_EMAIL;
        String name = (staffName != null && !staffName.trim().isEmpty()) ? staffName : DEFAULT_OPERATOR_NAME;
        String machine = (machineCode != null ? machineCode : "Vend-01") + (machineName != null ? " (" + machineName + ")" : "");
        String slot = (slotCode != null && !slotCode.trim().isEmpty()) ? slotCode : "N/A";
        String handler = (handlerName != null && !handlerName.trim().isEmpty()) ? handlerName : "Maintenance Staff";
        String note = (handledNote != null && !handledNote.trim().isEmpty()) ? handledNote : "Inspection completed and verified operational.";

        String subject = "[VENDDB RESOLVED] Incident #" + alertId + " at " + machineCode + " Has Been Resolved";
        String html = buildResolutionEmailHtml(name, alertId, machine, slot, ruleCode, handler, note, slotUnlocked);

        sendHtmlEmailAsync(recipient, subject, html);
    }

    /**
     * Mẫu Email Cảnh báo sự cố (Alert HTML Template)
     */
    private static String buildAlertEmailHtml(String staffName, String machine, String location, 
                                              String slot, String ruleCode, String severity, String message) {
        String headerColor = "CRITICAL".equalsIgnoreCase(severity) ? "#dc2626" : ("WARNING".equalsIgnoreCase(severity) ? "#d97706" : "#2563eb");
        String nowStr = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date());

        return "<!DOCTYPE html>"
            + "<html>"
            + "<head><meta charset='UTF-8'></head>"
            + "<body style='margin:0; padding:20px; background-color:#f1f5f9; font-family:-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif; color:#1e293b;'>"
            + "  <div style='max-width:620px; margin:0 auto; background:#ffffff; border-radius:10px; overflow:hidden; box-shadow:0 4px 6px -1px rgba(0,0,0,0.1); border:1px solid #e2e8f0;'>"
            + "    <div style='background:" + headerColor + "; color:#ffffff; padding:24px; text-align:center;'>"
            + "      <div style='font-size:12px; font-weight:700; letter-spacing:1px; text-transform:uppercase; margin-bottom:4px; opacity:0.9;'>VendDB Monitoring System</div>"
            + "      <h1 style='margin:0; font-size:22px; font-weight:700;'>OPERATIONAL ALERT NOTIFICATION</h1>"
            + "    </div>"
            + "    <div style='padding:28px 24px;'>"
            + "      <p style='font-size:15px; line-height:1.5; margin-top:0;'>Hello <strong>" + staffName + "</strong>,</p>"
            + "      <p style='font-size:14px; line-height:1.5; color:#475569;'>An operational incident has been detected by the automated sensor monitoring system at your assigned vending machine:</p>"
            + "      <div style='background:#f8fafc; border-left:4px solid " + headerColor + "; border-radius:4px; padding:16px 20px; margin:20px 0;'>"
            + "        <table style='width:100%; border-collapse:collapse; font-size:14px;'>"
            + "          <tr><td style='padding:6px 0; color:#64748b; width:130px;'>Machine:</td><td style='padding:6px 0; font-weight:600; color:#0f172a;'>" + machine + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Location:</td><td style='padding:6px 0; font-weight:600; color:#0f172a;'>" + location + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Target Slot:</td><td style='padding:6px 0; font-weight:700; color:#2563eb;'>Slot " + slot + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Incident Type:</td><td style='padding:6px 0; font-weight:700; color:" + headerColor + ";'>" + ruleCode + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Severity:</td><td style='padding:6px 0; font-weight:700; color:" + headerColor + ";'>" + severity + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Timestamp:</td><td style='padding:6px 0; color:#0f172a;'>" + nowStr + "</td></tr>"
            + "        </table>"
            + "        <div style='margin-top:12px; padding-top:12px; border-top:1px dashed #cbd5e1; font-size:13px; color:#334155; line-height:1.5;'>"
            + "          <strong>Diagnostic Details:</strong> " + message
            + "        </div>"
            + "      </div>"
            + "      <p style='font-size:14px; color:#475569; line-height:1.5;'><strong>Recommended Action:</strong></p>"
            + "      <ul style='font-size:13px; color:#475569; line-height:1.6; padding-left:20px; margin-top:6px;'>"
            + "        <li>Inspect the vending coil and tray for physical obstructions or stuck products.</li>"
            + "        <li>Verify coil rotational sensors and motor alignment.</li>"
            + "        <li>Log in to the VendDB Management Portal to record your resolution and resume normal dispensing.</li>"
            + "      </ul>"
            + "    </div>"
            + "    <div style='background:#f8fafc; border-top:1px solid #e2e8f0; padding:16px; text-align:center; font-size:12px; color:#94a3b8;'>"
            + "      PRJ301 Smart Vending Machine Automated Monitoring &copy; Fall 2026"
            + "    </div>"
            + "  </div>"
            + "</body>"
            + "</html>";
    }

    /**
     * Mẫu Email Xác nhận đã xử lý sự cố (Resolution Confirmation HTML Template)
     */
    private static String buildResolutionEmailHtml(String staffName, int alertId, String machine, 
                                                   String slot, String ruleCode, String handler, 
                                                   String handledNote, boolean slotUnlocked) {
        String nowStr = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date());

        return "<!DOCTYPE html>"
            + "<html>"
            + "<head><meta charset='UTF-8'></head>"
            + "<body style='margin:0; padding:20px; background-color:#f1f5f9; font-family:-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif; color:#1e293b;'>"
            + "  <div style='max-width:620px; margin:0 auto; background:#ffffff; border-radius:10px; overflow:hidden; box-shadow:0 4px 6px -1px rgba(0,0,0,0.1); border:1px solid #e2e8f0;'>"
            + "    <div style='background:#16a34a; color:#ffffff; padding:24px; text-align:center;'>"
            + "      <div style='font-size:12px; font-weight:700; letter-spacing:1px; text-transform:uppercase; margin-bottom:4px; opacity:0.9;'>VendDB Maintenance Confirmation</div>"
            + "      <h1 style='margin:0; font-size:22px; font-weight:700;'>INCIDENT RESOLVED & CLOSED</h1>"
            + "    </div>"
            + "    <div style='padding:28px 24px;'>"
            + "      <p style='font-size:15px; line-height:1.5; margin-top:0;'>Hello <strong>" + staffName + "</strong>,</p>"
            + "      <p style='font-size:14px; line-height:1.5; color:#475569;'>The following operational incident has been successfully resolved and logged into the audit trail:</p>"
            + "      <div style='background:#f0fdf4; border-left:4px solid #16a34a; border-radius:4px; padding:16px 20px; margin:20px 0;'>"
            + "        <table style='width:100%; border-collapse:collapse; font-size:14px;'>"
            + "          <tr><td style='padding:6px 0; color:#64748b; width:130px;'>Incident ID:</td><td style='padding:6px 0; font-weight:700; color:#0f172a;'>#" + alertId + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Machine:</td><td style='padding:6px 0; font-weight:600; color:#0f172a;'>" + machine + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Slot:</td><td style='padding:6px 0; font-weight:700; color:#2563eb;'>Slot " + slot + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Issue Type:</td><td style='padding:6px 0; font-weight:600; color:#334155;'>" + ruleCode + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Resolved By:</td><td style='padding:6px 0; font-weight:700; color:#16a34a;'>" + handler + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Resolved At:</td><td style='padding:6px 0; color:#0f172a;'>" + nowStr + "</td></tr>"
            + "          <tr><td style='padding:6px 0; color:#64748b;'>Slot Status:</td><td style='padding:6px 0; font-weight:700; color:" + (slotUnlocked ? "#16a34a" : "#2563eb") + ";'>" + (slotUnlocked ? "UNLOCKED & ACTIVE (Ready to Vend)" : "Preserved") + "</td></tr>"
            + "        </table>"
            + "        <div style='margin-top:12px; padding-top:12px; border-top:1px dashed #bbf7d0; font-size:13px; color:#14532d; line-height:1.5;'>"
            + "          <strong>Resolution Action Taken:</strong> \"" + handledNote + "\""
            + "        </div>"
            + "      </div>"
            + "      <p style='font-size:13px; color:#475569; line-height:1.5;'>This incident is now marked as <strong>RESOLVED</strong>. The vending machine is verified operational.</p>"
            + "    </div>"
            + "    <div style='background:#f8fafc; border-top:1px solid #e2e8f0; padding:16px; text-align:center; font-size:12px; color:#94a3b8;'>"
            + "      PRJ301 Smart Vending Machine Automated Monitoring &copy; Fall 2026"
            + "    </div>"
            + "  </div>"
            + "</body>"
            + "</html>";
    }
}
