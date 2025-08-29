package com.adonwheels.authservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.BAD_REQUEST)
public class InvalidRegistrationRequestException extends RegistrationException {
    public InvalidRegistrationRequestException(String message) {
        super(message);
    }
}