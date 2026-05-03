package com.adonwheels.gatewayservice.dto;

import java.time.LocalDateTime;
import java.util.List;

public record Ride(
        Long id,
        Long driverId,
        Long campaignId,
        LocalDateTime startTime,
        LocalDateTime endTime,
        Integer duration,
        String status,
        Double distanceKm,
        Double averageSpeedKmh,
        Double earnings,
        Double startLat,
        Double startLon,
        Double endLat,
        Double endLon,
        List<LatLng> trackPoints,
        Boolean verified
) {}
