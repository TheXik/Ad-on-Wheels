package com.adonwheels.rideservice.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class StartRideRequest {

    @NotBlank(message = "driverId must not be blank")
    private String driverId;
}
