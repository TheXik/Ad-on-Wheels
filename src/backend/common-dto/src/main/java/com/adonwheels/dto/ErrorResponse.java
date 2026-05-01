package com.adonwheels.dto;

import java.util.Map;

public record ErrorResponse(int internalCode, String message, Map<String, String> validationErrors) {

    public ErrorResponse(int internalCode, String message) {
        this(internalCode, message, null);
    }
}