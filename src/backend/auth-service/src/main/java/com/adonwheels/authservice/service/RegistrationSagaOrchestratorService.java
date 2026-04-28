package com.adonwheels.authservice.service;

import com.adonwheels.authservice.dto.RegistrationRequest;
import com.adonwheels.authservice.model.Role;
import com.adonwheels.authservice.model.User;
import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;

import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.adonwheels.authservice.dto.RegistrationResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClientResponseException;

@Service
public class RegistrationSagaOrchestratorService {
    private static final Logger logger = LoggerFactory.getLogger(RegistrationSagaOrchestratorService.class);

    @Autowired
    private AuthService authService;

    public RegistrationResponse register(RegistrationRequest request) {
        Long profileId = null;
        try {
            // STEP 1: Check if email already exists BEFORE creating profile
            // This prevents orphaned profiles in remote services
            Optional<User> existing = authService.findByEmail(request.email());
            if (existing.isPresent()) {
                User existingUser = existing.get();
                if (existingUser.getRole() != request.role()) {
                    logger.warn("Registration attempt with email {} under role {} but already registered as {}",
                            request.email(), request.role(), existingUser.getRole());
                    throw new BusinessException(AppErrorCode.ROLE_MISMATCH, existingUser.getRole().name());
                }
                logger.warn("Registration attempt with existing email: {}", request.email());
                throw new BusinessException(AppErrorCode.EMAIL_ALREADY_EXISTS);
            }

            // STEP 2: Create Profile in remote service (driver-service or company-service)
            profileId = authService.createProfile(request.name(), request.email(), request.role());

            // STEP 3: Save the User with profile reference
            authService.saveUserWithProfile(request, profileId);

            logger.info("Registration successful for email: {}", request.email());

            // Auto login generate new token for the newly registered user
            String token = authService.generateTokenForNewUser(request.email());

            logger.info("Auto-login token generated for email: {}", request.email());
            return new RegistrationResponse(token, "Registration successful");

        } catch (BusinessException ex) {
            // Re-throw business exceptions (like EMAIL_ALREADY_EXISTS)
            throw ex;

        } catch (DataIntegrityViolationException ex) {
            // This should rarely happen now since we check email first
            logger.error("SAGA ROLLBACK: Unexpected data integrity violation for email {}.", request.email());
            rollbackProfileCreation(profileId, request.role());
            throw new BusinessException(AppErrorCode.EMAIL_ALREADY_EXISTS);

        } catch (WebClientResponseException ex) {
            logger.error(
                    "SAGA ROLLBACK: Communication with profile service failed for email {}. Status: {}, Body: {}",
                    request.email(),
                    ex.getStatusCode(),
                    ex.getResponseBodyAsString()
            );
            // Rollback profile if it was created
            rollbackProfileCreation(profileId, request.role());
            throw new BusinessException(AppErrorCode.SERVICE_UNAVAILABLE,
                    "A required service is currently unavailable. Please try again later.");

        } catch (Throwable ex) {
            logger.error("SAGA ROLLBACK: Unexpected error for {}.", request.email(), ex);
            rollbackProfileCreation(profileId, request.role());
            // Preserve cause for logs/troubleshooting
            throw new BusinessException(AppErrorCode.INTERNAL_SERVER_ERROR,
                    "An unexpected error occurred during registration.");
        }
    }

    private void rollbackProfileCreation(Long profileId, Role role) {
        if (profileId != null) {
            try {
                authService.deleteProfile(profileId, role);
            } catch (Exception ex) {
                // Log the rollback failure but don't let it override the original exception
                logger.error("Rollback failed for profile ID: {}. This may require manual cleanup.", profileId, ex);
            }
        }
    }
}