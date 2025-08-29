package com.adonwheels.authservice.service;

import com.adonwheels.authservice.dto.*;
import com.adonwheels.authservice.model.Role;
import com.adonwheels.authservice.model.User;
import com.adonwheels.authservice.repository.AuthRepository;
import dto.ApiResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class AuthService {

    @Autowired
    private AuthRepository repository;
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private WebClient.Builder webClientBuilder;

    @Value("${services.driver-service.url}")
    private String driverServiceUrl;

    @Value("${services.company-service.url}")
    private String companyServiceUrl;


    private final Logger logger = LoggerFactory.getLogger(getClass());
    private final  JWTService JWTService;
    private final AuthenticationManager authenticationManager;

    public AuthService(AuthenticationManager authenticationManager,  JWTService JWTService) {
        this.authenticationManager = authenticationManager;
        this.JWTService = JWTService;
    }


    /**
     * This method is called by the RegistrationSagaOrchestrator AFTER the profile has been created.
     * It handles the final step of saving the user to the database.
     */
    public User saveUserWithProfile(RegistrationRequest request, Long profileId) {
        User newUser = new User();
        newUser.setEmail(request.email());
        newUser.setPassword(passwordEncoder.encode(request.password()));
        newUser.setRole(request.role());
        newUser.setProfileId(profileId);
        return repository.save(newUser);
    }

    /**
     * Creates a profile in the appropriate service (driver or company) using WebClient.
     * This is a step in the registration saga.
     */
    public Long createProfile(String name, String email, Role role) {
        String url;
        ProfileRequest requestBody = new ProfileRequest(name, email);

        if (role == Role.DRIVER) {
            url = driverServiceUrl + "/drivers";
        } else if (role == Role.COMPANY) {
            url = companyServiceUrl + "/companies";
        } else {
            throw new IllegalArgumentException("Invalid role for profile creation");
        }
        logger.info("Creating profile with body {}", requestBody);
        ApiResponse<ProfileResponse> apiResponse = webClientBuilder.build().post()
                .uri(url)
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<ProfileResponse>>() {})
                .block();

        logger.info("Profile response {}", apiResponse);
        if (apiResponse != null && apiResponse.isSuccess() && apiResponse.getData() != null && apiResponse.getData().id() != null) {
            logger.info("Profile created with id {}", apiResponse.getData().id());
            return apiResponse.getData().id();
        } else {
            logger.info("Profile creation failed");
            throw new IllegalStateException("Failed to create profile or received an empty response.");
        }
    }


    /**
     * Compensating transaction for the saga. Deletes a profile if the saga fails.
     */
    public void deleteProfile(Long profileId, Role role) {
        String url;
        if (role == Role.DRIVER) {
            url = driverServiceUrl + "/drivers/{id}";
        } else if (role == Role.COMPANY) {
            url = companyServiceUrl + "/companies/{id}";
        } else {
            logger.error("Cannot delete profile. Invalid role: {}", role);
            return;
        }

        webClientBuilder.build().delete()
                .uri(url, profileId)
                .retrieve()
                .toBodilessEntity()
                .doOnSuccess(response -> logger.info("Successfully rolled back profile for ID: {}", profileId))
                .doOnError(error -> logger.error("CRITICAL: Failed to roll back profile for ID: {}. Reason: {}", profileId, error.getMessage()))
                .retry(3) // retry on failure
                .block(); // Block to ensure completion in the saga pattern
    }


    /**
     * Verifies user credentials and generates a JWT token upon successful authentication.
     */
    public LoginResponse verify(LoginRequest loginRequest) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.email(), loginRequest.password())
        );
        return new LoginResponse(JWTService.generateToken(loginRequest.email()), "Token Generated");
    }
}