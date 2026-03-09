package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.NotBlank;

public class StartRideRequest {

    @NotBlank(message = "driverId must not be blank")
    private String driverId;

    public StartRideRequest() {
    }

    public String getDriverId() {
        return driverId;
    }

    public void setDriverId(String driverId) {
        this.driverId = driverId;
    }
}
