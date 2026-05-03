package com.adonwheels.rideservice.exception;

import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;

public class InvalidDeferredRideException extends BusinessException {
    public InvalidDeferredRideException(String message) {
        super(AppErrorCode.VALIDATION_ERROR, message);
    }
}
