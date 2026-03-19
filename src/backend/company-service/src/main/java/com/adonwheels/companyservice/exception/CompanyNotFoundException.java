package com.adonwheels.companyservice.exception;

import dto.AppErrorCode;
import dto.exception.BusinessException;

public class CompanyNotFoundException extends BusinessException {
    public CompanyNotFoundException(Long id) {
        super(AppErrorCode.COMPANY_NOT_FOUND, "Company not found with id " + id);
    }
}
