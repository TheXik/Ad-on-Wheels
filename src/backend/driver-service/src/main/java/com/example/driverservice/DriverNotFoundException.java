package com.example.driverservice;

public class DriverNotFoundException extends RuntimeException {
    public DriverNotFoundException(Long id) {
        super("Could not find driver " + id);
    }
} 