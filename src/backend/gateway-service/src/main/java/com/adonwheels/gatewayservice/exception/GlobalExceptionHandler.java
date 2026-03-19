package com.adonwheels.gatewayservice.exception;

import com.adonwheels.gatewayservice.dto.ApiResponseWrapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<ApiResponseWrapper<Void>> handleResponseStatusException(ResponseStatusException ex) {
        HttpStatus status = HttpStatus.valueOf(ex.getStatusCode().value());
        int code = status == HttpStatus.UNAUTHORIZED ? 4010 : status.value();
        String message = ex.getReason() != null ? ex.getReason() : status.getReasonPhrase();
        return ResponseEntity.status(status).body(ApiResponseWrapper.error(code, message));
    }

    @ExceptionHandler(WebClientResponseException.class)
    @ResponseStatus(HttpStatus.BAD_GATEWAY)
    public ApiResponseWrapper<Void> handleWebClientException(WebClientResponseException ex) {
        logger.error("Downstream service returned an error: {} {}", ex.getStatusCode(), ex.getMessage());
        return ApiResponseWrapper.error(9002, "A required service is currently unavailable. Please try again later.");
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiResponseWrapper<Void> handleGenericException(Exception ex) {
        logger.error("Unhandled exception in gateway controller", ex);
        return ApiResponseWrapper.error(9999, "An unexpected error occurred.");
    }
}
