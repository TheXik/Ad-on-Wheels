package com.adonwheels.gatewayservice.exception;

import com.adonwheels.dto.ApiResponse;
import com.adonwheels.dto.AppErrorCode;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.core.io.buffer.DataBufferFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebExceptionHandler;
import reactor.core.publisher.Mono;

/**
 * Reactive exception handler for the Spring Cloud Gateway filter chain.
 * {@code @RestControllerAdvice} only catches exceptions thrown by
 * {@code @RestController} handlers. The gateway's {@code AuthenticationFilter}
 * and {@code RoleAuthorizationFilter} run as WebFilters; their thrown
 * {@link ResponseStatusException}s would otherwise fall through to Spring's
 * default reactive error page, breaking the {@link ApiResponse} envelope
 * the iOS and web clients depend on. This handler restores that envelope.
 */
@Component
@Order(-2)
public class ApiResponseErrorWebExceptionHandler implements WebExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(ApiResponseErrorWebExceptionHandler.class);

    private final ObjectMapper objectMapper;

    public ApiResponseErrorWebExceptionHandler(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public Mono<Void> handle(ServerWebExchange exchange, Throwable ex) {
        if (exchange.getResponse().isCommitted()) {
            return Mono.error(ex);
        }

        HttpStatusCode status;
        AppErrorCode code;
        String message;

        if (ex instanceof ResponseStatusException rse) {
            status = rse.getStatusCode();
            code = GlobalExceptionHandler.mapStatusToCode(status);
            message = rse.getReason() != null ? rse.getReason() : code.getMessage();
        } else {
            logger.error("Unhandled exception in gateway filter chain", ex);
            status = HttpStatus.INTERNAL_SERVER_ERROR;
            code = AppErrorCode.INTERNAL_SERVER_ERROR;
            message = code.getMessage();
        }

        exchange.getResponse().setStatusCode(status);
        exchange.getResponse().getHeaders().setContentType(MediaType.APPLICATION_JSON);

        ApiResponse<Void> body = ApiResponse.error(code, message);
        DataBufferFactory factory = exchange.getResponse().bufferFactory();
        DataBuffer buffer;
        try {
            buffer = factory.wrap(objectMapper.writeValueAsBytes(body));
        } catch (JsonProcessingException jpe) {
            logger.error("Failed to serialize error response", jpe);
            buffer = factory.wrap(("{\"success\":false,\"error\":{\"internalCode\":9999,\"message\":\"Internal error\"}}").getBytes());
        }

        return exchange.getResponse().writeWith(Mono.just(buffer));
    }
}
