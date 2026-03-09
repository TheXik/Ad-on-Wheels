package com.adonwheels.driverservice.exception;

import dto.AppErrorCode;
import dto.exception.BusinessException;

public class DriverNotFoundException extends BusinessException {

    public DriverNotFoundException(Long id) {
        super(AppErrorCode.USER_NOT_FOUND, "Driver with ID " + id + " not found");
    }
} 