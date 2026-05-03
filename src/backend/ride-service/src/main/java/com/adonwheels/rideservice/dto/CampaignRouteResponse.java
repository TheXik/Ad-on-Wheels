package com.adonwheels.rideservice.dto;

import java.util.List;

public record CampaignRouteResponse(
        Long rideId,
        Long driverId,
        Double distanceKm,
        String status,
        Boolean verified,
        List<LatLng> trackPoints
) {}
