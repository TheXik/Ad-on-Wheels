package com.adonwheels.campaignservice.exception;

import dto.AppErrorCode;
import dto.exception.BusinessException;

public class ApplicationNotFoundException extends BusinessException {
    public ApplicationNotFoundException(Long id) {
        super(AppErrorCode.APPLICATION_NOT_FOUND, "Application not found with id " + id);
    }
}
