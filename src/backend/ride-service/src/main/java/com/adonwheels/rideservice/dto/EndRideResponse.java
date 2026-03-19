package com.adonwheels.rideservice.dto;

public class EndRideResponse {

    private final double totalDistanceKm;
    private final long durationSeconds;

    public EndRideResponse(double totalDistanceKm, long durationSeconds) {
        this.totalDistanceKm = totalDistanceKm;
        this.durationSeconds = durationSeconds;
    }

    public double getTotalDistanceKm() {
        return totalDistanceKm;
    }

    public long getDurationSeconds() {
        return durationSeconds;
    }
}
