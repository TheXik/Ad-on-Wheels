package com.adonwheels.authservice.exception;

// A base exception for registration failures
public class RegistrationException extends RuntimeException {
    public RegistrationException(String message) {
        super(message);
    }
}