package com.example.driverservice.dto;

import jakarta.validation.constraints.NotNull;

public class StopRideRequest {

    @NotNull(message = "Driver ID is required")
    private Long driverId;

    private String endLocation; // Optional

    public StopRideRequest() {
    }

    public StopRideRequest(Long driverId) {
        this.driverId = driverId;
    }

    // Getters and Setters
    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
    }

    public String getEndLocation() {
        return endLocation;
    }

    public void setEndLocation(String endLocation) {
        this.endLocation = endLocation;
    }
}
