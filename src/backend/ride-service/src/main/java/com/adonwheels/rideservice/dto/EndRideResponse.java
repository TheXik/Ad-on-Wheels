package com.adonwheels.rideservice.dto;

public class EndRideResponse {

    private final Long completedRideId;
    private final double totalDistanceKm;
    private final long durationSeconds;

    public EndRideResponse(Long completedRideId, double totalDistanceKm, long durationSeconds) {
        this.completedRideId = completedRideId;
        this.totalDistanceKm = totalDistanceKm;
        this.durationSeconds = durationSeconds;
    }

    public Long getCompletedRideId() {
        return completedRideId;
    }

    public double getTotalDistanceKm() {
        return totalDistanceKm;
    }

    public long getDurationSeconds() {
        return durationSeconds;
    }
}
