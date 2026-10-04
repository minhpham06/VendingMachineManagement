package model;

import java.io.Serializable;

public class AppRole implements Serializable {
    private static final long serialVersionUID = 1L;

    private int roleId;
    private String roleCode;
    private String roleName;
    private String description;

    public AppRole() {
    }

    public AppRole(int roleId, String roleCode, String roleName, String description) {
        this.roleId = roleId;
        this.roleCode = roleCode;
        this.roleName = roleName;
        this.description = description;
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return roleName + " (" + roleCode + ")";
    }
}
