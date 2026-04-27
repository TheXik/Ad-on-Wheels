package com.adonwheels.gatewayservice.dto;

/**
 * Coordinate emitted by the coverage / heat-map aggregator. Mirrors the
 * {@code RoutePointDto} returned by ride-service. Timestamp may be null
 * for legacy rides whose stored route only contains lat / lon.
 */
public class RoutePoint {
    private double lat;
    private double lon;
    private Long timestamp;

    public RoutePoint() {
    }

    public RoutePoint(double lat, double lon, Long timestamp) {
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
