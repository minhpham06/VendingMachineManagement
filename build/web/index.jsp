<%@page import="java.util.List"%>
<%@page import="dao.VendSlotDAO"%>
<%@page import="model.VendSlot"%>
<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser currentUser = (AppUser) session.getAttribute("user");
    VendSlotDAO slotDAO = new VendSlotDAO();
    List<VendSlot> slots = slotDAO.getAllSlots();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Máy bán hàng tự động - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .store-header {
            background: #ffffff;
            border-bottom: 1px solid var(--border-color);
            padding: 0.75rem 1.25rem;
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .store-nav {
            max-width: 1280px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .store-brand {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--accent-blue);
            text-decoration: none;
        }
        .store-banner {
            text-align: center;
            padding: 2.5rem 1rem 1.5rem;
            max-width: 800px;
            margin: 0 auto;
        }
        .store-banner h1 {
            font-size: 1.85rem;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            font-weight: 700;
        }
        .store-banner p {
            color: var(--text-secondary);
            font-size: 0.95rem;
        }
        .vending-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 1.25rem;
            margin-top: 1.5rem;
        }
        .product-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 1.25rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-shadow: 0 2px 4px rgba(0,0,0,0.04);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .product-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.08);
        }
        .slot-badge {
            font-size: 0.75rem;
            font-weight: 700;
            background: #f1f5f9;
            color: var(--text-secondary);
            padding: 0.2rem 0.5rem;
            border-radius: 4px;
            border: 1px solid var(--border-color);
            display: inline-block;
            margin-bottom: 0.5rem;
        }
        .product-name {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.35rem;
            min-height: 2.6rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .product-price {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--accent-blue);
            margin-bottom: 0.75rem;
        }
        .product-meta {
            font-size: 0.82rem;
            color: var(--text-secondary);
            margin-bottom: 0.85rem;
            border-top: 1px dashed var(--border-color);
            padding-top: 0.5rem;
            display: flex;
            justify-content: space-between;
        }
        .qty-control {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            margin-bottom: 0.85rem;
        }
        .qty-btn {
            width: 32px;
            height: 32px;
            background: #f1f5f9;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.15s;
        }
        .qty-btn:hover {
            background: #e2e8f0;
        }
        .qty-input {
            width: 50px !important;
            height: 32px !important;
            text-align: center;
            font-weight: 600;
            padding: 0 !important;
            margin: 0 !important;
        }
        /* Modal Popup */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.6);
            z-index: 2000;
            justify-content: center;
            align-items: center;
            padding: 1rem;
        }
        .modal-box {
            background: #ffffff;
            border-radius: 12px;
            max-width: 420px;
            width: 100%;
            padding: 1.75rem;
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);
            text-align: center;
            animation: modalFadeIn 0.2s ease-out;
        }
        @keyframes modalFadeIn {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }
        @media (max-width: 600px) {
            .vending-grid {
                grid-template-columns: 1fr;
            }
            .store-banner h1 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <!-- HEADER -->
    <header class="store-header">
        <div class="store-nav">
            <a href="<%=request.getContextPath()%>/index.jsp" class="store-brand">VendDB Vending Store</a>
            <div>
                <% if (currentUser != null) { %>
                    <span style="font-size:0.85rem; color:var(--text-secondary); margin-right:0.5rem;">
                        <%=currentUser.getFullName()%> (<%=currentUser.getRoleCode()%>)
                    </span>
                    <a href="<%=request.getContextPath()%>/dashboard" class="btn btn-primary btn-sm">Trang Quản trị</a>
                <% } else { %>
                    <a href="<%=request.getContextPath()%>/login" class="btn btn-outline btn-sm">Đăng nhập Quản trị</a>
                <% } %>
            </div>
        </div>
    </header>

    <div class="container" style="margin-top:0.5rem;">
        <!-- BANNER -->
        <div class="store-banner">
            <h1>Máy Bán Hàng Tự Động</h1>
            <p>Chọn sản phẩm, tùy chỉnh số lượng và nhấn Mua hàng để nhận đồ uống & thực phẩm ngay lập tức.</p>
        </div>

        <!-- PRODUCTS GRID -->
        <div class="vending-grid">
            <%
                if (slots != null && !slots.isEmpty()) {
                    for (VendSlot s : slots) {
                        boolean hasProduct = (s.getProductName() != null && !s.getProductName().trim().isEmpty());
                        boolean isAvailable = hasProduct && !s.isSuspended() && s.getCurrentStock() > 0;
            %>
            <div class="product-card">
                <div>
                    <span class="slot-badge">Rãnh <%=s.getCode()%></span>
                    <h3 class="product-name">
                        <%=hasProduct ? WebUtil.esc(s.getProductName()) : "(Rãnh trống chưa có hàng)"%>
                    </h3>
                    
                    <div class="product-price">
                        <%=hasProduct ? WebUtil.formatCurrency(s.getPrice()) : "0 đ"%>
                    </div>

                    <div class="product-meta">
                        <span>Khối lượng: <%=hasProduct ? WebUtil.formatWeight(s.getNominalWeight()) : "-"%></span>
                        <span>
                            <% if (s.isSuspended()) { %>
                                <span class="badge badge-danger">Tạm ngưng</span>
                            <% } else if (s.getCurrentStock() <= 0) { %>
                                <span class="badge badge-warning">Hết hàng</span>
                            <% } else { %>
                                <span class="badge badge-success">Còn: <%=s.getCurrentStock()%> gói</span>
                            <% } %>
                        </span>
                    </div>
                </div>

                <div>
                    <% if (isAvailable) { %>
                        <div class="qty-control">
                            <button type="button" class="qty-btn" onclick="changeQty(<%=s.getSlotId()%>, -1, <%=s.getCurrentStock()%>)">-</button>
                            <input type="number" id="qty_<%=s.getSlotId()%>" class="qty-input" value="1" min="1" max="<%=s.getCurrentStock()%>" readonly>
                            <button type="button" class="qty-btn" onclick="changeQty(<%=s.getSlotId()%>, 1, <%=s.getCurrentStock()%>)">+</button>
                        </div>
                        <button type="button" class="btn btn-primary" style="width:100%;" 
                                onclick="openBuyModal('<%=s.getCode()%>', '<%=WebUtil.esc(s.getProductName())%>', <%=s.getPrice()%>, <%=s.getSlotId()%>)">
                            Mua ngay
                        </button>
                    <% } else { %>
                        <div class="qty-control" style="opacity:0.4; pointer-events:none;">
                            <button type="button" class="qty-btn">-</button>
                            <input type="number" class="qty-input" value="0" disabled>
                            <button type="button" class="qty-btn">+</button>
                        </div>
                        <button type="button" class="btn btn-outline" style="width:100%;" disabled>
                            <%=s.isSuspended() ? "Đang bảo trì" : (s.getCurrentStock() <= 0 ? "Tạm hết hàng" : "Chưa có hàng")%>
                        </button>
                    <% } %>
                </div>
            </div>
            <%
                    }
                } else {
            %>
            <div style="grid-column: 1 / -1; text-align:center; padding:3rem; color:var(--text-muted);">
                Hiện tại máy chưa được nạp mặt hàng nào.
            </div>
            <% } %>
        </div>
    </div>

    <!-- MODAL CONFIRM POPUP WITH VNPAY FORM -->
    <div id="buyModal" class="modal-overlay" onclick="closeModal(event)">
        <div class="modal-box" onclick="event.stopPropagation()">
            <h3 style="font-size:1.35rem; color:var(--text-primary); margin-bottom:0.5rem;">Xác nhận Mua hàng</h3>
            <p style="color:var(--text-secondary); font-size:0.9rem; margin-bottom:1.25rem;">Thanh toán trực tuyến qua cổng VNPay Sandbox</p>

            <form id="vnpayForm" action="<%=request.getContextPath()%>/vnpay_pay" method="POST">
                <input type="hidden" name="amount" id="formAmount" value="0">
                <input type="hidden" name="slotCode" id="formSlotCode" value="">
                <input type="hidden" name="orderInfo" id="formOrderInfo" value="">
                <input type="hidden" name="qty" id="formQty" value="1">

                <div style="background:#f8fafc; border:1px solid var(--border-color); border-radius:8px; padding:1rem; text-align:left; margin-bottom:1.25rem; font-size:0.9rem;">
                    <div style="display:flex; justify-content:space-between; margin-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Mặt hàng:</span>
                        <strong id="modalProdName">-</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; margin-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Vị trí rãnh:</span>
                        <strong id="modalSlotCode">-</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; margin-bottom:0.4rem;">
                        <span style="color:var(--text-secondary);">Số lượng chọn:</span>
                        <strong id="modalQty">-</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; border-top:1px dashed var(--border-color); padding-top:0.4rem; font-size:1rem;">
                        <span style="color:var(--text-primary); font-weight:600;">Tổng thanh toán:</span>
                        <strong id="modalTotal" style="color:var(--accent-blue);">-</strong>
                    </div>
                </div>

                <div style="display: flex; gap: 0.75rem;">
                    <button type="button" class="btn btn-outline" style="flex: 1;" onclick="closeModal()">
                        Hủy
                    </button>
                    <button type="submit" class="btn btn-primary" style="flex: 2;">
                        Thanh toán qua VNPay
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function changeQty(slotId, delta, maxStock) {
            const input = document.getElementById('qty_' + slotId);
            if (!input) return;
            let current = parseInt(input.value) || 1;
            current += delta;
            if (current < 1) current = 1;
            if (current > maxStock) current = maxStock;
            input.value = current;
        }

        function openBuyModal(slotCode, prodName, price, slotId) {
            const input = document.getElementById('qty_' + slotId);
            const qty = input ? parseInt(input.value) || 1 : 1;
            const total = price * qty;

            document.getElementById('modalProdName').innerText = prodName;
            document.getElementById('modalSlotCode').innerText = 'Rãnh ' + slotCode;
            document.getElementById('modalQty').innerText = qty + ' gói';
            document.getElementById('modalTotal').innerText = total.toLocaleString('vi-VN') + ' đ';

            // Gán dữ liệu vào Form submit VNPay
            document.getElementById('formAmount').value = total;
            document.getElementById('formSlotCode').value = slotCode;
            document.getElementById('formOrderInfo').value = 'Mua ' + qty + ' ' + prodName + ' (Ran ' + slotCode + ')';
            document.getElementById('formQty').value = qty;

            document.getElementById('buyModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('buyModal').style.display = 'none';
        }
    </script>
</body>
</html>
