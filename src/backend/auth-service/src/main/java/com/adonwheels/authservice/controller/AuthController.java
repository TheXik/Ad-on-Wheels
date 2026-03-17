package com.adonwheels.authservice.controller;

import com.adonwheels.authservice.dto.*;
import com.adonwheels.authservice.service.AuthService;
import com.adonwheels.authservice.service.RegistrationSagaOrchestratorService;
import dto.ApiResponse;
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

    /** UC010/UC012: Request password reset code */
    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<String>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.generateResetToken(request.email());
        return ResponseEntity.ok(ApiResponse.success("Reset code sent to your email"));
    }

    /** UC010/UC012: Reset password with code */
    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<String>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request.email(), request.resetCode(), request.newPassword());
        return ResponseEntity.ok(ApiResponse.success("Password reset successful"));
    }

    /** UC009/UC011: Send email verification code */
    @PostMapping("/send-verification")
    public ResponseEntity<ApiResponse<String>> sendVerification(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.sendVerificationCode(request.email());
        return ResponseEntity.ok(ApiResponse.success("Verification code sent"));
    }

    /** UC009/UC011: Verify email with code */
    @PostMapping("/verify-email")
    public ResponseEntity<ApiResponse<String>> verifyEmail(@RequestBody VerifyEmailRequest request) {
        authService.verifyEmail(request.email(), request.code());
        return ResponseEntity.ok(ApiResponse.success("Email verified successfully"));
    }
}
