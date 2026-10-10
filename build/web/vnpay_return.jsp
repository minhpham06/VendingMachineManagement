<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="util.VNPayConfig"%>
<%@page import="util.WebUtil"%>
<%@page import="dao.VendSlotDAO"%>
<%@page import="model.VendSlot"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán VNPay - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .return-card {
            max-width: 600px;
            margin: 2.5rem auto;
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.06);
            overflow: hidden;
        }
        .return-header {
            padding: 1.5rem;
            text-align: center;
            border-bottom: 1px solid var(--border-color);
        }
        .status-badge {
            display: inline-block;
            padding: 0.35rem 1rem;
            border-radius: 9999px;
            font-size: 0.95rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }
        .status-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }
        .status-failed {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 0.75rem 1.5rem;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.95rem;
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            color: var(--text-secondary);
        }
        .detail-value {
            font-weight: 600;
            color: var(--text-primary);
            text-align: right;
            word-break: break-all;
        }
    </style>
</head>
<body>
<%
    // Xử lý dữ liệu trả về từ VNPAY chuẩn mẫu
    Map fields = new HashMap();
    for (Enumeration params = request.getParameterNames(); params.hasMoreElements();) {
        String fieldName = URLEncoder.encode((String) params.nextElement(), StandardCharsets.US_ASCII.toString());
        String fieldValue = URLEncoder.encode(request.getParameter(fieldName), StandardCharsets.US_ASCII.toString());
        if ((fieldValue != null) && (fieldValue.length() > 0)) {
            fields.put(fieldName, fieldValue);
        }
    }

    String vnp_SecureHash = request.getParameter("vnp_SecureHash");
    if (fields.containsKey("vnp_SecureHashType")) {
        fields.remove("vnp_SecureHashType");
    }
    if (fields.containsKey("vnp_SecureHash")) {
        fields.remove("vnp_SecureHash");
    }
    String signValue = VNPayConfig.hashAllFields(fields);

    boolean checkSignature = (signValue != null && signValue.equals(vnp_SecureHash));
    String vnp_TransactionStatus = request.getParameter("vnp_TransactionStatus");
    String vnp_ResponseCode = request.getParameter("vnp_ResponseCode");
    boolean isSuccess = checkSignature && "00".equals(vnp_TransactionStatus);

    if (isSuccess) {
        String pendingSlotCode = (String) session.getAttribute("pendingSlotCode");
        String pendingQtyStr = (String) session.getAttribute("pendingQty");
        if (pendingSlotCode != null && pendingQtyStr != null) {
            try {
                int qtyToDeduct = Integer.parseInt(pendingQtyStr);
                VendSlotDAO slotDAO = new VendSlotDAO();
                VendSlot slot = slotDAO.findByCode(pendingSlotCode);
                if (slot != null) {
                    slotDAO.updateStock(slot.getSlotId(), -qtyToDeduct);
                }
            } catch (Exception e) {
                // Ignore parsing errors
            }
            session.removeAttribute("pendingSlotCode");
            session.removeAttribute("pendingQty");
        }
    }

    String vnp_TxnRef = request.getParameter("vnp_TxnRef");
    String vnp_Amount = request.getParameter("vnp_Amount");
    String vnp_OrderInfo = request.getParameter("vnp_OrderInfo");
    String vnp_TransactionNo = request.getParameter("vnp_TransactionNo");
    String vnp_BankCode = request.getParameter("vnp_BankCode");
    String vnp_PayDate = request.getParameter("vnp_PayDate");

    long displayAmount = 0;
    if (vnp_Amount != null) {
        try {
            displayAmount = Long.parseLong(vnp_Amount) / 100;
        } catch (Exception ignored) {}
    }
%>

    <div class="container">
        <div class="return-card">
            <div class="return-header">
                <% if (isSuccess) { %>
                    <span class="status-badge status-success">Thanh toán Thành công</span>
                    <h2 style="font-size: 1.5rem; color: #166534; margin: 0.25rem 0;">Giao dịch hoàn tất</h2>
                    <p style="color: var(--text-secondary); font-size: 0.9rem;">Cảm ơn bạn đã mua hàng tại Máy bán hàng tự động</p>
                <% } else if (!checkSignature) { %>
                    <span class="status-badge status-failed">Lỗi Chữ Ký</span>
                    <h2 style="font-size: 1.5rem; color: #991b1b; margin: 0.25rem 0;">Xác thực không hợp lệ</h2>
                    <p style="color: var(--text-secondary); font-size: 0.9rem;">Chữ ký trả về không khớp với mã bảo mật (invalid signature)</p>
                <% } else { %>
                    <span class="status-badge status-failed">Giao dịch Thất bại</span>
                    <h2 style="font-size: 1.5rem; color: #991b1b; margin: 0.25rem 0;">Thanh toán không thành công</h2>
                    <p style="color: var(--text-secondary); font-size: 0.9rem;">Giao dịch đã bị hủy hoặc có lỗi (Mã trạng thái: <%=vnp_TransactionStatus != null ? vnp_TransactionStatus : vnp_ResponseCode%>)</p>
                <% } %>
            </div>

            <div>
                <div class="detail-row">
                    <span class="detail-label">Mã đơn hàng (TxnRef):</span>
                    <span class="detail-value"><%=vnp_TxnRef != null ? WebUtil.esc(vnp_TxnRef) : "N/A"%></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Số tiền thanh toán:</span>
                    <span class="detail-value" style="color: var(--accent-blue); font-size: 1.1rem;">
                        <%=WebUtil.formatCurrency(displayAmount)%>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Nội dung thanh toán:</span>
                    <span class="detail-value"><%=vnp_OrderInfo != null ? WebUtil.esc(vnp_OrderInfo) : "N/A"%></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Mã giao dịch VNPay:</span>
                    <span class="detail-value"><%=vnp_TransactionNo != null ? WebUtil.esc(vnp_TransactionNo) : "N/A"%></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Ngân hàng thanh toán:</span>
                    <span class="detail-value"><%=vnp_BankCode != null ? WebUtil.esc(vnp_BankCode) : "N/A"%></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Mã phản hồi (Response Code):</span>
                    <span class="detail-value"><%=vnp_ResponseCode != null ? WebUtil.esc(vnp_ResponseCode) : "N/A"%></span>
                </div>
                <% if (vnp_PayDate != null && vnp_PayDate.length() == 14) { %>
                <div class="detail-row">
                    <span class="detail-label">Thời gian thanh toán:</span>
                    <span class="detail-value">
                        <%=vnp_PayDate.substring(6, 8) + "/" + vnp_PayDate.substring(4, 6) + "/" + vnp_PayDate.substring(0, 4) + " " + vnp_PayDate.substring(8, 10) + ":" + vnp_PayDate.substring(10, 12) + ":" + vnp_PayDate.substring(12, 14)%>
                    </span>
                </div>
                <% } %>
            </div>

            <div style="padding: 1.5rem; text-align: center; background: #f8fafc; border-top: 1px solid var(--border-color);">
                <a href="<%=request.getContextPath()%>/index.jsp" class="btn btn-primary" style="display: inline-block; width: 100%;">
                    Quay về Trang chủ Mua hàng
                </a>
            </div>
        </div>
    </div>
</body>
</html>
