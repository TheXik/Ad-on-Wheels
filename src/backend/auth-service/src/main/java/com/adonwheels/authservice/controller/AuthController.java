package com.adonwheels.authservice.controller;

import com.adonwheels.authservice.dto.LoginRequest;
import com.adonwheels.authservice.dto.LoginResponse;
import com.adonwheels.authservice.dto.RegistrationRequest;
import com.adonwheels.authservice.dto.RegistrationResponse;
import com.adonwheels.authservice.service.AuthService;
import com.adonwheels.authservice.service.RegistrationSagaOrchestratorService;
import dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @Autowired
    private RegistrationSagaOrchestratorService registrationSagaOrchestratorService;


    /// This method calls the SAGA orchestrator which takes care of creating UserProfile
    /// valid anotation chcecks if the dto RegistrationRequest have correctFields
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<RegistrationResponse>> register(@Valid @RequestBody RegistrationRequest request) {
        registrationSagaOrchestratorService.register(request);
        RegistrationResponse registrationData = new RegistrationResponse("User registered successfully");

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(registrationData));
    }

    /// valid anotation chcecks if the dto LoginRequests have correctFields
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest loginRequest) {
        LoginResponse loginData = authService.verify(loginRequest);
        LoginResponse loginResponseData = new LoginResponse(loginData.token(), "User successfully logged in");

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(loginResponseData));
    }


}
