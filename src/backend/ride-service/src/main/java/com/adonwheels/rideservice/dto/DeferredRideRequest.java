package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

// Logs a ride started without a QR scan: the app provides buffered GPS points
// collected in the background and the backend reconstructs the ride.
public record DeferredRideRequest(
        @NotBlank(message = "driverId must not be blank") String driverId,
        Long campaignId,
        Double ratePerKm,
        @NotEmpty(message = "locationPoints must not be empty") List<LocationPointDto> locationPoints
) {
    public record LocationPointDto(double lat, double lon, String capturedAt) {}
}
