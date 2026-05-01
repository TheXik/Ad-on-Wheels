package com.adonwheels.campaignservice.exception;

import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;

public class DuplicateApplicationException extends BusinessException {
    public DuplicateApplicationException(Long driverId, Long campaignId) {
        super(AppErrorCode.ALREADY_APPLIED,
                "Driver " + driverId + " has already applied to campaign " + campaignId);
    }
}
