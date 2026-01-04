package com.adonwheels.authservice.service;

import com.adonwheels.authservice.dto.RegistrationRequest;
import com.adonwheels.authservice.exception.EmailAlreadyExistsException;
import com.adonwheels.authservice.exception.RegistrationException;
import com.adonwheels.authservice.exception.RegistrationFailedException;
import com.adonwheels.authservice.model.Role;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClientResponseException;

@Service
public class RegistrationSagaOrchestratorService {
    private static final Logger logger = LoggerFactory.getLogger(RegistrationSagaOrchestratorService.class);

    @Autowired
    private AuthService authService;

    public void register(RegistrationRequest request) {
        Long profileId = null;
        try {
            // Create Profile
            profileId = authService.createProfile(request.name(), request.email(), request.role());

            // Save the User
            authService.saveUserWithProfile(request, profileId);

            // Registration successful - TODO AUTO LOGIN
            

        } catch (DataIntegrityViolationException ex) {
            logger.error("SAGA ROLLBACK: Data integrity violation for email {}.", request.email());
            rollbackProfileCreation(profileId, request.role());
            throw new EmailAlreadyExistsException(request.email());

        }  catch (WebClientResponseException ex) {
            logger.error(
                    "SAGA ROLLBACK: Communication with profile service failed for email {}. Status: {}, Body: {}",
                    request.email(),
                    ex.getStatusCode(),
                    ex.getResponseBodyAsString()
            );
            // No rollback needed as profile wasn't created
            throw new RegistrationException("A required service is currently unavailable. Please try again later.");

        } catch (Throwable ex) {
            logger.error("SAGA ROLLBACK: Unexpected error for {}.", request.email());
            rollbackProfileCreation(profileId, request.role());
            // Re-throw the original exception to be handled by the GlobalExceptionHandlerAspect
            throw new RegistrationFailedException("An unexpected error occurred during registration.", ex);
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