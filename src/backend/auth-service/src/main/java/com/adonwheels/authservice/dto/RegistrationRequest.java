package com.adonwheels.authservice.dto;

import com.adonwheels.authservice.model.Role;
import com.adonwheels.dto.validation.NoHtml;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record RegistrationRequest(
        @NotBlank(message = "Email cannot be empty")
        @Email(message = "Please provide a valid email address",
               regexp = "^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$")
        String email,

        @NotBlank(message = "Password cannot be empty")
        @Size(min = 8, max = 50, message = "Password must be between 8 and 30 characters")
        String password,

        @NotBlank(message = "Name cannot be empty")
        @NoHtml
        String name,

        @NotNull(message = "Role must be specified")
        Role role
) {
}