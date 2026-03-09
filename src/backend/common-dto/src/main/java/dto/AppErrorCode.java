package dto;

import org.springframework.http.HttpStatus;

// Error codes used across the application improving the UX
public enum AppErrorCode {

    // Authentication and security (401, 403)
    INVALID_CREDENTIALS(1001, "Invalid credentials provided", HttpStatus.UNAUTHORIZED),
    TOKEN_EXPIRED(1002, "Authentication token has expired", HttpStatus.UNAUTHORIZED),
    ACCOUNT_LOCKED(1003, "User account is locked", HttpStatus.FORBIDDEN),
    INVALID_TOKEN(1004, "Invalid authentication token", HttpStatus.UNAUTHORIZED),
    ACCESS_DENIED(1005, "Insufficient permissions to access this resource", HttpStatus.FORBIDDEN),

    // User Management (404, 409, 400)
    USER_NOT_FOUND(2001, "User not found", HttpStatus.NOT_FOUND),

    // Critical use 409 CONFLICT for duplicates, not 400
    EMAIL_ALREADY_EXISTS(2002, "Email already exists", HttpStatus.CONFLICT),

    DRIVER_PROFILE_INCOMPLETE(2003, "Driver profile is incomplete (missing car details)", HttpStatus.BAD_REQUEST),
    COMPANY_PROFILE_INCOMPLETE(2004, "Company profile is incomplete", HttpStatus.BAD_REQUEST),
    IMAGE_UPLOAD_FAILED(2005, "Failed to upload profile/car image", HttpStatus.INTERNAL_SERVER_ERROR),
    COMPANY_NOT_FOUND(2006, "Company not found", HttpStatus.NOT_FOUND),

    // Campaign Management (404, 400)
    CAMPAIGN_NOT_FOUND(3001, "Campaign not found", HttpStatus.NOT_FOUND),
    CAMPAIGN_FULL(3002, "Campaign has reached its maximum number of drivers", HttpStatus.CONFLICT),
    CAMPAIGN_EXPIRED(3003, "Campaign has ended", HttpStatus.BAD_REQUEST),
    INVALID_CAMPAIGN_DATES(3004, "Start date must be before end date", HttpStatus.BAD_REQUEST),
    INSUFFICIENT_BUDGET(3005, "Company has insufficient budget for this campaign", HttpStatus.BAD_REQUEST),
    APPLICATION_NOT_FOUND(3006, "Application not found", HttpStatus.NOT_FOUND),

    // Ride & QR Logic (400, 404, 409)
    INVALID_QR_CODE(5001, "The scanned QR code is invalid or unknown", HttpStatus.NOT_FOUND),
    RIDE_ALREADY_STARTED(5002, "Ride is already in progress", HttpStatus.CONFLICT),
    RIDE_NOT_ACTIVE(5003, "No active ride found to end", HttpStatus.NOT_FOUND),
    RIDE_TOO_SHORT(5004, "Ride duration or distance was too short to be monetized", HttpStatus.BAD_REQUEST),

    // System and validation (400, 500, 503)
    VALIDATION_ERROR(9001, "Input validation failed", HttpStatus.BAD_REQUEST),
    SERVICE_UNAVAILABLE(9002, "External service is currently unavailable", HttpStatus.SERVICE_UNAVAILABLE),
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