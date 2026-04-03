package com.adonwheels.authservice.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(
    @NotBlank
    @Email(regexp = "^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$",
           message = "Please provide a valid email address")
    String email,
    @NotBlank String resetCode,
    @NotBlank @Size(min = 6, message = "Password must be at least 6 characters") String newPassword
) {}
