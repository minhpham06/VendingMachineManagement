package util;

public class VendRuleEngine {

    public static final String LABEL_SUCCESS = "SUCCESS";
    public static final String LABEL_JAM = "JAM";
    public static final String LABEL_WRONG_ITEM = "WRONG_ITEM";
    public static final String LABEL_MOTOR_FAIL = "MOTOR_FAIL";

    /**
     * Tự động phân loại nhãn phiên đo theo 2 nguồn tin độc lập:
     * 1. Động cơ quay đủ vòng (motor_done == true)
     * 2. Độ chênh lệch khối lượng khay (deltaW = weight_after_g - weight_before_g)
     */
    public static String classifySession(boolean motorDone, int rotationTimeMs,
                                         double weightBefore, double weightAfter,
                                         double nominalWeight, double tolerance) {
        // Nếu động cơ không quay đủ vòng hoặc thời gian vượt ngưỡng quá lớn (motor fail)
        if (!motorDone || rotationTimeMs > 4000) {
            return LABEL_MOTOR_FAIL;
        }

        double deltaW = weightAfter - weightBefore;
        double minSuccess = nominalWeight - tolerance;
        double maxSuccess = nominalWeight + tolerance;

        // Trọng lượng không tăng (gần bằng 0) -> Kẹt hàng trong rãnh
        if (deltaW < minSuccess * 0.5) {
            return LABEL_JAM;
        }

        // Trọng lượng nằm trong khoảng danh định +/- dung sai -> Thành công
        if (deltaW >= minSuccess && deltaW <= maxSuccess) {
            return LABEL_SUCCESS;
        }

        // Trọng lượng rơi nhiều hơn (rơi 2 món) hoặc sai lệch lớn -> Sai mặt hàng / Rơi đúp
        return LABEL_WRONG_ITEM;
    }
}
