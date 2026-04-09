package com.adonwheels.authservice.aspect;

import com.adonwheels.authservice.config.TestSecurityConfig;
import com.adonwheels.authservice.dto.LoginRequest;
import com.adonwheels.authservice.dto.RegistrationRequest;
import com.adonwheels.authservice.model.Role;
import com.adonwheels.authservice.service.AuthService;
import com.adonwheels.authservice.service.RegistrationSagaOrchestratorService;
import com.github.tomakehurst.wiremock.client.WireMock;
import dto.AppErrorCode;
import dto.exception.BusinessException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.cloud.contract.wiremock.AutoConfigureWireMock;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.web.reactive.function.client.WebClientRequestException;

import java.io.IOException;
import java.net.URI;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = {
                "eureka.client.enabled=false",
                "spring.cloud.discovery.enabled=false",
                "spring.main.allow-bean-definition-overriding=true"
        })
@AutoConfigureWireMock(port = 0)
@ActiveProfiles("test")
@Import(TestSecurityConfig.class)
class GlobalExceptionHandlerAspectTest {

    @Autowired
    private WebTestClient webTestClient;

    @MockBean
    private AuthService authService;

    @MockBean
    private RegistrationSagaOrchestratorService registrationSagaOrchestratorService;

    @BeforeEach
    void setUp() {
        WireMock.reset();
    }

    @Test
    void shouldHandleEmailAlreadyExistsException_WhenEmailIsDuplicate() {
        // Given
        RegistrationRequest validRequest = new RegistrationRequest(
                "test@example.com",
                "password123",
                "Test User",
                Role.DRIVER
        );

        doThrow(new BusinessException(AppErrorCode.EMAIL_ALREADY_EXISTS))
                .when(registrationSagaOrchestratorService)
                .register(any(RegistrationRequest.class));

        // When & Then
        webTestClient
                .post().uri("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(validRequest)
                .exchange()
                .expectStatus().isEqualTo(409)
                .expectBody()
                .jsonPath("$.success").isEqualTo(false)
                .jsonPath("$.error.internalCode").isEqualTo(2002)
                .jsonPath("$.error.message").exists();
    }

    @Test
    void shouldHandleRegistrationException_WhenBusinessLogicFails() {
        // Given
        RegistrationRequest validRequest = new RegistrationRequest(
                "test@example.com",
                "password123",
                "Test User",
                Role.DRIVER
        );

        doThrow(new BusinessException(AppErrorCode.VALIDATION_ERROR, "Invalid registration data"))
                .when(registrationSagaOrchestratorService)
                .register(any(RegistrationRequest.class));

        // When & Then
        webTestClient
                .post().uri("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(validRequest)
                .exchange()
                .expectStatus().isBadRequest()
                .expectBody()
                .jsonPath("$.success").isEqualTo(false)
                .jsonPath("$.error.internalCode").isEqualTo(9001)
                .jsonPath("$.error.message").isEqualTo("Invalid registration data");
    }

    @Test
    void shouldHandleBadCredentialsException_WhenLoginFails() {
        // Given
        LoginRequest loginRequest = new LoginRequest(
                "test@example.com",
                "wrongpassword",
                null
        );

        when(authService.verify(any(LoginRequest.class)))
                .thenThrow(new BadCredentialsException("Invalid credentials"));

        // When & Then
        webTestClient
                .post().uri("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(loginRequest)
                .exchange()
                .expectStatus().isUnauthorized()
                .expectBody()
                .jsonPath("$.success").isEqualTo(false)
                .jsonPath("$.error.internalCode").isEqualTo(1001)
                .jsonPath("$.error.message").isEqualTo("Invalid credentials provided");
    }

    @Test
    void shouldHandleRestClientException_WhenMicroserviceCommunicationFails() {
        // Given
        RegistrationRequest validRequest = new RegistrationRequest(
                "test@example.com",
                "password123",
                "Test User",
                Role.DRIVER
        );

        doThrow(new WebClientRequestException(
                new IOException("Service unavailable"),
                null,
                URI.create("http://localhost"),
                org.springframework.http.HttpHeaders.EMPTY
        ))
                .when(registrationSagaOrchestratorService)
                .register(any(RegistrationRequest.class));

        // When & Then
        webTestClient
                .post().uri("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(validRequest)
                .exchange()
                .expectStatus().isEqualTo(503)
                .expectBody()
                .jsonPath("$.success").isEqualTo(false)
                .jsonPath("$.error.internalCode").isEqualTo(9002)
                .jsonPath("$.error.message").isEqualTo("External service is currently unavailable");
    }

    @Test
    void shouldHandleRegistrationFailedException_WhenCriticalErrorOccurs() {
        // Given
        RegistrationRequest validRequest = new RegistrationRequest(
                "test@example.com",
                "password123",
                "Test User",
                Role.DRIVER
        );

        doThrow(new BusinessException(AppErrorCode.INTERNAL_SERVER_ERROR))
                .when(registrationSagaOrchestratorService)
                .register(any(RegistrationRequest.class));

        // When & Then
        webTestClient
                .post().uri("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(validRequest)
                .exchange()
                .expectStatus().isEqualTo(500)
                .expectBody()
                .jsonPath("$.success").isEqualTo(false)
                .jsonPath("$.error.internalCode").isEqualTo(9999)
                .jsonPath("$.error.message").isEqualTo("An unexpected internal server error occurred");
    }

    @Test
    void shouldHandleUnexpectedExceptions_WhenUnknownErrorOccurs() {
        // Given
        RegistrationRequest validRequest = new RegistrationRequest(
                "test@example.com",
                "password123",
                "Test User",
                Role.DRIVER
        );

        doThrow(new RuntimeException("Unexpected error"))
                .when(registrationSagaOrchestratorService)
                .register(any(RegistrationRequest.class));

        // When & Then
        webTestClient
                .post().uri("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(validRequest)
                .exchange()
                .expectStatus().isEqualTo(500)
                .expectBody()
                .jsonPath("$.success").isEqualTo(false)
                .jsonPath("$.error.internalCode").isEqualTo(9999)
                .jsonPath("$.error.message").isEqualTo("An unexpected internal server error occurred");
    }

    @Test
    void shouldReturnStandardApiResponse_ForAllErrors() {
        // Given
        LoginRequest loginRequest = new LoginRequest(
                "test@example.com",
                "wrongpassword",
                null
        );


        when(authService.verify(any(LoginRequest.class)))
                .thenThrow(new BadCredentialsException("Invalid credentials"));

        // When & Then - Verify standard ApiResponse structure
        webTestClient
                .post().uri("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(loginRequest)
                .exchange()
                .expectStatus().isUnauthorized()
                .expectBody()
                .jsonPath("$.success").isEqualTo(false)
                .jsonPath("$.data").doesNotExist()
                .jsonPath("$.error").exists()
                .jsonPath("$.error.internalCode").isEqualTo(1001)
                .jsonPath("$.error.message").exists();
    }
}
