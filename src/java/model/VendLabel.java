package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class VendLabel implements Serializable {
    private static final long serialVersionUID = 1L;

    private int labelId;
    private int sessionId;
    private String labelCode; // 'SUCCESS', 'JAM', 'WRONG_ITEM', 'MOTOR_FAIL'
    private String source; // 'SYSTEM', 'REVIEWER'
    private Integer reviewerId;
    private String reviewerName;
    private String reason;
    private Timestamp labeledAt;

    public VendLabel() {
    }

    public int getLabelId() {
        return labelId;
    }

    public void setLabelId(int labelId) {
        this.labelId = labelId;
    }

    public int getSessionId() {
        return sessionId;
    }

    public void setSessionId(int sessionId) {
        this.sessionId = sessionId;
    }

    public String getLabelCode() {
        return labelCode;
    }

    public void setLabelCode(String labelCode) {
        this.labelCode = labelCode;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public Integer getReviewerId() {
        return reviewerId;
    }

    public void setReviewerId(Integer reviewerId) {
        this.reviewerId = reviewerId;
    }

    public String getReviewerName() {
        return reviewerName;
    }

    public void setReviewerName(String reviewerName) {
        this.reviewerName = reviewerName;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Timestamp getLabeledAt() {
        return labeledAt;
    }

    public void setLabeledAt(Timestamp labeledAt) {
        this.labeledAt = labeledAt;
    }
}
