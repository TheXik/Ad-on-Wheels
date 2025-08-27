package com.adonwheels.authservice.service;

import com.adonwheels.authservice.dto.RegistrationRequest;
import com.adonwheels.authservice.exception.EmailAlreadyExistsException;
import com.adonwheels.authservice.exception.RegistrationException;
import com.adonwheels.authservice.model.Role;
import com.adonwheels.authservice.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;

@Service
public class RegistrationSagaOrchestratorService {
    private static final Logger logger = LoggerFactory.getLogger(RegistrationSagaOrchestratorService.class);

    @Autowired
    private AuthService authService;

    public User register(RegistrationRequest request) {
        Long profileId = null;
        try {
            // Create Profile
            profileId = authService.createProfile(request.getName(), request.getEmail(), request.getRole());

            // Save the User
            return authService.saveUserWithProfile(request, profileId);

        } catch (DataIntegrityViolationException ex) {
            logger.error("SAGA ROLLBACK: Data integrity violation for email {}.", request.getEmail());
            rollbackProfileCreation(profileId, request.getRole());
            throw new EmailAlreadyExistsException("This email address is already in use: " + request.getEmail());

        } catch (RestClientException ex) {
            logger.error("SAGA ROLLBACK: Service unavailable during profile creation for {}.", request.getEmail());
            // No rollback needed as profile wasn't created
            throw new RegistrationException("A required service is currently unavailable. Please try again later.");

        } catch (Throwable ex) {
            logger.error("SAGA ROLLBACK: Unexpected error for {}.", request.getEmail());
            rollbackProfileCreation(profileId, request.getRole());
            // Re-throw the original exception to be handled by the GlobalExceptionHandlerAspect
            throw new RuntimeException(ex);
        }
    }

    private void rollbackProfileCreation(Long profileId, Role role) {
        if (profileId != null) {
            authService.deleteProfile(profileId, role);
        }
    }
}