<%@page import="java.util.List"%>
<%@page import="dao.VendSlotDAO"%>
<%@page import="dao.DeviceDAO"%>
<%@page import="model.VendSlot"%>
<%@page import="model.Device"%>
<%@page import="model.AppUser"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    AppUser currentUser = (AppUser) session.getAttribute("user");
    VendSlotDAO slotDAO = new VendSlotDAO();
    DeviceDAO deviceDAO = new DeviceDAO();

    List<Device> allDevices = deviceDAO.getAllDevices();

    // Mặc định là máy 1 (máy thật Vend-01)
    int selectedDevId = 1;
    String devParam = request.getParameter("deviceId");
    if (devParam != null && !devParam.trim().isEmpty()) {
        selectedDevId = WebUtil.parseInt(devParam, 1);
    }

    Device selectedDevice = deviceDAO.findById(selectedDevId);
    if (selectedDevice == null && allDevices != null && !allDevices.isEmpty()) {
        selectedDevice = allDevices.get(0);
        selectedDevId = selectedDevice.getDeviceId();
    }

    // Chỉ lấy các rãnh thuộc máy được chọn
    List<VendSlot> slots = slotDAO.getSlotsByDevice(selectedDevId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Vending Store - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .store-header {
            background: #ffffff;
            border-bottom: 1px solid var(--border-color, #e2e8f0);
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
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--accent-blue, #2563eb);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .machine-selector-bar {
            display: flex;
            gap: 0.75rem;
            overflow-x: auto;
            padding: 0.75rem 0 1rem;
            margin-top: 0.5rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        .machine-pill {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 18px;
            border-radius: 12px;
            text-decoration: none;
            font-size: 0.92rem;
            font-weight: 600;
            border: 1.5px solid #e2e8f0;
            background: #ffffff;
            color: #475569;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }
        .machine-pill:hover {
            border-color: #3b82f6;
            color: #1d4ed8;
            background: #f8fafc;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(59, 130, 246, 0.1);
        }
        .machine-pill.active {
            background: #eff6ff;
            color: #1d4ed8;
            border: 2px solid #2563eb;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);
        }
        .badge-tag {
            font-size: 0.75rem;
            padding: 3px 8px;
            border-radius: 6px;
            background: #f1f5f9;
            color: #475569;
            font-weight: 700;
            border: 1px solid #cbd5e1;
        }
        .badge-tag.demo-hardware {
            background: #ecfdf5;
            color: #047857;
            border: 1px solid #a7f3d0;
        }
        .current-machine-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-left: 5px solid #2563eb;
            border-radius: 12px;
            padding: 1.25rem 1.75rem;
            margin-top: 0.75rem;
            margin-bottom: 0.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        }
        .vending-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-top: 1.5rem;
            margin-bottom: 3rem;
        }
        .product-card {
            background: #ffffff;
            border: 1px solid var(--border-color, #e2e8f0);
            border-radius: 12px;
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-shadow: 0 2px 5px rgba(0,0,0,0.04);
            transition: all 0.2s;
        }
        .product-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 16px rgba(0,0,0,0.08);
            border-color: #93c5fd;
        }
        .slot-badge {
            font-size: 0.75rem;
            font-weight: 700;
            background: #f1f5f9;
            color: var(--text-secondary, #475569);
            padding: 0.25rem 0.6rem;
            border-radius: 6px;
            border: 1px solid var(--border-color, #e2e8f0);
            display: inline-block;
            margin-bottom: 0.5rem;
        }
        .product-name {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--text-primary, #0f172a);
            margin-bottom: 0.4rem;
            min-height: 2.8rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .product-price {
            font-size: 1.35rem;
            font-weight: 800;
            color: #2563eb;
            margin-bottom: 0.75rem;
        }
        .product-meta {
            font-size: 0.85rem;
            color: var(--text-secondary, #64748b);
            margin-bottom: 1rem;
            border-top: 1px dashed var(--border-color, #e2e8f0);
            padding-top: 0.6rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .qty-control {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            margin-bottom: 0.85rem;
        }
        .qty-btn {
            width: 34px;
            height: 34px;
            background: #f1f5f9;
            border: 1px solid var(--border-color, #e2e8f0);
            border-radius: 6px;
            font-size: 1.1rem;
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
            width: 55px !important;
            height: 34px !important;
            text-align: center;
            font-weight: 700;
            padding: 0 !important;
            margin: 0 !important;
            border: 1px solid var(--border-color, #e2e8f0);
            border-radius: 6px;
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
            max-width: 440px;
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
    </style>
</head>
<body>
    <!-- HEADER -->
    <header class="store-header">
        <div class="store-nav">
            <a href="<%=request.getContextPath()%>/" class="store-brand">
                VendDB Vending Store
            </a>
            <div>
                <% if (currentUser != null) { %>
                    <span style="font-size:0.85rem; color:var(--text-secondary); margin-right:0.6rem;">
                        <%=currentUser.getFullName()%> (<strong><%=currentUser.getRoleCode()%></strong >)
                    </span>
                    <a href="<%=request.getContextPath()%>/dashboard" class="btn btn-primary btn-sm">Admin Portal</a>
                <% } else { %>
                    <a href="<%=request.getContextPath()%>/login" class="btn btn-outline btn-sm">Admin Login</a>
                <% } %>
            </div>
        </div>
    </header>

    <div class="container" style="margin-top:0.75rem;">
        
        <!-- LOCATION SELECTOR (DEFAULT MACHINE 1) -->
        <div style="text-align:center; margin-top:0.5rem;">
            <span style="font-size:0.85rem; font-weight:700; text-transform:uppercase; color:#64748b; letter-spacing:0.5px;">
                Select Vending Machine Location:
            </span>
            <div class="machine-selector-bar">
                <%
                    if (allDevices != null) {
                        for (Device d : allDevices) {
                            boolean isCur = (d.getDeviceId() == selectedDevId);
                %>
                    <a href="<%=request.getContextPath()%>/index?deviceId=<%=d.getDeviceId()%>" 
                       class="machine-pill <%=isCur ? "active" : ""%>">
                        <span><%=d.getDeviceCode()%>: <%=d.getMachineName() != null ? d.getMachineName() : ""%></span>
                        <% if (d.isHardwareDemo()) { %>
                            <span class="badge-tag demo-hardware">Hardware</span>
                        <% } else { %>
                            <span class="badge-tag">Virtual</span>
                        <% } %>
                    </a>
                <%
                        }
                    }
                %>
            </div>
        </div>

        <!-- CURRENT MACHINE DETAILS -->
        <% if (selectedDevice != null) { %>
            <div class="current-machine-card">
                <div>
                    <div style="display:flex; align-items:center; gap:0.5rem;">
                        <h2 style="margin:0; font-size:1.35rem; color:#0f172a;">
                            <%=selectedDevice.getDeviceCode()%> - <%=selectedDevice.getMachineName()%>
                        </h2>
                        <% if (selectedDevice.isHardwareDemo()) { %>
                            <span style="background:#ecfdf5; color:#047857; border:1px solid #a7f3d0; font-size:0.75rem; font-weight:700; padding:3px 10px; border-radius:20px; display:inline-flex; align-items:center;">
                                CONNECTED HARDWARE (ESP32 & LOADCELL)
                            </span>
                        <% } else { %>
                            <span style="background:#eff6ff; color:#1d4ed8; border:1px solid #bfdbfe; font-size:0.75rem; font-weight:700; padding:3px 10px; border-radius:20px; display:inline-flex; align-items:center;">
                                VIRTUAL SIMULATION
                            </span>
                        <% } %>
                    </div>
                    <div style="font-size:0.9rem; color:#475569; margin-top:5px;">
                        Location: <strong style="color:#0f172a;"><%=selectedDevice.getLocationName() != null ? selectedDevice.getLocationName() : "Location not updated"%></strong>
                    </div>
                </div>
                <div>
                    <span style="font-size:0.86rem; color:#1e293b; background:#f8fafc; border:1px solid #e2e8f0; padding:6px 14px; border-radius:8px; font-weight:600; display:inline-block;">
                        Available Slots: <strong style="color:#2563eb;"><%=slots != null ? slots.size() : 0%> slots</strong>
                    </span>
                </div>
            </div>
        <% } %>

        <!-- VENDING SLOTS GRID -->
        <div class="vending-grid">
            <%
                if (slots != null && !slots.isEmpty()) {
                    for (VendSlot s : slots) {
                        boolean hasProduct = (s.getProductName() != null && !s.getProductName().trim().isEmpty());
                        boolean isAvailable = hasProduct && !s.isSuspended() && s.getCurrentStock() > 0;
            %>
            <div class="product-card">
                <div>
                    <span class="slot-badge">Slot <%=s.getCode()%></span>
                    <h3 class="product-name">
                        <%=hasProduct ? WebUtil.esc(s.getProductName()) : "(Empty Slot - No Product Assigned)"%>
                    </h3>
                    
                    <div class="product-price">
                        <%=hasProduct ? WebUtil.formatCurrency(s.getPrice()) : "0 VND"%>
                    </div>

                    <div class="product-meta">
                        <span>Nominal Weight: <strong><%=hasProduct ? WebUtil.formatWeight(s.getNominalWeight()) : "-"%></strong></span>
                        <span>
                            <% if (s.isSuspended()) { %>
                                <span class="badge badge-danger">Suspended</span>
                            <% } else if (s.getCurrentStock() <= 0) { %>
                                <span class="badge badge-warning">Out of stock</span>
                            <% } else { %>
                                <span class="badge badge-success">In Stock: <%=s.getCurrentStock()%> pcs</span>
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
                        <button type="button" class="btn btn-primary" style="width:100%; font-weight:700;" 
                                onclick="openBuyModal('<%=s.getCode()%>', '<%=WebUtil.esc(s.getProductName())%>', <%=s.getPrice()%>, <%=s.getSlotId()%>, '<%=selectedDevice != null ? selectedDevice.getDeviceCode() : ""%>')">
                            Buy Now
                        </button>
                    <% } else { %>
                        <div class="qty-control" style="opacity:0.4; pointer-events:none;">
                            <button type="button" class="qty-btn">-</button>
                            <input type="number" class="qty-input" value="0" disabled>
                            <button type="button" class="qty-btn">+</button>
                        </div>
                        <button type="button" class="btn btn-outline" style="width:100%;" disabled>
                            <%=s.isSuspended() ? "Under Maintenance" : (s.getCurrentStock() <= 0 ? "Out of Stock" : "Unavailable")%>
                        </button>
                    <% } %>
                </div>
            </div>
            <%
                    }
                } else {
            %>
            <div style="grid-column: 1 / -1; text-align:center; padding:3.5rem; background:#fff; border-radius:12px; border:1px solid #cbd5e1; color:#64748b;">
                No active dispensing slots available in this vending machine.
            </div>
            <% } %>
        </div>
    </div>

    <!-- MODAL CONFIRM PURCHASE (VNPAY) -->
    <div id="buyModal" class="modal-overlay" onclick="closeModal(event)">
        <div class="modal-box" onclick="event.stopPropagation()">
            <h3 style="font-size:1.35rem; color:var(--text-primary); margin-bottom:0.4rem;">Order Confirmation</h3>
            <p style="color:var(--text-secondary); font-size:0.88rem; margin-bottom:1.25rem;">Online payment via VNPay Sandbox</p>

            <form id="vnpayForm" action="<%=request.getContextPath()%>/vnpay_pay" method="POST">
                <input type="hidden" name="amount" id="formAmount" value="0">
                <input type="hidden" name="slotCode" id="formSlotCode" value="">
                <input type="hidden" name="orderInfo" id="formOrderInfo" value="">
                <input type="hidden" name="qty" id="formQty" value="1">

                <div style="background:#f8fafc; border:1px solid #cbd5e1; border-radius:8px; padding:1rem; text-align:left; margin-bottom:1.25rem; font-size:0.9rem;">
                    <div style="display:flex; justify-content:space-between; margin-bottom:0.4rem;">
                        <span style="color:#64748b;">Machine:</span>
                        <strong id="modalDevName" style="color:#2563eb;">-</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; margin-bottom:0.4rem;">
                        <span style="color:#64748b;">Product:</span>
                        <strong id="modalProdName">-</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; margin-bottom:0.4rem;">
                        <span style="color:#64748b;">Slot:</span>
                        <strong id="modalSlotCode">-</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; margin-bottom:0.4rem;">
                        <span style="color:#64748b;">Quantity:</span>
                        <strong id="modalQty">-</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; border-top:1px dashed #cbd5e1; padding-top:0.5rem; font-size:1.05rem;">
                        <span style="color:#0f172a; font-weight:700;">Total Amount:</span>
                        <strong id="modalTotal" style="color:#2563eb;">-</strong>
                    </div>
                </div>

                <div style="display: flex; gap: 0.75rem;">
                    <button type="button" class="btn btn-outline" style="flex: 1;" onclick="closeModal()">
                        Cancel
                    </button>
                    <button type="submit" class="btn btn-primary" style="flex: 2; font-weight:700;">
                        Pay with VNPay
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

        function openBuyModal(slotCode, prodName, price, slotId, devCode) {
            const input = document.getElementById('qty_' + slotId);
            const qty = input ? parseInt(input.value) || 1 : 1;
            const total = price * qty;

            document.getElementById('modalDevName').innerText = devCode;
            document.getElementById('modalProdName').innerText = prodName;
            document.getElementById('modalSlotCode').innerText = 'Slot ' + slotCode;
            document.getElementById('modalQty').innerText = qty + ' pcs';
            document.getElementById('modalTotal').innerText = total.toLocaleString('vi-VN') + ' VND';

            // Set data to VNPay submit form
            document.getElementById('formAmount').value = total;
            document.getElementById('formSlotCode').value = slotCode;
            document.getElementById('formOrderInfo').value = devCode + ' - Order ' + qty + ' ' + prodName + ' (Slot ' + slotCode + ')';
            document.getElementById('formQty').value = qty;

            document.getElementById('buyModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('buyModal').style.display = 'none';
        }
    </script>
</body>
</html>
