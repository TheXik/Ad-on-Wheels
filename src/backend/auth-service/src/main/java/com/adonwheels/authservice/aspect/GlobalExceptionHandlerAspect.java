package com.adonwheels.authservice.aspect;

import com.adonwheels.dto.ApiResponse;
import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.reactive.function.client.WebClientRequestException;
import org.springframework.web.reactive.function.client.WebClientResponseException;

@Aspect
@Component
public class GlobalExceptionHandlerAspect {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandlerAspect.class);

    @Pointcut("execution(public * com.adonwheels.authservice.controller..*.*(..))")
    public void controllerMethods() {
    }

    @Around("controllerMethods()")
    public Object handleControllerExceptions(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().toShortString();
        try {
            return joinPoint.proceed();

        } catch (MethodArgumentNotValidException ex) {
            // Let ValidationExceptionHandler handle this
            throw ex;

        } catch (BusinessException ex) {
            // Shared business error across services
            AppErrorCode code = ex.getErrorCode();
            logger.warn("Business error in {}: {} ({})", methodName, ex.getMessage(), code);
            return buildResponse(code, ex.getMessage());

        } catch (BadCredentialsException ex) {
            // Login Failure
            logger.warn("Unsuccessful login {}: Invalid credentials.", methodName);

            return buildResponse(AppErrorCode.INVALID_CREDENTIALS);

        } catch (WebClientRequestException ex) {
            // Microservices Communication Failure - request exception
            logger.error("Inter-service request failed in {}: {}", methodName, ex.getMessage());

            return buildResponse(AppErrorCode.SERVICE_UNAVAILABLE);

        } catch (WebClientResponseException ex) {
            // Microservices Communication Failure - response exception
            logger.error("Inter-service communication failed in {}: {}", methodName, ex.getMessage());

            return buildResponse(AppErrorCode.SERVICE_UNAVAILABLE);

        } catch (Throwable ex) {
            // Catch-All
            logger.error("An unexpected internal error occurred in {}.", methodName, ex);

            return buildResponse(AppErrorCode.INTERNAL_SERVER_ERROR);
        }
    }

    // Helper methods

    private ResponseEntity<ApiResponse<Void>> buildResponse(AppErrorCode errorCode) {
        return ResponseEntity
                .status(errorCode.getHttpStatus())
                .body(ApiResponse.error(errorCode));
    }

    private ResponseEntity<ApiResponse<Void>> buildResponse(AppErrorCode errorCode, String customMessage) {
        return ResponseEntity
                .status(errorCode.getHttpStatus())
                .body(ApiResponse.error(errorCode, customMessage));
    }
}