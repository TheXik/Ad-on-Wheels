package com.adonwheels.authservice.exception;

public class InvalidRegistrationRequestException extends RegistrationException {
    public InvalidRegistrationRequestException(String message) {
        super(message);
    }
}