package com.adonwheels.rideservice.dto;

/**
 * Coordinate point used by the coverage / heat-map feature.
 * Timestamp is optional: legacy {@code routePointsJson} payloads store
 * only lat / lon, so {@code timestamp} may be {@code null} for older rides.
 */
public class RoutePointDto {

    private double lat;
    private double lon;
    private Long timestamp;

    public RoutePointDto() {
    }

    public RoutePointDto(double lat, double lon, Long timestamp) {
        this.lat = lat;
        this.lon = lon;
        this.timestamp = timestamp;
    }

    public double getLat() { return lat; }
    public void setLat(double lat) { this.lat = lat; }

    public double getLon() { return lon; }
    public void setLon(double lon) { this.lon = lon; }

    public Long getTimestamp() { return timestamp; }
    public void setTimestamp(Long timestamp) { this.timestamp = timestamp; }
}
