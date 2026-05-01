package com.adonwheels.authservice.exception;

import com.adonwheels.dto.ApiResponse;
import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BaseExceptionHandler;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.reactive.function.client.WebClientRequestException;
import org.springframework.web.reactive.function.client.WebClientResponseException;

@RestControllerAdvice
public class AuthExceptionHandler extends BaseExceptionHandler {

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ApiResponse<Void>> handleAuthentication(AuthenticationException ex) {
        return build(AppErrorCode.INVALID_CREDENTIALS);
    }

    @ExceptionHandler({WebClientResponseException.class, WebClientRequestException.class})
    public ResponseEntity<ApiResponse<Void>> handleWebClient(Exception ex) {
        return build(AppErrorCode.SERVICE_UNAVAILABLE);
    }
}
