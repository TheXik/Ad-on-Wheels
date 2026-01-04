package dto;

import java.util.Map;

public record ErrorResponse(int internalCode, String message, Map<String, String> validationErrors) {

    // Canonical constructor handled by record

    // Constructor for backward compatibility (no validation errors)
    public ErrorResponse(int internalCode, String message) {
        this(internalCode, message, null);
    }
}