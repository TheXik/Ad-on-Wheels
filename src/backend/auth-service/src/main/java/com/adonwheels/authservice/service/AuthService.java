package com.adonwheels.authservice.service;

import com.adonwheels.authservice.dto.ProfileRequest;
import com.adonwheels.authservice.dto.ProfileResponse;
import com.adonwheels.authservice.dto.RegistrationRequest;
import com.adonwheels.authservice.exception.EmailAlreadyExistsException;
import com.adonwheels.authservice.exception.RegistrationException;
import com.adonwheels.authservice.model.Role;
import com.adonwheels.authservice.model.User;
import com.adonwheels.authservice.repository.AuthRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Service
public class AuthService {

    @Autowired
    private AuthRepository repository;
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private JWTService JWTService;

    @Autowired
    private AuthenticationManager authenticationManager;

    /**
     * This method is the Saga Orchestrator for user registration.
     * It handles the sequence of transactions and compensates if something fails.
     */
    public User registerNewUser(RegistrationRequest request) throws RegistrationException {
        Long profileId = null;
        try {
            // Create the profile in the appropriate service.
            profileId = createProfile(request.getName(), request.getEmail(), request.getRole());

            // Step 2: Save the user credentials in the auth database.
            User newUser = new User();
            newUser.setEmail(request.getEmail());
            newUser.setPassword(passwordEncoder.encode(request.getPassword()));
            newUser.setRole(request.getRole());
            newUser.setProfileId(profileId);

            return repository.save(newUser);

        } catch (DataIntegrityViolationException e) {
            // When user types the same email that already exists
            System.err.println("Registration failed: Data integrity violation.");
            if (profileId != null) {
                // Roll back the profile creation.
                deleteProfile(profileId, request.getRole());
            }
            throw new EmailAlreadyExistsException(request.getEmail());

        } catch (RestClientException e) {
            // driver/company service is down.
            System.err.println("Registration failed: Cannot create profile. Reason: " + e.getMessage());
            throw new RegistrationException("A required service is currently unavailable. Please try again later.");

        } catch (Exception e) {
            // Catch any other unexpected errors.
            System.err.println("An unexpected error occurred during registration: " + e.getMessage());
            if (profileId != null) {
                // Compensating Transaction: Roll back the profile creation.
                deleteProfile(profileId, request.getRole());
            }
            throw new RegistrationException("An unexpected error occurred during registration.");
        }
    }

    // This method is now effectively private to the service's orchestration logic.
    private Long createProfile(String name, String email, Role role) {
        String url;
        ProfileRequest requestBody = new ProfileRequest();
        requestBody.setName(name);
        requestBody.setEmail(email);

        if (role == Role.DRIVER) {
            url = "http://driver-service/drivers";
        } else if (role == Role.COMPANY) {
            url = "http://company-service/companies";
        } else {
            throw new IllegalArgumentException("Invalid role for profile creation");
        }
        ResponseEntity<ProfileResponse> response = restTemplate.postForEntity(url, requestBody, ProfileResponse.class);

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            return response.getBody().getId();
        } else {
            throw new RestClientException("Failed to create profile. Status code: " + response.getStatusCode());
        }
    }

    /// When something went wrong during the registration this will act as a
    /// rollback of the already created profile in the driver/company service
    private void deleteProfile(Long profileId, Role role) {
        String url;
        if (role == Role.DRIVER) {
            // Use a URI template for the URL
            url = "http://driver-service/drivers/{id}";
        } else if (role == Role.COMPANY) {
            // Use a URI template for the URL
            url = "http://company-service/companies/{id}";
        } else {
            System.err.println("Cannot delete profile. Invalid role: " + role);
            return;
        }
        try {
            // Pass the profileId as a URI variable

            restTemplate.delete(url, profileId);
            System.out.println("Successfully rolled back profile for ID: " + profileId);
        } catch (Exception e) {
            System.err.println("CRITICAL: Failed to roll back profile for ID: " + profileId + ". Reason: " + e.getMessage());
            // TODO In a real system this MUSTTTT trigger an alert for manual intervention
        }
    }

    public ResponseEntity<String> verify(User user) {
        // Spring Security handles the authentication
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(user.getEmail(), user.getPassword())
        );

        if (authentication.isAuthenticated()) {
            return ResponseEntity.ok(JWTService.generateToken(user));
        } else {
            return ResponseEntity.status(401).body("Invalid credentials");
        }
    }
}