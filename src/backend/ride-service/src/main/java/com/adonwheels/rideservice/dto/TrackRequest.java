package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class TrackRequest {

    @NotBlank(message = "rideId must not be blank")
    private String rideId;

    @DecimalMin(value = "-90.0",  message = "lat must be >= -90")
    @DecimalMax(value = "90.0",   message = "lat must be <= 90")
    private double lat;

    @DecimalMin(value = "-180.0", message = "lon must be >= -180")
    @DecimalMax(value = "180.0",  message = "lon must be <= 180")
    private double lon;
}
