package com.adonwheels.authservice.dto;
import com.adonwheels.authservice.model.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        @NotBlank(message = "Email cannot be empty")
        @Email(message = "Please provide a valid email address",
               regexp = "^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$")
        String email,

        @NotBlank(message = "Password cannot be empty")
        String password,

        Role expectedRole
) {
}