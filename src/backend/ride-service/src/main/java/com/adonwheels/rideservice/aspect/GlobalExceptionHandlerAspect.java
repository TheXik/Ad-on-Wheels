package com.adonwheels.rideservice.aspect;

import dto.ApiResponse;
import dto.AppErrorCode;
import dto.exception.BusinessException;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.MethodArgumentNotValidException;

@Aspect
@Component
public class GlobalExceptionHandlerAspect {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandlerAspect.class);

    @Pointcut("execution(public * com.adonwheels.rideservice.controller..*.*(..))")
    public void controllerMethods() {
    }

    @Around("controllerMethods()")
    public Object handleControllerExceptions(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().toShortString();
        try {
            return joinPoint.proceed();

        } catch (MethodArgumentNotValidException ex) {
            throw ex;

        } catch (BusinessException ex) {
            AppErrorCode code = ex.getErrorCode();
            logger.warn("Business error in {}: {} ({})", methodName, ex.getMessage(), code);
            return buildResponse(code, ex.getMessage());

        } catch (Throwable ex) {
            logger.error("An unexpected internal error occurred in {}.", methodName, ex);
            String detail = ex.getClass().getSimpleName() + ": " + ex.getMessage();
            return buildResponse(AppErrorCode.INTERNAL_SERVER_ERROR, detail);
        }
    }

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
