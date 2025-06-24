package com.example.companyservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@ControllerAdvice
public class CompanyNotFoundAdvice {
    @ResponseBody
    @ExceptionHandler(CompanyNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    String companyNotFoundHandler(CompanyNotFoundException ex) {
        return ex.getMessage();
    }
} 