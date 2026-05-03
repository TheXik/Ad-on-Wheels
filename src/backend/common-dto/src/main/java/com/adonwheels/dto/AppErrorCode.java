package com.adonwheels.dto;

import org.springframework.http.HttpStatus;

public enum AppErrorCode {

    // Authentication and security (401, 403)
    INVALID_CREDENTIALS(1001, "Invalid credentials provided", HttpStatus.UNAUTHORIZED),
    INVALID_TOKEN(1004, "Invalid authentication token", HttpStatus.UNAUTHORIZED),
    ACCESS_DENIED(1005, "Insufficient permissions to access this resource", HttpStatus.FORBIDDEN),

    // User Management (404, 409)
    USER_NOT_FOUND(2001, "User not found", HttpStatus.NOT_FOUND),
    EMAIL_ALREADY_EXISTS(2002, "Email already exists", HttpStatus.CONFLICT),
    COMPANY_NOT_FOUND(2006, "Company not found", HttpStatus.NOT_FOUND),
    ROLE_MISMATCH(2007, "Email already registered under a different role", HttpStatus.CONFLICT),

    // Campaign Management (404, 400, 409)
    CAMPAIGN_NOT_FOUND(3001, "Campaign not found", HttpStatus.NOT_FOUND),
    CAMPAIGN_FULL(3002, "Campaign has reached its maximum number of drivers", HttpStatus.CONFLICT),
    CAMPAIGN_EXPIRED(3003, "Campaign has ended", HttpStatus.BAD_REQUEST),
    INVALID_CAMPAIGN_DATES(3004, "Start date must be before end date", HttpStatus.BAD_REQUEST),
    APPLICATION_NOT_FOUND(3006, "Application not found", HttpStatus.NOT_FOUND),
    ALREADY_APPLIED(3007, "Driver has already applied to this campaign", HttpStatus.CONFLICT),
    DRIVER_HAS_ACTIVE_CAMPAIGN(3008, "Driver already has an active campaign", HttpStatus.CONFLICT),

    // Ride & QR Logic (400, 404, 409)
    INVALID_QR_CODE(5001, "The scanned QR code is invalid or unknown", HttpStatus.NOT_FOUND),
    RIDE_ALREADY_STARTED(5002, "Ride is already in progress", HttpStatus.CONFLICT),
    RIDE_NOT_ACTIVE(5003, "No active ride found to end", HttpStatus.NOT_FOUND),
    RIDE_NOT_FOUND(5005, "Completed ride not found", HttpStatus.NOT_FOUND),

    // System and validation (400, 409, 500, 503)
    VALIDATION_ERROR(9001, "Input validation failed", HttpStatus.BAD_REQUEST),
    SERVICE_UNAVAILABLE(9002, "External service is currently unavailable", HttpStatus.SERVICE_UNAVAILABLE),
    RESOURCE_CONFLICT(9003, "Resource conflict", HttpStatus.CONFLICT),
    INTERNAL_SERVER_ERROR(9999, "An unexpected internal server error occurred", HttpStatus.INTERNAL_SERVER_ERROR);

    private final int code;
    private final String message;
    private final HttpStatus httpStatus;

    AppErrorCode(int code, String message, HttpStatus httpStatus) {
        this.code = code;
        this.message = message;
        this.httpStatus = httpStatus;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    public HttpStatus getHttpStatus() {
        return httpStatus;
    }
}