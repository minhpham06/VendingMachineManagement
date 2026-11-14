<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="model.AppUser"%>
<%@page import="model.Device"%>
<%@page import="util.WebUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Machine Assignments - VendDB</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <style>
        .badge-hardware {
            background: #059669;
            color: #ffffff;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .badge-virtual {
            background: #2563eb;
            color: #ffffff;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .modal-backdrop {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.6);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }
        .modal-box {
            background: var(--bg-card, #ffffff);
            border: 1px solid var(--border-color, #e5e7eb);
            border-radius: 8px;
            width: 90%;
            max-width: 580px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            padding: 1.5rem;
        }
        .machine-checkbox-card {
            border: 1px solid var(--border-color, #e5e7eb);
            border-radius: 6px;
            padding: 0.75rem 1rem;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--bg-surface, #f9fafb);
            transition: all 0.2s;
            cursor: pointer;
        }
        .machine-checkbox-card:hover {
            border-color: var(--primary-color, #3b82f6);
            background: #eff6ff;
        }
        .machine-checkbox-card input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="container">
        <% if (request.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success" style="margin-bottom: 1.5rem;">
                <%=request.getAttribute("successMessage")%>
            </div>
        <% } %>

        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">Machine Assignments Management</h2>
                    <p style="font-size:0.875rem; color:var(--text-secondary); margin-top:0.25rem;">
                        Authorize and configure machine-level access rights for <strong>Operator</strong> (Restock/Maintenance) and <strong>Reviewer</strong> (Data Verification).
                    </p>
                </div>
            </div>

            <!-- TABLE -->
            <div class="table-responsive" style="margin-top: 1rem;">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width: 25%;">Staff Member</th>
                            <th style="width: 15%;">System Role</th>
                            <th style="width: 45%;">Assigned Vending Machines</th>
                            <th style="width: 15%; text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<AppUser> targetUsers = (List<AppUser>) request.getAttribute("targetUsers");
                            List<Device> allDevices = (List<Device>) request.getAttribute("allDevices");
                            Map<Integer, List<Device>> assignmentsMap = (Map<Integer, List<Device>>) request.getAttribute("assignmentsMap");

                            if (targetUsers != null && !targetUsers.isEmpty()) {
                                for (AppUser u : targetUsers) {
                                    List<Device> assigned = (assignmentsMap != null) ? assignmentsMap.get(u.getUserId()) : null;
                                    StringBuilder devIdsJson = new StringBuilder("[");
                                    if (assigned != null) {
                                        for (int i = 0; i < assigned.size(); i++) {
                                            devIdsJson.append(assigned.get(i).getDeviceId());
                                            if (i < assigned.size() - 1) devIdsJson.append(",");
                                        }
                                    }
                                    devIdsJson.append("]");
                        %>
                            <tr>
                                <td>
                                    <strong><%=u.getFullName()%></strong>
                                    <div style="font-size:0.8rem; color:var(--text-secondary);">@<%=u.getUsername()%> • <%=u.getEmail() != null ? u.getEmail() : ""%></div>
                                </td>
                                <td>
                                    <% if ("OPERATOR".equals(u.getRoleCode())) { %>
                                        <span class="badge" style="background:#fef3c7; color:#92400e; font-weight:600;">OPERATOR</span>
                                    <% } else if ("REVIEWER".equals(u.getRoleCode())) { %>
                                        <span class="badge" style="background:#e0e7ff; color:#3730a3; font-weight:600;">REVIEWER</span>
                                    <% } else { %>
                                        <span class="badge"><%=u.getRoleCode()%></span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (assigned != null && !assigned.isEmpty()) { %>
                                        <div style="display:flex; flex-wrap:wrap; gap:0.4rem;">
                                            <% for (Device d : assigned) { %>
                                                <% if (d.isHardwareDemo()) { %>
                                                    <span class="badge-hardware" title="<%=d.getLocationName() != null ? d.getLocationName() : ""%>">
                                                        [HARDWARE] <%=d.getDeviceCode()%>: <%=d.getMachineName() != null ? d.getMachineName() : ""%>
                                                    </span>
                                                <% } else { %>
                                                    <span class="badge-virtual" title="<%=d.getLocationName() != null ? d.getLocationName() : ""%>">
                                                        [VIRTUAL] <%=d.getDeviceCode()%>: <%=d.getMachineName() != null ? d.getMachineName() : ""%>
                                                    </span>
                                                <% } %>
                                            <% } %>
                                        </div>
                                    <% } else { %>
                                        <span style="font-size:0.85rem; color:#dc2626; font-style:italic;">
                                            No machines assigned (Data access restricted)
                                        </span>
                                    <% } %>
                                </td>
                                <td style="text-align: center;">
                                    <button type="button" class="btn btn-outline btn-sm"
                                            onclick='openAssignModal(<%=u.getUserId()%>, "<%=WebUtil.esc(u.getFullName())%>", "<%=u.getRoleCode()%>", <%=devIdsJson.toString()%>)'>
                                        Assign Machines
                                    </button>
                                </td>
                            </tr>
                        <%
                                }
                            } else {
                        %>
                            <tr>
                                <td colspan="4" style="text-align:center; padding:2rem; color:var(--text-secondary);">
                                    No operator or reviewer staff accounts found in the system.
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- MODAL ASSIGN MACHINE -->
    <div id="assignModal" class="modal-backdrop">
        <div class="modal-box">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem; border-bottom:1px solid var(--border-color, #e5e7eb); padding-bottom:0.75rem;">
                <h3 style="margin:0; font-size:1.2rem;">Assign Machines for: <span id="modalUserName" style="color:var(--primary-color, #2563eb);"></span></h3>
                <button type="button" style="background:none; border:none; font-size:1rem; font-weight:700; color:#64748b; cursor:pointer;" onclick="closeAssignModal()">Close</button>
            </div>

            <form action="<%=request.getContextPath()%>/admin/assignments" method="POST">
                <input type="hidden" name="userId" id="modalUserId">

                <p style="font-size:0.875rem; color:var(--text-secondary); margin-bottom:1rem;">
                    Select the vending machines this staff member is authorized to manage and monitor:
                </p>

                <div style="max-height: 320px; overflow-y: auto; padding-right: 0.25rem;">
                    <% if (allDevices != null) {
                        for (Device dev : allDevices) {
                    %>
                        <label class="machine-checkbox-card" for="dev_chk_<%=dev.getDeviceId()%>">
                            <div>
                                <div style="font-weight: 600; display:flex; align-items:center; gap:0.5rem;">
                                    <%=dev.getDeviceCode()%> - <%=dev.getMachineName() != null ? dev.getMachineName() : "Vending Machine"%>
                                    <% if (dev.isHardwareDemo()) { %>
                                        <span class="badge-hardware" style="font-size:0.68rem;">HARDWARE DEMO</span>
                                    <% } else { %>
                                        <span class="badge-virtual" style="font-size:0.68rem;">VIRTUAL DEMO</span>
                                    <% } %>
                                </div>
                                <div style="font-size: 0.8rem; color: var(--text-secondary); margin-top: 2px;">
                                    <%=dev.getLocationName() != null ? dev.getLocationName() : "Location not specified"%>
                                </div>
                            </div>
                            <input type="checkbox" name="deviceIds" id="dev_chk_<%=dev.getDeviceId()%>" value="<%=dev.getDeviceId()%>">
                        </label>
                    <%   }
                       } %>
                </div>

                <div style="display:flex; justify-content:flex-end; gap:0.75rem; margin-top:1.25rem; border-top:1px solid var(--border-color, #e5e7eb); padding-top:1rem;">
                    <button type="button" class="btn btn-outline" onclick="closeAssignModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Assignments</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openAssignModal(userId, fullName, roleCode, assignedIds) {
            document.getElementById('modalUserId').value = userId;
            document.getElementById('modalUserName').innerText = fullName + ' (' + roleCode + ')';

            // Reset tất cả checkboxes
            var checkboxes = document.querySelectorAll('input[name="deviceIds"]');
            checkboxes.forEach(function(cb) {
                var devId = parseInt(cb.value);
                cb.checked = (assignedIds.indexOf(devId) !== -1);
            });

            document.getElementById('assignModal').style.display = 'flex';
        }

        function closeAssignModal() {
            document.getElementById('assignModal').style.display = 'none';
        }

        // Đóng khi click ra ngoài backdrop
        window.onclick = function(event) {
            var modal = document.getElementById('assignModal');
            if (event.target === modal) {
                closeAssignModal();
            }
        };
    </script>
</body>
</html>
