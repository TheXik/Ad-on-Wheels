package com.adonwheels.rideservice.dto;

import java.time.LocalDateTime;

public record ActiveRideResponse(
        Long id,
        Long driverId,
        LocalDateTime startTime,
        String status
) {
    public static ActiveRideResponse active(Long driverId, LocalDateTime startTime) {
        return new ActiveRideResponse(driverId, driverId, startTime, "ACTIVE");
    }
}
