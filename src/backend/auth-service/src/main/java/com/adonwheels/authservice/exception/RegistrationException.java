package com.adonwheels.authservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

// A base exception for registration failures
public class RegistrationException extends RuntimeException {
    public RegistrationException(String message) {
        super(message);
    }
}