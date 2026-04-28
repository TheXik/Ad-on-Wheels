package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class StartRideRequest {

    @NotBlank(message = "driverId must not be blank")
    private String driverId;

    @NotNull(message = "campaignId is required: a ride must be tied to an accepted campaign (UC01 precondition)")
    private Long campaignId;

    private Double ratePerKm;

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

    public Double getRatePerKm() {
        return ratePerKm;
    }

    public void setRatePerKm(Double ratePerKm) {
        this.ratePerKm = ratePerKm;
    }
}
