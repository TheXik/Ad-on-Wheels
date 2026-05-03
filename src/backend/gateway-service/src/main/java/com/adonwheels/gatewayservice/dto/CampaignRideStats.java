package com.adonwheels.gatewayservice.dto;

public record CampaignRideStats(
        Long campaignId,
        long totalRides,
        double totalDistanceKm,
        long totalDurationSeconds,
        double totalEarnings,
        long activeDriverCount
) {}
