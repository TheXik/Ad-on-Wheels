package com.example.driverservice.dto;

import jakarta.validation.constraints.NotNull;

public class StartRideRequest {

    @NotNull(message = "Driver ID is required")
    private Long driverId;

    private Long campaignId; // Optional

    private String startLocation; // Optional

    public StartRideRequest() {
    }

    public StartRideRequest(Long driverId, Long campaignId) {
        this.driverId = driverId;
        this.campaignId = campaignId;
    }

    // Getters and Setters
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

    public String getStartLocation() {
        return startLocation;
    }

    public void setStartLocation(String startLocation) {
        this.startLocation = startLocation;
    }
}
