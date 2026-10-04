package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class VendSession implements Serializable {
    private static final long serialVersionUID = 1L;

    private int sessionId;
    private int deviceId;
    private String deviceCode;
    private Integer slotId;
    private int deviceSeq;
    private Timestamp measuredAt;
    private Timestamp ingestedAt;
    private boolean sample;
    private String labelCode; // joined from Vend_Label table
    private double weightBefore;
    private double weightAfter;
    private double weightDelta;
    private int coilTurns;
    private int motorMs;
    private int settleMs;
    private double peakDelta;

    public int getSessionId() { return sessionId; }
    public void setSessionId(int v) { this.sessionId = v; }

    public int getDeviceId() { return deviceId; }
    public void setDeviceId(int v) { this.deviceId = v; }

    public String getDeviceCode() { return deviceCode; }
    public void setDeviceCode(String deviceCode) { this.deviceCode = deviceCode; }

    public Integer getSlotId() { return slotId; }
    public void setSlotId(Integer slotId) { this.slotId = slotId; }

    public int getDeviceSeq() { return deviceSeq; }
    public void setDeviceSeq(int v) { this.deviceSeq = v; }

    public Timestamp getMeasuredAt() { return measuredAt; }
    public void setMeasuredAt(Timestamp v) { this.measuredAt = v; }

    public Timestamp getIngestedAt() { return ingestedAt; }
    public void setIngestedAt(Timestamp v) { this.ingestedAt = v; }

    public boolean isSample() { return sample; }
    public void setSample(boolean v) { this.sample = v; }

    public String getLabelCode() { return labelCode; }
    public void setLabelCode(String v) { this.labelCode = v; }

    public double getWeightBefore() { return weightBefore; }
    public void setWeightBefore(double v) { this.weightBefore = v; }

    public double getWeightAfter() { return weightAfter; }
    public void setWeightAfter(double v) { this.weightAfter = v; }

    public double getWeightDelta() { return weightDelta; }
    public void setWeightDelta(double v) { this.weightDelta = v; }

    public int getCoilTurns() { return coilTurns; }
    public void setCoilTurns(int v) { this.coilTurns = v; }

    public int getMotorMs() { return motorMs; }
    public void setMotorMs(int v) { this.motorMs = v; }

    public int getSettleMs() { return settleMs; }
    public void setSettleMs(int v) { this.settleMs = v; }

    public double getPeakDelta() { return peakDelta; }
    public void setPeakDelta(double v) { this.peakDelta = v; }
}
