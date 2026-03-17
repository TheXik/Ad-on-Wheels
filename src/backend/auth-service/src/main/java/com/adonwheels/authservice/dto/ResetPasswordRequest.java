package com.adonwheels.authservice.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(
    @NotBlank @Email String email,
    @NotBlank String resetCode,
    @NotBlank @Size(min = 6, message = "Password must be at least 6 characters") String newPassword
) {}
