package com.adonwheels.gatewayservice.exception;

import com.adonwheels.dto.ApiResponse;
import com.adonwheels.dto.AppErrorCode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.reactive.function.client.WebClientRequestException;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import org.springframework.web.server.ResponseStatusException;

// Handles BFF controller exceptions. Filter-thrown ones go through
// ApiResponseErrorWebExceptionHandler instead.
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<ApiResponse<Void>> handleResponseStatus(ResponseStatusException ex) {
        HttpStatusCode status = ex.getStatusCode();
        AppErrorCode code = mapStatusToCode(status);
        String message = ex.getReason() != null ? ex.getReason() : code.getMessage();
        return ResponseEntity.status(status).body(ApiResponse.error(code, message));
    }

    @ExceptionHandler({WebClientResponseException.class, WebClientRequestException.class})
    public ResponseEntity<ApiResponse<Void>> handleWebClient(Exception ex) {
        logger.error("Downstream service call failed: {}", ex.getMessage());
        AppErrorCode code = AppErrorCode.SERVICE_UNAVAILABLE;
        return ResponseEntity.status(code.getHttpStatus())
                .body(ApiResponse.error(code,
                        "A required service is currently unavailable. Please try again later."));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleGeneric(Exception ex) {
        logger.error("Unhandled exception in gateway controller", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(AppErrorCode.INTERNAL_SERVER_ERROR));
    }

    static AppErrorCode mapStatusToCode(HttpStatusCode status) {
        if (status.value() == HttpStatus.UNAUTHORIZED.value()) return AppErrorCode.INVALID_TOKEN;
        if (status.value() == HttpStatus.FORBIDDEN.value()) return AppErrorCode.ACCESS_DENIED;
        if (status.is4xxClientError()) return AppErrorCode.VALIDATION_ERROR;
        return AppErrorCode.INTERNAL_SERVER_ERROR;
    }
}
