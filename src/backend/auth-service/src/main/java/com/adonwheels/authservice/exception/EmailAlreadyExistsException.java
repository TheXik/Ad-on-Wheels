package com.adonwheels.authservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.CONFLICT) //409 error
public class EmailAlreadyExistsException extends RegistrationException {
    public EmailAlreadyExistsException(String email) {
        super("This email address is already in use: " + email);
    }
}