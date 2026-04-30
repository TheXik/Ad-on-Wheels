package com.adonwheels.gatewayservice.config;

import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.Set;

@Component
public class RoleAuthorizationFilter extends AbstractGatewayFilterFactory<RoleAuthorizationFilter.Config> {

    private static final String ROLE_DRIVER = "DRIVER";
    private static final String ROLE_COMPANY = "COMPANY";
    private static final String ROLE_ADMIN = "ADMIN";

    // Paths are inspected after StripPrefix=1 has run, so the leading /api segment
    // is already gone by the time this filter sees the request.
    private static final Map<String, Set<String>> PATH_ROLE_RULES = Map.of(
            "/drivers/", Set.of(ROLE_DRIVER, ROLE_ADMIN),
            "/rides/", Set.of(ROLE_DRIVER, ROLE_COMPANY, ROLE_ADMIN),
            "/companies/", Set.of(ROLE_COMPANY, ROLE_ADMIN),
            "/campaigns/", Set.of(ROLE_DRIVER, ROLE_COMPANY, ROLE_ADMIN),
            "/messages/", Set.of(ROLE_DRIVER, ROLE_COMPANY, ROLE_ADMIN)
    );

    public RoleAuthorizationFilter() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            String path = exchange.getRequest().getURI().getPath();
            List<String> roleHeader = exchange.getRequest().getHeaders().get("X-User-Role");

            if (roleHeader == null || roleHeader.isEmpty()) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing role claim");
            }
            String role = roleHeader.getFirst();

            Set<String> allowed = PATH_ROLE_RULES.entrySet().stream()
                    .filter(e -> path.startsWith(e.getKey()))
                    .map(Map.Entry::getValue)
                    .findFirst()
                    .orElse(Set.of());

            if (!allowed.contains(role)) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                        "Role " + role + " is not permitted to access " + path);
            }

            return chain.filter(exchange);
        };
    }

    public static class Config {
    }
}
