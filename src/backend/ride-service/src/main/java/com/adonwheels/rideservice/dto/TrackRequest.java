package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;

public class TrackRequest {

    @NotBlank(message = "rideId must not be blank")
    private String rideId;

    @DecimalMin(value = "-90.0",  message = "lat must be >= -90")
    @DecimalMax(value = "90.0",   message = "lat must be <= 90")
    private double lat;

    @DecimalMin(value = "-180.0", message = "lon must be >= -180")
    @DecimalMax(value = "180.0",  message = "lon must be <= 180")
    private double lon;

    public TrackRequest() {
    }

    public String getRideId() {
        return rideId;
    }

    public void setRideId(String rideId) {
        this.rideId = rideId;
    }

    public double getLat() {
        return lat;
    }

    public void setLat(double lat) {
        this.lat = lat;
    }

    public double getLon() {
        return lon;
    }

    public void setLon(double lon) {
        this.lon = lon;
    }
}
