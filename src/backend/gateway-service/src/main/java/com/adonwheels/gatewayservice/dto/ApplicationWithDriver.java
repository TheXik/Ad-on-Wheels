package com.adonwheels.gatewayservice.dto;

public record ApplicationWithDriver(
        Long id,
        Long campaignId,
        String campaignName,
        String status,
        Driver driver
) {}
