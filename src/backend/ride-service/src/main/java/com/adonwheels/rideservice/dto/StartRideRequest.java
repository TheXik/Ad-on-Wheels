package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.NotBlank;

public class StartRideRequest {

    @NotBlank(message = "driverId must not be blank")
    private String driverId;

    private Long campaignId;

    public StartRideRequest() {
    }

    public String getDriverId() {
        return driverId;
    }

    public void setDriverId(String driverId) {
        this.driverId = driverId;
    }

    public Long getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(Long campaignId) {
        this.campaignId = campaignId;
    }
}
