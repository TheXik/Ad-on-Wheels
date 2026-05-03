package com.adonwheels.rideservice.exception;

import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;

public class RideNotFoundException extends BusinessException {
    public RideNotFoundException(Long id) {
        super(AppErrorCode.RIDE_NOT_FOUND, "Ride not found with id " + id);
    }
}
