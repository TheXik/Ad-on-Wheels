package com.adonwheels.rideservice.model;

import org.springframework.data.cassandra.core.mapping.Column;
import org.springframework.data.cassandra.core.mapping.UserDefinedType;

import java.time.LocalDateTime;

@UserDefinedType("location_point")
public class LocationPoint {

    private double lat;
    private double lon;

    @Column("captured_at")
    private LocalDateTime capturedAt;

    public LocationPoint() {
    }

    public LocationPoint(double lat, double lon, LocalDateTime capturedAt) {
        this.lat = lat;
        this.lon = lon;
        this.capturedAt = capturedAt;
    }

    public double getLat() {
        return lat;
    }

    public double getLon() {
        return lon;
    }

    public LocalDateTime getCapturedAt() {
        return capturedAt;
    }
}
