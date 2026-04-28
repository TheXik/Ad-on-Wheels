package com.adonwheels.authservice.controller;

import com.adonwheels.authservice.dto.*;
import com.adonwheels.authservice.service.AuthService;
import com.adonwheels.authservice.service.RegistrationSagaOrchestratorService;
import com.adonwheels.dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;
    private final RegistrationSagaOrchestratorService registrationSagaOrchestratorService;

    public AuthController(AuthService authService, RegistrationSagaOrchestratorService registrationSagaOrchestratorService) {
        this.authService = authService;
        this.registrationSagaOrchestratorService = registrationSagaOrchestratorService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<RegistrationResponse>> register(@Valid @RequestBody RegistrationRequest request) {
        RegistrationResponse registrationData = registrationSagaOrchestratorService.register(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(registrationData));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest loginRequest) {
        LoginResponse loginData = authService.verify(loginRequest);
        LoginResponse loginResponseData = new LoginResponse(loginData.token(), "User successfully logged in");

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(loginResponseData));
    }

    @PostMapping("/google")
    public ResponseEntity<ApiResponse<LoginResponse>> googleLogin(@Valid @RequestBody GoogleLoginRequest request) {
        LoginResponse loginData = authService.loginWithGoogle(request);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(loginData));
    }
}
