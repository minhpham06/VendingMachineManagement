package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class RejectedPacket implements Serializable {
    private static final long serialVersionUID = 1L;

    private int rejectId;
    private Integer deviceId;
    private String rawPayload;
    private String reason;
    private Timestamp receivedAt;

    public RejectedPacket() {
    }

    public int getRejectId() {
        return rejectId;
    }

    public void setRejectId(int rejectId) {
        this.rejectId = rejectId;
    }

    public Integer getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(Integer deviceId) {
        this.deviceId = deviceId;
    }

    public String getRawPayload() {
        return rawPayload;
    }

    public void setRawPayload(String rawPayload) {
        this.rawPayload = rawPayload;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Timestamp getReceivedAt() {
        return receivedAt;
    }

    public void setReceivedAt(Timestamp receivedAt) {
        this.receivedAt = receivedAt;
    }
}
