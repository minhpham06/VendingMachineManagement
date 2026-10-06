package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class VendRestock implements Serializable {
    private static final long serialVersionUID = 1L;

    private int restockId;
    private String code;
    private int slotId;
    private String slotCode;
    private Integer productId;
    private String productName;
    private int quantity;
    private int restockedBy;
    private String restockedByName;
    private String note;
    private boolean active;
    private Timestamp createdAt;

    public VendRestock() {
    }

    public int getRestockId() {
        return restockId;
    }

    public void setRestockId(int restockId) {
        this.restockId = restockId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public int getSlotId() {
        return slotId;
    }

    public void setSlotId(int slotId) {
        this.slotId = slotId;
    }

    public String getSlotCode() {
        return slotCode;
    }

    public void setSlotCode(String slotCode) {
        this.slotCode = slotCode;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getRestockedBy() {
        return restockedBy;
    }

    public void setRestockedBy(int restockedBy) {
        this.restockedBy = restockedBy;
    }

    public String getRestockedByName() {
        return restockedByName;
    }

    public void setRestockedByName(String restockedByName) {
        this.restockedByName = restockedByName;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
