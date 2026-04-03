package com.adonwheels.gatewayservice.filter;

import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.function.Predicate;

@Component
public class RouteValidator {

    public static final List<String> openApiEndpoints = List.of(
            "/auth/register",
            "/auth/login",
            "/auth/google",
            "/auth/forgot-password",
            "/auth/reset-password",
            "/auth/send-verification",
            "/auth/verify-email",
            "/eureka", //TODO MAKE sure that this is okay to have it here  im not sure i know i need it for eureka discovery
            //TODO but i dont know if it wont make issues with security
            "/campaigns/images/"
    );

    public Predicate<ServerHttpRequest> isSecured =
            request -> openApiEndpoints
                    .stream()
                    .noneMatch(uri -> request.getURI().getPath().contains(uri));
}