package com.adonwheels.authservice.dto;

import com.adonwheels.authservice.model.Role;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record GoogleLoginRequest(
        @NotBlank(message = "ID token cannot be empty")
        String idToken,

        @NotNull(message = "Role must be specified")
        Role role
) {}
