package com.adonwheels.authservice.dto;

public class RegistrationResponse {
    private Long userId;
    private String message;

    public RegistrationResponse(Long userId, String message) {
        this.userId = userId;
        this.message = message;
    }

    // Standard Getters and Setters
    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}