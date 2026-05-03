package com.adonwheels.rideservice.dto;

public record RideStatisticsResponse(
        Long totalRides,
        Long completedRides,
        Integer totalDurationSeconds,
        Double totalDistanceKm,
        Double weeklyDistanceKm,
        Double monthlyDistanceKm,
        Double totalEarnings,
        Double weeklyEarnings,
        Double monthlyEarnings,
        Double averageSpeedKmh
) {}
