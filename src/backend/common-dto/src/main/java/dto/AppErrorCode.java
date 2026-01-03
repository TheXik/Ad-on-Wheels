package dto;

/// Error codes used across the application improving the UX
public enum AppErrorCode {

    // Authentication Errors && Security errors
    INVALID_CREDENTIALS(1001, "Invalid credentials provided"),
    TOKEN_EXPIRED(1002, "Authentication token has expired"),
    ACCOUNT_LOCKED(1003, "User account is locked"),
    INVALID_TOKEN(1004, "Invalid authentication token"),
    ACCESS_DENIED(1005, "Insufficient permissions to access this resource"),

    // User Management Errors
    USER_NOT_FOUND(2001, "User not found"),
    EMAIL_ALREADY_EXISTS(2002, "Email already exists"),
    DRIVER_PROFILE_INCOMPLETE(2003, "Driver profile is incomplete (missing car details)"),
    COMPANY_PROFILE_INCOMPLETE(2004, "Company profile is incomplete"),
    IMAGE_UPLOAD_FAILED(2005, "Failed to upload profile/car image"),


    // Campaign management errors
    CAMPAIGN_NOT_FOUND(3001, "Campaign not found"),
    CAMPAIGN_FULL(3002, "Campaign has reached its maximum number of drivers"),
    CAMPAIGN_EXPIRED(3003, "Campaign has ended"),
    INVALID_CAMPAIGN_DATES(3004, "Start date must be before end date"),
    INSUFFICIENT_BUDGET(3005, "Company has insufficient budget for this campaign"),

    // QR code ride tracking errors
    INVALID_QR_CODE(5001, "The scanned QR code is invalid or unknown"),
    RIDE_ALREADY_STARTED(5002, "Ride is already in progress"),
    RIDE_NOT_ACTIVE(5003, "No active ride found to end"),
    RIDE_TOO_SHORT(5004, "Ride duration or distance was too short to be monetized"),


    // System and validation errors
    VALIDATION_ERROR(9001, "Input validation failed"),
    SERVICE_UNAVAILABLE(9002, "External service is currently unavailable"),
    INTERNAL_SERVER_ERROR(9999, "An unexpected internal server error occurred");

    private final int code;
    private final String message;

    private AppErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
