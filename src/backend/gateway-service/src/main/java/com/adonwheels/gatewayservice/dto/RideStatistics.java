package com.adonwheels.gatewayservice.dto;

public record RideStatistics(
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
