package com.adonwheels.authservice.aspect;

import com.adonwheels.authservice.exception.InvalidRegistrationRequestException;
import dto.ApiResponse;
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
            String errorMessage = ex.getBindingResult().getFieldErrors().stream()
                    .map(FieldError::getDefaultMessage)
                    .collect(Collectors.joining(", "));
            logger.warn("Validation error in {}: {}", methodName, errorMessage);
            throw new InvalidRegistrationRequestException(errorMessage);

        } catch (EmailAlreadyExistsException ex) {
            logger.warn("Mistake in registration Email already exists {}", ex.getMessage());
            ApiResponse<Object> errorResponse = ApiResponse.error(HttpStatus.CONFLICT.value(), ex.getMessage());
            return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .body(errorResponse);

        } catch (RegistrationException ex) {
            logger.warn("Mistake in registration {}: {}", methodName, ex.getMessage());
            ApiResponse<Object> errorResponse = ApiResponse.error(HttpStatus.BAD_REQUEST.value(), ex.getMessage());
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(errorResponse);

        } catch (BadCredentialsException ex) {
            logger.warn("Unsuccessful login {}: Invalid credentials.", methodName);
            ApiResponse<Object> errorResponse = ApiResponse.error(HttpStatus.UNAUTHORIZED.value(), "Invalid credentials");
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(errorResponse);

        } catch (RestClientException ex) {
            logger.error("A required service is currently unavailable. {}: {}", methodName, ex.getMessage());
            String message = "A required service is currently unavailable. Please try again later.";
            ApiResponse<Object> errorResponse = ApiResponse.error(HttpStatus.SERVICE_UNAVAILABLE.value(), message);
            return ResponseEntity
                    .status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(errorResponse);

        } catch (RegistrationFailedException ex) {
            logger.error("An unexpected internal error occurred during registration in {}: {}", methodName, ex.getMessage(), ex.getCause());
            String message = "An internal error prevented registration. Please try again later.";
            ApiResponse<Object> errorResponse = ApiResponse.error(HttpStatus.INTERNAL_SERVER_ERROR.value(), message);
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(errorResponse);

        } catch (Throwable ex) {
            logger.error("An unexpected internal error occurred. {}", methodName, ex);
            String message = "An unexpected internal error occurred.";
            ApiResponse<Object> errorResponse = ApiResponse.error(HttpStatus.INTERNAL_SERVER_ERROR.value(), message);
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(errorResponse);
        }
    }
}