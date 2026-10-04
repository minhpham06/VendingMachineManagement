package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class AppUser implements Serializable {
    private static final long serialVersionUID = 1L;

    private int userId;
    private String username;
    private String passHash;
    private String fullName;
    private String email;
    private String phone;
    private int roleId;
    private String roleCode;
    private String roleName;
    private boolean locked;
    private Timestamp createdAt;

    public AppUser() {
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

    public String getPassHash() {
        return passHash;
    }

    public void setPassHash(String passHash) {
        this.passHash = passHash;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getRoleCode() {
        return roleCode;
    }

    public void setRoleCode(String roleCode) {
        this.roleCode = roleCode;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public boolean isLocked() {
        return locked;
    }

    public void setLocked(boolean locked) {
        this.locked = locked;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    // Cac ham tien ich kiem tra vai tro
    public boolean isAdmin() {
        return "ADMIN".equalsIgnoreCase(roleCode);
    }

    public boolean isCatalogManager() {
        return "CATALOG_MANAGER".equalsIgnoreCase(roleCode);
    }

    public boolean isOperator() {
        return "OPERATOR".equalsIgnoreCase(roleCode);
    }

    public boolean isReviewer() {
        return "REVIEWER".equalsIgnoreCase(roleCode);
    }

    public boolean isViewer() {
        return "VIEWER".equalsIgnoreCase(roleCode);
    }
}
