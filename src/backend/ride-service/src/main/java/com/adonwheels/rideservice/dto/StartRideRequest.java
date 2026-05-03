package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record StartRideRequest(
        @NotBlank(message = "driverId must not be blank") String driverId,
        @NotNull(message = "campaignId is required: a ride must be tied to an accepted campaign (UC01 precondition)") Long campaignId,
        Double ratePerKm
) {}
