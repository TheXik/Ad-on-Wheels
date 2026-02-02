package com.example.gatewayservice.dto;

import java.time.LocalDateTime;

public class Ride {
    private Long id;
    private Long driverId;
    private Long campaignId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String startLocation;
    private String endLocation;
    private Integer duration;
    private String qrCodeData;
    private String status;

    public Ride() {
    }

    public Ride(Long id, Long driverId, Long campaignId, LocalDateTime startTime,
                LocalDateTime endTime, String startLocation, String endLocation,
                Integer duration, String qrCodeData, String status) {
        this.id = id;
        this.driverId = driverId;
        this.campaignId = campaignId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.startLocation = startLocation;
        this.endLocation = endLocation;
        this.duration = duration;
        this.qrCodeData = qrCodeData;
        this.status = status;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }

    public Long getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(Long campaignId) {
        this.campaignId = campaignId;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public String getStartLocation() {
        return startLocation;
    }

    public void setStartLocation(String startLocation) {
        this.startLocation = startLocation;
    }

    public String getEndLocation() {
        return endLocation;
    }

    public void setEndLocation(String endLocation) {
        this.endLocation = endLocation;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    public String getQrCodeData() {
        return qrCodeData;
    }

    public void setQrCodeData(String qrCodeData) {
        this.qrCodeData = qrCodeData;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
