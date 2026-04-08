package com.adonwheels.campaignservice.exception;

import dto.ApiResponse;
import dto.AppErrorCode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

@RestControllerAdvice
@Order(1)
public class ValidationExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(ValidationExceptionHandler.class);

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidationErrors(MethodArgumentNotValidException ex) {
        java.util.Map<String, String> validationErrors = ex.getBindingResult().getFieldErrors().stream()
                .collect(Collectors.toMap(
                        FieldError::getField,
                        e -> e.getDefaultMessage() != null ? e.getDefaultMessage() : "Invalid value",
                        (existing, replacement) -> existing));

        String errorMessage = "Validation failed for " + validationErrors.size() + " fields";
        logger.warn("Validation error captured by ControllerAdvice: {}", validationErrors);

        return ResponseEntity
                .status(AppErrorCode.VALIDATION_ERROR.getHttpStatus())
                .body(ApiResponse.error(AppErrorCode.VALIDATION_ERROR, errorMessage, validationErrors));
    }

    @ExceptionHandler(DuplicateApplicationException.class)
    public ResponseEntity<ApiResponse<Void>> handleDuplicateApplication(DuplicateApplicationException ex) {
        logger.warn("Duplicate application attempt: {}", ex.getMessage());
        return ResponseEntity
                .status(AppErrorCode.ALREADY_APPLIED.getHttpStatus())
                .body(ApiResponse.error(AppErrorCode.ALREADY_APPLIED, ex.getMessage()));
    }

    @ExceptionHandler(ActiveCampaignException.class)
    public ResponseEntity<ApiResponse<Void>> handleActiveCampaign(ActiveCampaignException ex) {
        logger.warn("Active campaign conflict: {}", ex.getMessage());
        return ResponseEntity
                .status(AppErrorCode.DRIVER_HAS_ACTIVE_CAMPAIGN.getHttpStatus())
                .body(ApiResponse.error(AppErrorCode.DRIVER_HAS_ACTIVE_CAMPAIGN, ex.getMessage()));
    }
}
