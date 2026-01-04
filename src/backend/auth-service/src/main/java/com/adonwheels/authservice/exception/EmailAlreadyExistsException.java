package com.adonwheels.authservice.exception;

public class EmailAlreadyExistsException extends RegistrationException {
    public EmailAlreadyExistsException(String email) {
        super("This email address is already in use: " + email);
    }
}