package util;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class WebUtil {

    private static final DecimalFormat CURRENCY_FMT = new DecimalFormat("#,##0");
    private static final SimpleDateFormat DATETIME_FMT = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

    /** Escape chuoi de hien thi an toan tren HTML tranh loi XSS */
    public static String esc(Object val) {
        if (val == null) return "";
        String s = String.valueOf(val);
        StringBuilder out = new StringBuilder(Math.max(16, s.length()));
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '<': out.append("&lt;"); break;
                case '>': out.append("&gt;"); break;
                case '&': out.append("&amp;"); break;
                case '"': out.append("&quot;"); break;
                case '\'': out.append("&#39;"); break;
                default: out.append(c);
            }
        }
        return out.toString();
    }

    public static int parseInt(String val, int def) {
        if (val == null) return def;
        try {
            return Integer.parseInt(val.trim());
        } catch (Exception ex) {
            return def;
        }
    }

    public static double parseDouble(String val, double def) {
        if (val == null) return def;
        try {
            return Double.parseDouble(val.trim());
        } catch (Exception ex) {
            return def;
        }
    }

    public static String formatCurrency(double amount) {
        return CURRENCY_FMT.format(amount) + " đ";
    }

    public static String formatDateTime(Date d) {
        if (d == null) return "-";
        return DATETIME_FMT.format(d);
    }
}
