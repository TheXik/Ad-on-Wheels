package com.adonwheels.authservice.service;

import com.adonwheels.authservice.dto.*;
import com.adonwheels.authservice.model.Role;
import com.adonwheels.authservice.model.User;
import com.adonwheels.authservice.repository.AuthRepository;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.adonwheels.dto.ApiResponse;
import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.util.Arrays;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    private final AuthRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final WebClient.Builder webClientBuilder;
    private final AuthenticationManager authenticationManager;
    private final JWTService jwtService;

    @Value("${services.driver-service.url}")
    private String driverServiceUrl;

    @Value("${services.company-service.url}")
    private String companyServiceUrl;

    @Value("${google.client-ids}")
    private String googleClientIdsRaw;

    public AuthService(
            AuthRepository repository,
            PasswordEncoder passwordEncoder,
            WebClient.Builder webClientBuilder,
            AuthenticationManager authenticationManager,
            JWTService jwtService) {
        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
        this.webClientBuilder = webClientBuilder;
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
    }

    public Optional<User> findByEmail(String email) {
        return repository.findByEmail(email);
    }

    public User saveUserWithProfile(RegistrationRequest request, Long profileId) {
        User newUser = new User();
        newUser.setEmail(request.email());
        newUser.setPassword(passwordEncoder.encode(request.password()));
        newUser.setRole(request.role());
        newUser.setProfileId(profileId);
        return repository.save(newUser);
    }

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

        ApiResponse<ProfileResponse> apiResponse = webClientBuilder.build().post()
                .uri(url)
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<ProfileResponse>>() {})
                .block();

        if (apiResponse != null && apiResponse.isSuccess() && apiResponse.getData() != null && apiResponse.getData().id() != null) {
            return apiResponse.getData().id();
        } else {
            throw new BusinessException(AppErrorCode.SERVICE_UNAVAILABLE, "Profile creation failed in remote service");
        }
    }

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
                .retryWhen(Retry.backoff(3, Duration.ofMillis(200)).maxBackoff(Duration.ofSeconds(2)))
                .block();
    }

    public LoginResponse verify(LoginRequest loginRequest) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.email(), loginRequest.password())
        );
        User user = repository.findByEmail(loginRequest.email())
                .orElseThrow(() -> new BusinessException(AppErrorCode.USER_NOT_FOUND, "No account found with this email"));
        if (loginRequest.expectedRole() != null && user.getRole() != loginRequest.expectedRole()) {
            throw new BusinessException(AppErrorCode.ROLE_MISMATCH, user.getRole().name());
        }
        return new LoginResponse(jwtService.generateToken(user));
    }

    public String generateTokenForNewUser(User user) {
        return jwtService.generateToken(user);
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
            String token = jwtService.generateToken(user);
            return new LoginResponse(token);
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
            User saved = repository.save(user);

            String token = jwtService.generateToken(saved);
            return new LoginResponse(token);
        } catch (Exception e) {
            if (profileId != null) {
                try {
                    deleteProfile(profileId, role);
                } catch (Exception rollbackEx) {
                    logger.error("Rollback failed for profile ID: {}. May require manual cleanup.", profileId, rollbackEx);
                }
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
