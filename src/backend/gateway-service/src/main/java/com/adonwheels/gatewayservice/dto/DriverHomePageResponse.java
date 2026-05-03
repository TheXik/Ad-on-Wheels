package com.adonwheels.gatewayservice.dto;

public record DriverHomePageResponse(
        Driver driver,
        Ride activeRide,
        Campaign currentCampaign,
        RideStatistics statistics
) {}
