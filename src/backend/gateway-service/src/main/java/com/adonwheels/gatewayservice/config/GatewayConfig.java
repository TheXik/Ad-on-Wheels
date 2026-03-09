package com.adonwheels.gatewayservice.config;

import org.springframework.context.annotation.Configuration;

/**
 * Gateway route definitions have been moved to application.yml for declarative,
 * diff-friendly configuration. See spring.cloud.gateway.routes in application.yml.
 *
 * The {@link AuthenticationFilter} is registered as a named GatewayFilterFactory
 * (@Component extending AbstractGatewayFilterFactory) and is referenced by name
 * in the YAML filters list.
 */
@Configuration
public class GatewayConfig {
}
