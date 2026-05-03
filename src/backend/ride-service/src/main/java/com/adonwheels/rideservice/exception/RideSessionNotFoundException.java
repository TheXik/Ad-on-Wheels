package com.adonwheels.rideservice.exception;

import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;

public class RideSessionNotFoundException extends BusinessException {
    public RideSessionNotFoundException(String rideId) {
        super(AppErrorCode.RIDE_NOT_ACTIVE, "No active ride found for id " + rideId);
    }
}
