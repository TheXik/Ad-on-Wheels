package com.adonwheels.authservice.service;

import com.adonwheels.authservice.dto.LoginResponse;
import com.adonwheels.authservice.dto.ProfileRequest;
import com.adonwheels.authservice.dto.ProfileResponse;
import com.adonwheels.authservice.dto.RegistrationRequest;
import com.adonwheels.authservice.model.Role;
import com.adonwheels.authservice.model.User;
import com.adonwheels.authservice.repository.AuthRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
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
     * This method is called by the RegistrationSagaOrchestrator AFTER the profile has been created.
     * It handles the final step of saving the user to the database.
     */
    public User saveUserWithProfile(RegistrationRequest request, Long profileId) {
        User newUser = new User();
        newUser.setEmail(request.getEmail());
        newUser.setPassword(passwordEncoder.encode(request.getPassword()));
        newUser.setRole(request.getRole());
        newUser.setProfileId(profileId);
        return repository.save(newUser);
    }

    /**
     * Creates a profile in the appropriate service (driver or company).
     * This is a step in the registration saga.
     */
    public Long createProfile(String name, String email, Role role) {
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

    /**
     * Compensating transaction for the saga. Deletes a profile if the saga fails.
     */
    public void deleteProfile(Long profileId, Role role) {
        String url;
        if (role == Role.DRIVER) {
            url = "http://driver-service/drivers/{id}";
        } else if (role == Role.COMPANY) {
            url = "http://company-service/companies/{id}";
        } else {
            System.err.println("Cannot delete profile. Invalid role: " + role);
            return;
        }
        try {
            restTemplate.delete(url, profileId);
            System.out.println("Successfully rolled back profile for ID: " + profileId);
        } catch (Exception e) {
            System.err.println("CRITICAL: Failed to roll back profile for ID: " + profileId + ". Reason: " + e.getMessage());
            // In a real system this MUST trigger an alert for manual intervention
        }
    }

    /**
     * Verifies user credentials and generates a JWT token upon successful authentication.
     */
    public LoginResponse verify(User user) {


        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(user.getEmail(), user.getPassword())
        );
        return new LoginResponse(JWTService.generateToken(user.getEmail()));

    }
}
