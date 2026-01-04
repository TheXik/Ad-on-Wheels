package com.example.gatewayservice.config;

import com.example.gatewayservice.filter.RouteValidator;
import com.example.gatewayservice.util.JwtUtil;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.security.SignatureException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

@Component
public class AuthenticationFilter extends AbstractGatewayFilterFactory<AuthenticationFilter.Config> {

    @Autowired
    private RouteValidator validator;

    @Autowired
    private JwtUtil jwtUtil;

    public AuthenticationFilter() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        return ((exchange, chain) -> {
            if (validator.isSecured.test(exchange.getRequest())) {
                // Check for the auth header
                if (!exchange.getRequest().getHeaders().containsKey(HttpHeaders.AUTHORIZATION)) {
                    throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing authorization header");
                }

                String authHeader = exchange.getRequest().getHeaders().get(HttpHeaders.AUTHORIZATION).getFirst();
                if (authHeader != null && authHeader.startsWith("Bearer ")) {
                    authHeader = authHeader.substring(7);
                }

                try {
                    // AUTHENTICATION
                    Claims claims = jwtUtil.extractAllClaims(authHeader);


                    // TODO AUTHORIZATION later
                    // String role = claims.get("role", String.class);
                    // String path = exchange.getRequest().getURI().getPath();

                } catch (ExpiredJwtException e) {
                    System.err.println("JWT expired: " + e.getMessage());
                    throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "JWT token has expired");
                } catch (SignatureException e) {
                    System.err.println("Invalid signature: " + e.getMessage());
                    throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid JWT signature");
                } catch (Exception e) {
                    System.err.println("Invalid token: " + e.getMessage());
                    throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthorized access: Invalid token");
                }
            }
            return chain.filter(exchange);
        });
    }

    public static class Config {
    }
}