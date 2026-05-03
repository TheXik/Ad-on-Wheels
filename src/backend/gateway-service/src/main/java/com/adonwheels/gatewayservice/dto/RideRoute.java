package com.adonwheels.gatewayservice.dto;

import java.util.List;

public record RideRoute(
        Long rideId,
        Long driverId,
        boolean verified,
        List<RoutePoint> route
) {}
