package com.adonwheels.authservice.controller;


import com.adonwheels.authservice.dto.LoginResponse;
import com.adonwheels.authservice.dto.RegistrationRequest;
import com.adonwheels.authservice.dto.RegistrationResponse;
import com.adonwheels.authservice.exception.RegistrationException;
import com.adonwheels.authservice.model.Role;
import com.adonwheels.authservice.model.User;
import com.adonwheels.authservice.service.AuthService;
import com.adonwheels.authservice.service.RegistrationSagaOrchestratorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
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


    /// This firstly create a dto object that will be sent to the driver/company service based on the user role
    /// it returns the profileID of the user that we created and now it creates the user with the password in the auth
    /// service database
    @PostMapping("/register")
    public ResponseEntity<RegistrationResponse> register(@RequestBody RegistrationRequest request) {

        User newUser = registrationSagaOrchestratorService.register(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(new RegistrationResponse (newUser.getId(),"User registered successfully"));
    }

    @PostMapping("/login")
    public LoginResponse login(@RequestBody User user) {
        return authService.verify(user);
    }


}
