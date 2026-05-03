package com.adonwheels.gatewayservice.config;

import com.adonwheels.gatewayservice.filter.RouteValidator;
import com.adonwheels.gatewayservice.util.JwtUtil;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.security.SignatureException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

/**
 * Global JWT authentication.
 *
 * <p>Implemented as a {@link WebFilter} (not a Spring Cloud Gateway
 * {@code AbstractGatewayFilterFactory}) so it runs in the WebFlux pipeline
 * <em>before</em> request mapping. That covers both routed endpoints
 * ({@code lb://*-service}) and the gateway-local {@code @RestController}
 * BFF aggregators ({@code DriverBffController}, {@code CompanyBffController},
 * {@code CoverageBffController}). A gateway-route filter would only fire for
 * the former, leaving the BFFs unauthenticated.
 *
 * <p>The filter sees the path before {@code StripPrefix=1} runs, so the
 * paths in {@link RouteValidator#openApiEndpoints} include the {@code /api/}
 * prefix where applicable.
 */
@Component
@Order(1)
public class AuthenticationFilter implements WebFilter {

    private static final Logger logger = LoggerFactory.getLogger(AuthenticationFilter.class);

    private final RouteValidator validator;
    private final JwtUtil jwtUtil;

    public AuthenticationFilter(RouteValidator validator, JwtUtil jwtUtil) {
        this.validator = validator;
        this.jwtUtil = jwtUtil;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();

        if (!validator.isSecured.test(request)) {
            return chain.filter(exchange);
        }

        if (!request.getHeaders().containsKey(HttpHeaders.AUTHORIZATION)) {
            return Mono.error(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing authorization header"));
        }

        String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            authHeader = authHeader.substring(7);
        }

        try {
            Claims claims = jwtUtil.extractAllClaims(authHeader);

            String role = claims.get("role", String.class);
            Object profileIdRaw = claims.get("profileID");
            String profileId = profileIdRaw != null ? profileIdRaw.toString() : null;

            ServerHttpRequest mutated = request.mutate()
                    .headers(h -> {
                        h.remove("X-User-Role");
                        h.remove("X-User-Id");
                    })
                    .header("X-User-Role", role)
                    .header("X-User-Id", profileId)
                    .build();

            return chain.filter(exchange.mutate().request(mutated).build());

        } catch (ExpiredJwtException e) {
            logger.warn("JWT expired: {}", e.getMessage());
            return Mono.error(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "JWT token has expired"));
        } catch (SignatureException e) {
            logger.warn("Invalid signature: {}", e.getMessage());
            return Mono.error(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid JWT signature"));
        } catch (Exception e) {
            logger.warn("Invalid token: {}", e.getMessage());
            return Mono.error(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized access: Invalid token"));
        }
    }
}
