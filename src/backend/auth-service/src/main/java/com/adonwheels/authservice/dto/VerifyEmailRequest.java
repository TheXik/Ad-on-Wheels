package com.adonwheels.authservice.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record VerifyEmailRequest(
    @NotBlank
    @Email(regexp = "^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$",
           message = "Please provide a valid email address")
    String email,
    @NotBlank String code
) {}
