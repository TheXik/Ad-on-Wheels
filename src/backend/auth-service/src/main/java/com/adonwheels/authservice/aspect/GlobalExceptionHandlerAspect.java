package com.adonwheels.authservice.aspect;

// Import the new shared ErrorResponse DTO
import dto.ErrorResponse;
import com.adonwheels.authservice.exception.EmailAlreadyExistsException;
import com.adonwheels.authservice.exception.RegistrationException;
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
import org.springframework.web.client.RestClientException;

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

        } catch (EmailAlreadyExistsException ex) {
            logger.warn("Mistake in registration {}: Email already exists. Detail: {}", methodName, ex.getMessage());
            ErrorResponse errorResponse = new ErrorResponse
                    (HttpStatus.CONFLICT.value(),
                            ex.getMessage());
            return new ResponseEntity<>(errorResponse, HttpStatus.CONFLICT);

        } catch (RegistrationException ex) {
            logger.warn("Mistake in registration {}: {}", methodName, ex.getMessage());
            ErrorResponse errorResponse = new ErrorResponse(
                    HttpStatus.BAD_REQUEST.value(),
                    ex.getMessage());
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);

        } catch (BadCredentialsException ex) {
            logger.warn("Unsuccessful login {}: Invalid credentials.", methodName);
            ErrorResponse errorResponse = new ErrorResponse(
                    HttpStatus.UNAUTHORIZED.value(),
                    "Invalid credentials");
            return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);

        } catch (RestClientException ex) {
            logger.error("A required service is currently unavailable. {}: {}", methodName, ex.getMessage());
            ErrorResponse errorResponse = new ErrorResponse(
                    HttpStatus.SERVICE_UNAVAILABLE.value(),
                    "A required service is currently unavailable. Please try again later.");
            return new ResponseEntity<>(errorResponse, HttpStatus.SERVICE_UNAVAILABLE);


        } catch (Throwable ex) {
            logger.error("An unexpected internal error occurred. {}: {}", methodName, ex);
            ErrorResponse errorResponse = new ErrorResponse(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    "An unexpected internal error occurred.");
            return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}