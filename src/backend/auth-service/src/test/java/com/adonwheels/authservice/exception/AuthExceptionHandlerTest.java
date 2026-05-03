package com.adonwheels.authservice.exception;

import com.adonwheels.dto.AppErrorCode;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class AuthExceptionHandlerTest {

    private MockMvc mvc;

    @BeforeEach
    void setUp() {
        mvc = MockMvcBuilders.standaloneSetup(new TriggerController())
                .setControllerAdvice(new AuthExceptionHandler())
                .build();
    }

    @Test
    void badCredentials_mapsToInvalidCredentials() throws Exception {
        mvc.perform(get("/_t/bad-credentials"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.error.internalCode").value(AppErrorCode.INVALID_CREDENTIALS.getCode()));
    }

    @Test
    void disabledAccount_mapsToInvalidCredentials() throws Exception {
        mvc.perform(get("/_t/disabled"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.error.internalCode").value(AppErrorCode.INVALID_CREDENTIALS.getCode()));
    }

    @Test
    void lockedAccount_mapsToInvalidCredentials() throws Exception {
        mvc.perform(get("/_t/locked"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.error.internalCode").value(AppErrorCode.INVALID_CREDENTIALS.getCode()));
    }

    @RestController
    static class TriggerController {

        @GetMapping("/_t/bad-credentials")
        String bad() {
            throw new BadCredentialsException("wrong password");
        }

        @GetMapping("/_t/disabled")
        String disabled() {
            throw new DisabledException("account disabled");
        }

        @GetMapping("/_t/locked")
        String locked() {
            throw new LockedException("account locked");
        }
    }
}
