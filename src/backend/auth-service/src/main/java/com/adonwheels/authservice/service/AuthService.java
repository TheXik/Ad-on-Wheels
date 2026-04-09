package com.adonwheels.authservice.service;

import com.adonwheels.authservice.dto.*;
import com.adonwheels.authservice.model.Role;
import com.adonwheels.authservice.model.User;
import com.adonwheels.authservice.repository.AuthRepository;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import dto.ApiResponse;
import dto.AppErrorCode;
import dto.exception.BusinessException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.Arrays;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

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

    @Value("${google.client-ids}")
    private String googleClientIdsRaw;

    private final Logger logger = LoggerFactory.getLogger(getClass());
    private final  JWTService JWTService;
    private final AuthenticationManager authenticationManager;

    public AuthService(AuthenticationManager authenticationManager,  JWTService JWTService) {
        this.authenticationManager = authenticationManager;
        this.JWTService = JWTService;
    }

    /**
     * Checks if an email already exists in the database.
     * This is called BEFORE creating a profile to prevent orphaned records.
     */
    public boolean emailExists(String email) {
        return repository.findByEmail(email).isPresent();
    }

    public Optional<User> findByEmail(String email) {
        return repository.findByEmail(email);
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
            throw new BusinessException(AppErrorCode.VALIDATION_ERROR, "Invalid role provided: " + role);
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
            throw new BusinessException(AppErrorCode.SERVICE_UNAVAILABLE, "Profile creation failed in remote service");
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
        if (loginRequest.expectedRole() != null) {
            User user = repository.findByEmail(loginRequest.email())
                    .orElseThrow(() -> new BusinessException(AppErrorCode.USER_NOT_FOUND, "No account found with this email"));
            if (user.getRole() != loginRequest.expectedRole()) {
                throw new BusinessException(AppErrorCode.ROLE_MISMATCH, user.getRole().name());
            }
        }
        return new LoginResponse(JWTService.generateToken(loginRequest.email()), "Token Generated");
    }

    /**
     * Generates a JWT token for a newly registered user without requiring authentication.
     * This is used for auto-login after successful registration.
     */
    public String generateTokenForNewUser(String email) {
        return JWTService.generateToken(email);
    }

    public LoginResponse loginWithGoogle(GoogleLoginRequest request) {
        GoogleIdToken.Payload payload = verifyGoogleIdToken(request.idToken());
        String email = payload.getEmail();

        Optional<User> existing = repository.findByEmail(email);
        if (existing.isPresent()) {
            User user = existing.get();
            if (user.getRole() != request.role()) {
                throw new BusinessException(AppErrorCode.ROLE_MISMATCH, user.getRole().name());
            }
            String token = JWTService.generateToken(email);
            return new LoginResponse(token, "Google sign-in successful");
        }

        String name = (String) payload.get("name");
        if (name == null || name.isBlank()) name = email;
        Role role = request.role();

        Long profileId = null;
        try {
            profileId = createProfile(name, email, role);

            User user = new User();
            user.setEmail(email);
            user.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
            user.setRole(role);
            user.setProfileId(profileId);
            repository.save(user);

            String token = JWTService.generateToken(email);
            return new LoginResponse(token, "Google sign-in successful");
        } catch (Exception e) {
            if (profileId != null) {
                try { deleteProfile(profileId, role); } catch (Exception ignored) {}
            }
            throw e;
        }
    }

    private GoogleIdToken.Payload verifyGoogleIdToken(String idTokenString) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Arrays.stream(googleClientIdsRaw.split(","))
                            .map(String::trim)
                            .filter(s -> !s.isEmpty())
                            .collect(Collectors.toList()))
                    .build();

            GoogleIdToken idToken = verifier.verify(idTokenString);
            if (idToken == null) {
                throw new BusinessException(AppErrorCode.INVALID_CREDENTIALS, "Invalid Google ID token");
            }
            return idToken.getPayload();
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            logger.error("Google token verification failed", e);
            throw new BusinessException(AppErrorCode.INVALID_CREDENTIALS, "Google token verification failed");
        }
    }
}