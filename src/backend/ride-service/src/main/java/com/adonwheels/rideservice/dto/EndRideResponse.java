package com.adonwheels.rideservice.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class EndRideResponse {
    private final double totalDistanceKm;
    private final long durationSeconds;
}
