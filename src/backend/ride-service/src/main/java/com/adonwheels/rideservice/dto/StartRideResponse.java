package com.adonwheels.rideservice.dto;

public class StartRideResponse {

    private final String rideId;

    public StartRideResponse(String rideId) {
        this.rideId = rideId;
    }

    public String getRideId() {
        return rideId;
    }
}
