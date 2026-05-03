package com.adonwheels.driverservice.dto;

import com.adonwheels.dto.validation.NoHtml;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record VehicleRequest(
        @NotBlank(message = "License plate must not be blank")
        @Size(min = 2, max = 20, message = "License plate must be between 2 and 20 characters")
        @Pattern(regexp = "^[A-Z0-9 \\-]+$", message = "License plate may only contain uppercase letters, digits, spaces, and hyphens") String licensePlate,
        @NotBlank(message = "Vehicle make must not be blank") @NoHtml String make,
        @NotBlank(message = "Vehicle model must not be blank") @NoHtml String model,
        @NotBlank(message = "Vehicle year must not be blank")
        @Pattern(regexp = "^\\d{4}$", message = "Vehicle year must be a 4-digit number") String year
) {}
