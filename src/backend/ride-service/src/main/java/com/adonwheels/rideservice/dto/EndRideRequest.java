package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.NotBlank;

public class EndRideRequest {

    @NotBlank(message = "rideId must not be blank")
    private String rideId;

    public EndRideRequest() {
    }

    public String getRideId() {
        return rideId;
    }

    public void setRideId(String rideId) {
        this.rideId = rideId;
    }
}
