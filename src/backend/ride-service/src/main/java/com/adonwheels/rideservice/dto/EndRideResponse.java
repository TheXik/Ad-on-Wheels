package com.adonwheels.rideservice.dto;

public record EndRideResponse(Long completedRideId, double totalDistanceKm, long durationSeconds) {}
