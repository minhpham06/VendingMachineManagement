package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class VendProduct implements Serializable {
    private static final long serialVersionUID = 1L;

    private int productId;
    private String code;
    private String name;
    private double nominalWeight;
    private double tolerance;
    private double price;
    private String note;
    private boolean active;
    private Timestamp createdAt;

    public VendProduct() {
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getNominalWeight() {
        return nominalWeight;
    }

    public void setNominalWeight(double nominalWeight) {
        this.nominalWeight = nominalWeight;
    }

    public double getTolerance() {
        return tolerance;
    }

    public void setTolerance(double tolerance) {
        this.tolerance = tolerance;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
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
