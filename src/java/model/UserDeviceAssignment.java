package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class UserDeviceAssignment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int assignmentId;
    private int userId;
    private String username;
    private String userFullName;
    private String roleCode;
    private int deviceId;
    private String deviceCode;
    private String machineName;
    private String locationName;
    private boolean hardwareDemo;
    private int assignedBy;
    private String assignerFullName;
    private Timestamp assignedAt;

    public UserDeviceAssignment() {
    }

    public int getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getUserFullName() {
        return userFullName;
    }

    public void setUserFullName(String userFullName) {
        this.userFullName = userFullName;
    }

    public String getRoleCode() {
        return roleCode;
    }

    public void setRoleCode(String roleCode) {
        this.roleCode = roleCode;
    }

    public int getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(int deviceId) {
        this.deviceId = deviceId;
    }

    public String getDeviceCode() {
        return deviceCode;
    }

    public void setDeviceCode(String deviceCode) {
        this.deviceCode = deviceCode;
    }

    public String getMachineName() {
        return machineName;
    }

    public void setMachineName(String machineName) {
        this.machineName = machineName;
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
    }

    public boolean isHardwareDemo() {
        return hardwareDemo;
    }

    public void setHardwareDemo(boolean hardwareDemo) {
        this.hardwareDemo = hardwareDemo;
    }

    public int getAssignedBy() {
        return assignedBy;
    }

    public void setAssignedBy(int assignedBy) {
        this.assignedBy = assignedBy;
    }

    public String getAssignerFullName() {
        return assignerFullName;
    }

    public void setAssignerFullName(String assignerFullName) {
        this.assignerFullName = assignerFullName;
    }

    public Timestamp getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(Timestamp assignedAt) {
        this.assignedAt = assignedAt;
    }
}
