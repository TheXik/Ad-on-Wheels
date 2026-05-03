package com.adonwheels.campaignservice.exception;

import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;

public class ApplicationNotFoundException extends BusinessException {
    public ApplicationNotFoundException(Long id) {
        super(AppErrorCode.APPLICATION_NOT_FOUND, "Application not found with id " + id);
    }
}
