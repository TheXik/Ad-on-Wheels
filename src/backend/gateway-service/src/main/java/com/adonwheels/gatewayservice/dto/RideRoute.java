package com.adonwheels.gatewayservice.dto;

import java.util.List;

// One ride's contribution to a campaign coverage map. The verified flag drives
// styling on the client (solid for verified rides, dashed/lighter for unverified).
public record RideRoute(
        Long rideId,
        Long driverId,
        boolean verified,
        List<RoutePoint> route
) {}
