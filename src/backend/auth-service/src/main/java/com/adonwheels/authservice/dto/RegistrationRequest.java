package com.adonwheels.authservice.dto;

import com.adonwheels.authservice.model.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record RegistrationRequest(
        @NotBlank(message = "Email cannot be empty")
        @Email(message = "Please provide a valid email address")
        String email,

        @NotBlank(message = "Password cannot be empty")
        @Size(min = 8, message = "Password must be at least 8 characters long")
        String password,

        @NotBlank(message = "Name cannot be empty")
        String name,

        @NotNull(message = "Role must be specified")
        Role role
) {
}