package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.NotBlank;

public record EndRideRequest(
        @NotBlank(message = "rideId must not be blank") String rideId
) {}
