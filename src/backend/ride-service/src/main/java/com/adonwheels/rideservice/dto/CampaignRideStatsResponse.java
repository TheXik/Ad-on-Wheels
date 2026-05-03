package com.adonwheels.rideservice.dto;

public record CampaignRideStatsResponse(
        Long campaignId,
        long totalRides,
        double totalDistanceKm,
        long totalDurationSeconds,
        double totalEarnings,
        long activeDriverCount
) {}
