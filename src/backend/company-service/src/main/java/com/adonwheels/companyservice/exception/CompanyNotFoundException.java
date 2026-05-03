package com.adonwheels.companyservice.exception;

import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;

public class CompanyNotFoundException extends BusinessException {
    public CompanyNotFoundException(Long id) {
        super(AppErrorCode.COMPANY_NOT_FOUND, "Company not found with id " + id);
    }
}
