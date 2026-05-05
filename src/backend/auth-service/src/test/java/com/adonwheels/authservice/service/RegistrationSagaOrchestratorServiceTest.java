package com.adonwheels.authservice.service;

import com.adonwheels.authservice.dto.RegistrationRequest;
import com.adonwheels.authservice.dto.RegistrationResponse;
import com.adonwheels.authservice.model.Role;
import com.adonwheels.authservice.model.User;
import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RegistrationSagaOrchestratorServiceTest {

    @Mock
    private AuthService authService;

    @InjectMocks
    private RegistrationSagaOrchestratorService saga;

    private static final String EMAIL = "driver@example.com";
    private static final String NAME = "Test Driver";
    private static final String PASSWORD = "password123";
    private static final Long PROFILE_ID = 42L;
    private static final String JWT = "jwt-token-value";

    private RegistrationRequest request(Role role) {
        return new RegistrationRequest(EMAIL, PASSWORD, NAME, role);
    }

    @Test
    void register_happyPath_createsProfileSavesUserAndReturnsToken() {
        User saved = new User();
        saved.setEmail(EMAIL);
        saved.setRole(Role.DRIVER);
        saved.setProfileId(PROFILE_ID);

        when(authService.findByEmail(EMAIL)).thenReturn(Optional.empty());
        when(authService.createProfile(NAME, EMAIL, Role.DRIVER)).thenReturn(PROFILE_ID);
        when(authService.saveUserWithProfile(any(RegistrationRequest.class), eq(PROFILE_ID))).thenReturn(saved);
        when(authService.generateTokenForNewUser(saved)).thenReturn(JWT);

        RegistrationResponse response = saga.register(request(Role.DRIVER));

        assertThat(response.token()).isEqualTo(JWT);
        verify(authService).saveUserWithProfile(any(RegistrationRequest.class), eq(PROFILE_ID));
        verify(authService, never()).deleteProfile(any(), any());
    }

    @Test
    void register_emailExistsSameRole_throwsEmailAlreadyExistsAndDoesNotCreateProfile() {
        User existing = new User();
        existing.setEmail(EMAIL);
        existing.setRole(Role.DRIVER);
        when(authService.findByEmail(EMAIL)).thenReturn(Optional.of(existing));

        assertThatThrownBy(() -> saga.register(request(Role.DRIVER)))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(AppErrorCode.EMAIL_ALREADY_EXISTS);

        verify(authService, never()).createProfile(any(), any(), any());
        verify(authService, never()).deleteProfile(any(), any());
    }

    @Test
    void register_emailExistsDifferentRole_throwsRoleMismatch() {
        User existing = new User();
        existing.setEmail(EMAIL);
        existing.setRole(Role.COMPANY);
        when(authService.findByEmail(EMAIL)).thenReturn(Optional.of(existing));

        assertThatThrownBy(() -> saga.register(request(Role.DRIVER)))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(AppErrorCode.ROLE_MISMATCH);

        verify(authService, never()).createProfile(any(), any(), any());
    }

    @Test
    void register_saveUserFailsWithDataIntegrityViolation_rollsBackProfileCreation() {
        when(authService.findByEmail(EMAIL)).thenReturn(Optional.empty());
        when(authService.createProfile(NAME, EMAIL, Role.DRIVER)).thenReturn(PROFILE_ID);
        when(authService.saveUserWithProfile(any(RegistrationRequest.class), eq(PROFILE_ID)))
                .thenThrow(new DataIntegrityViolationException("duplicate key"));

        assertThatThrownBy(() -> saga.register(request(Role.DRIVER)))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(AppErrorCode.EMAIL_ALREADY_EXISTS);

        verify(authService).deleteProfile(PROFILE_ID, Role.DRIVER);
    }

    @Test
    void register_unexpectedErrorAfterProfileCreated_rollsBackAndThrowsInternalError() {
        when(authService.findByEmail(EMAIL)).thenReturn(Optional.empty());
        when(authService.createProfile(NAME, EMAIL, Role.DRIVER)).thenReturn(PROFILE_ID);
        when(authService.saveUserWithProfile(any(RegistrationRequest.class), eq(PROFILE_ID)))
                .thenThrow(new RuntimeException("database is on fire"));

        assertThatThrownBy(() -> saga.register(request(Role.DRIVER)))
                .isInstanceOf(BusinessException.class)
                .extracting("errorCode")
                .isEqualTo(AppErrorCode.INTERNAL_SERVER_ERROR);

        verify(authService).deleteProfile(PROFILE_ID, Role.DRIVER);
    }
}
