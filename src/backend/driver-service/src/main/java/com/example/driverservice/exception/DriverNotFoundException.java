package com.example.driverservice.exception;

public class DriverNotFoundException extends RuntimeException {
    public DriverNotFoundException(Long id) {
        super("Could not find driver " + id);
    }
} 