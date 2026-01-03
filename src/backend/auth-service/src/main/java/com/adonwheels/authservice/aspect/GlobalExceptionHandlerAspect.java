package com.adonwheels.authservice.aspect;

import dto.ApiResponse;
import dto.AppErrorCode;
import com.adonwheels.authservice.exception.EmailAlreadyExistsException;
import com.adonwheels.authservice.exception.RegistrationException;
import com.adonwheels.authservice.exception.RegistrationFailedException;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Component;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.client.RestClientException;

import java.util.stream.Collectors;

@Aspect
@Component
public class GlobalExceptionHandlerAspect {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandlerAspect.class);

    @Pointcut("execution(public * com.adonwheels.authservice.controller..*.*(..))")
    public void controllerMethods() {
    }

    @Around("controllerMethods()")
    public Object handleControllerExceptions(ProceedingJoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().toShortString();
        try {
            return joinPoint.proceed();

        } catch (MethodArgumentNotValidException ex) {
            // Spring Validation Errors
            String errorMessage = ex.getBindingResult().getFieldErrors().stream()
                    .map(FieldError::getDefaultMessage)
                    .collect(Collectors.joining(", "));
            logger.warn("Validation error in {}: {}", methodName, errorMessage);

            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(AppErrorCode.VALIDATION_ERROR, errorMessage));

        } catch (EmailAlreadyExistsException ex) {
            // Specific Business Rule
            logger.warn("Registration failed - Email already exists: {}", ex.getMessage());

            return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .body(ApiResponse.error(AppErrorCode.EMAIL_ALREADY_EXISTS));

        } catch (RegistrationException ex) {
            // Generic Business Logic Error
            logger.warn("Registration logic error in {}: {}", methodName, ex.getMessage());

            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(AppErrorCode.VALIDATION_ERROR, ex.getMessage()));

        } catch (BadCredentialsException ex) {
            // Login Failure
            logger.warn("Unsuccessful login {}: Invalid credentials.", methodName);

            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(AppErrorCode.INVALID_CREDENTIALS));

        } catch (RestClientException ex) {
            // Microservices Communication Failure
            logger.error("Inter-service communication failed in {}: {}", methodName, ex.getMessage());

            return ResponseEntity
                    .status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(ApiResponse.error(AppErrorCode.SERVICE_UNAVAILABLE));

        } catch (RegistrationFailedException ex) {
            // Critical Database/System Failure
            logger.error("Critical registration failure in {}: {}", methodName, ex.getMessage(), ex.getCause());

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(AppErrorCode.INTERNAL_SERVER_ERROR));

        } catch (Throwable ex) {
            // Catch-All
            logger.error("An unexpected internal error occurred in {}.", methodName, ex);

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(AppErrorCode.INTERNAL_SERVER_ERROR));
        }
    }
}