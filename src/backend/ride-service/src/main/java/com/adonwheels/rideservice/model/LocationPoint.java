package com.adonwheels.rideservice.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * A single GPS snapshot captured during an active ride.
 * {@code @NoArgsConstructor} is required for Jackson deserialization from Redis JSON.
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class LocationPoint {
    private double lat;
    private double lon;
    private LocalDateTime capturedAt;
}
