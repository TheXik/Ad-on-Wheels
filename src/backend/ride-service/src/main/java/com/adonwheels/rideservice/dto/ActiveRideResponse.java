package com.adonwheels.rideservice.dto;

import java.time.LocalDateTime;

public class ActiveRideResponse {

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
    private Double distanceKm;
    private Double averageSpeedKmh;
    private Double earnings;

    public ActiveRideResponse(Long driverId, LocalDateTime startTime) {
        this.id = driverId;
        this.driverId = driverId;
        this.startTime = startTime;
        this.status = "ACTIVE";
    }

    public Long getId() { return id; }
    public Long getDriverId() { return driverId; }
    public Long getCampaignId() { return campaignId; }
    public LocalDateTime getStartTime() { return startTime; }
    public LocalDateTime getEndTime() { return endTime; }
    public String getStartLocation() { return startLocation; }
    public String getEndLocation() { return endLocation; }
    public Integer getDuration() { return duration; }
    public String getQrCodeData() { return qrCodeData; }
    public String getStatus() { return status; }
    public Double getDistanceKm() { return distanceKm; }
    public Double getAverageSpeedKmh() { return averageSpeedKmh; }
    public Double getEarnings() { return earnings; }
}
