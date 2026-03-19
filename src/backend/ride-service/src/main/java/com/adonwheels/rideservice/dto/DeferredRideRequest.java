package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

/**
 * Request for logging a ride that was started without a QR scan.
 * The app provides buffered GPS points collected in the background,
 * and the backend reconstructs the ride from that data.
 */
public class DeferredRideRequest {

    @NotBlank(message = "driverId must not be blank")
    private String driverId;

    @NotEmpty(message = "locationPoints must not be empty")
    private List<LocationPointDto> locationPoints;

    public DeferredRideRequest() {
    }

    public String getDriverId() {
        return driverId;
    }

    public void setDriverId(String driverId) {
        this.driverId = driverId;
    }

    public List<LocationPointDto> getLocationPoints() {
        return locationPoints;
    }

    public void setLocationPoints(List<LocationPointDto> locationPoints) {
        this.locationPoints = locationPoints;
    }

    public static class LocationPointDto {
        private double lat;
        private double lon;
        private String capturedAt; // ISO-8601 timestamp

        public LocationPointDto() {
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

        public String getCapturedAt() {
            return capturedAt;
        }

        public void setCapturedAt(String capturedAt) {
            this.capturedAt = capturedAt;
        }
    }
}
