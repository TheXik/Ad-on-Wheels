package com.adonwheels.gatewayservice.dto;

import java.util.List;

/**
 * One ride's contribution to a campaign coverage map. The {@code verified}
 * flag drives the styling on the client (solid for verified rides,
 * dashed/lighter for unverified ones).
 */
public class RideRoute {
    private Long rideId;
    private Long driverId;
    private boolean verified;
    private List<RoutePoint> route;

    public RideRoute() {
    }

    public RideRoute(Long rideId, Long driverId, boolean verified, List<RoutePoint> route) {
        this.rideId = rideId;
        this.driverId = driverId;
        this.verified = verified;
        this.route = route;
    }

    public Long getRideId() { return rideId; }
    public void setRideId(Long rideId) { this.rideId = rideId; }

    public Long getDriverId() { return driverId; }
    public void setDriverId(Long driverId) { this.driverId = driverId; }

    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }

    public List<RoutePoint> getRoute() { return route; }
    public void setRoute(List<RoutePoint> route) { this.route = route; }
}
