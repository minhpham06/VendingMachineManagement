package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class VendSession implements Serializable {
    private static final long serialVersionUID = 1L;

    private int sessionId;
    private int deviceId;
    private int slotId;
    private String slotCode;
    private String productName;
    private double nominalWeight;
    private double tolerance;
    private int deviceSeq;
    private Timestamp measuredAt;
    private Timestamp ingestedAt;
    private double weightBefore;
    private double weightAfter;
    private double weightDelta;
    private int coilTurns;
    private int motorMs;
    private int settleMs;
    private double peakDelta;
    private boolean sample;

    // Latest label information
    private String currentLabel;
    private String labelSource;
    private String labelReason;
    private String reviewerName;

    public VendSession() {
    }

    public int getSessionId() {
        return sessionId;
    }

    public void setSessionId(int sessionId) {
        this.sessionId = sessionId;
    }

    public int getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(int deviceId) {
        this.deviceId = deviceId;
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

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
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

    public int getDeviceSeq() {
        return deviceSeq;
    }

    public void setDeviceSeq(int deviceSeq) {
        this.deviceSeq = deviceSeq;
    }

    public Timestamp getMeasuredAt() {
        return measuredAt;
    }

    public void setMeasuredAt(Timestamp measuredAt) {
        this.measuredAt = measuredAt;
    }

    public Timestamp getIngestedAt() {
        return ingestedAt;
    }

    public void setIngestedAt(Timestamp ingestedAt) {
        this.ingestedAt = ingestedAt;
    }

    public double getWeightBefore() {
        return weightBefore;
    }

    public void setWeightBefore(double weightBefore) {
        this.weightBefore = weightBefore;
    }

    public double getWeightAfter() {
        return weightAfter;
    }

    public void setWeightAfter(double weightAfter) {
        this.weightAfter = weightAfter;
    }

    public double getWeightDelta() {
        return weightDelta;
    }

    public void setWeightDelta(double weightDelta) {
        this.weightDelta = weightDelta;
    }

    public int getCoilTurns() {
        return coilTurns;
    }

    public void setCoilTurns(int coilTurns) {
        this.coilTurns = coilTurns;
    }

    public int getMotorMs() {
        return motorMs;
    }

    public void setMotorMs(int motorMs) {
        this.motorMs = motorMs;
    }

    public int getSettleMs() {
        return settleMs;
    }

    public void setSettleMs(int settleMs) {
        this.settleMs = settleMs;
    }

    public double getPeakDelta() {
        return peakDelta;
    }

    public void setPeakDelta(double peakDelta) {
        this.peakDelta = peakDelta;
    }

    public boolean isSample() {
        return sample;
    }

    public void setSample(boolean sample) {
        this.sample = sample;
    }

    public String getCurrentLabel() {
        return currentLabel;
    }

    public void setCurrentLabel(String currentLabel) {
        this.currentLabel = currentLabel;
    }

    public String getLabelSource() {
        return labelSource;
    }

    public void setLabelSource(String labelSource) {
        this.labelSource = labelSource;
    }

    public String getLabelReason() {
        return labelReason;
    }

    public void setLabelReason(String labelReason) {
        this.labelReason = labelReason;
    }

    public String getReviewerName() {
        return reviewerName;
    }

    public void setReviewerName(String reviewerName) {
        this.reviewerName = reviewerName;
    }
}
