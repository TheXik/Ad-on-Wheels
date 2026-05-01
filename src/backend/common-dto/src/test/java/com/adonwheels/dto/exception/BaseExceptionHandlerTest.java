package com.adonwheels.dto.exception;

import com.adonwheels.dto.AppErrorCode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class BaseExceptionHandlerTest {

    private MockMvc mvc;

    @BeforeEach
    void setUp() {
        mvc = MockMvcBuilders.standaloneSetup(new TriggerController())
                .setControllerAdvice(new TestAdvice())
                .build();
    }

    @Test
    void businessException_mapsToAppErrorCodeStatus() throws Exception {
        mvc.perform(post("/_t/business"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error.internalCode").value(AppErrorCode.USER_NOT_FOUND.getCode()));
    }

    @Test
    void invalidValidBody_mapsToValidationErrorWithFieldMap() throws Exception {
        mvc.perform(post("/_t/valid")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.internalCode").value(AppErrorCode.VALIDATION_ERROR.getCode()))
                .andExpect(jsonPath("$.error.validationErrors.name").exists());
    }

    @Test
    void malformedJsonBody_mapsToValidationError() throws Exception {
        mvc.perform(post("/_t/valid")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{not json"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.internalCode").value(AppErrorCode.VALIDATION_ERROR.getCode()));
    }

    @Test
    void illegalArgument_mapsToValidationError() throws Exception {
        mvc.perform(post("/_t/illegal"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.internalCode").value(AppErrorCode.VALIDATION_ERROR.getCode()))
                .andExpect(jsonPath("$.error.message").value("rejected input"));
    }

    @Test
    void dataIntegrityViolation_mapsToResourceConflict() throws Exception {
        mvc.perform(post("/_t/integrity"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error.internalCode").value(AppErrorCode.RESOURCE_CONFLICT.getCode()));
    }

    @Test
    void responseStatusException_preservesStatusAndReason() throws Exception {
        mvc.perform(post("/_t/forbidden"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.error.message").value("not your inbox"));
    }

    @Test
    void uncaughtRuntimeException_mapsToInternalServerError() throws Exception {
        mvc.perform(post("/_t/runtime"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.error.internalCode").value(AppErrorCode.INTERNAL_SERVER_ERROR.getCode()));
    }

    @RestController
    static class TriggerController {

        @PostMapping("/_t/business")
        String business() {
            throw new BusinessException(AppErrorCode.USER_NOT_FOUND);
        }

        @PostMapping("/_t/illegal")
        String illegal() {
            throw new IllegalArgumentException("rejected input");
        }

        @PostMapping("/_t/integrity")
        String integrity() {
            throw new DataIntegrityViolationException("unique constraint x");
        }

        @PostMapping("/_t/forbidden")
        String forbidden() {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "not your inbox");
        }

        @PostMapping("/_t/runtime")
        String runtime() {
            throw new RuntimeException("boom");
        }

        @PostMapping("/_t/valid")
        String valid(@Valid @RequestBody Payload payload) {
            return "ok";
        }
    }

    static class Payload {
        @NotBlank
        private String name;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }
    }

    @RestControllerAdvice
    static class TestAdvice extends BaseExceptionHandler {
    }
}
