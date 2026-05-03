package com.adonwheels.gatewayservice.config;

import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Path-prefix → allowed-role rules. Runs as a {@link WebFilter} after
 * {@link AuthenticationFilter}, so it sees the {@code X-User-Role} header
 * the auth filter already set.
 *
 * <p>Paths are inspected before {@code StripPrefix=1} runs, so they include
 * the {@code /api/} prefix. Auth-only paths ({@code /auth/**}) do not match
 * any rule and pass through unchanged (they are open per
 * {@link com.adonwheels.gatewayservice.filter.RouteValidator}).
 */
@Component
@Order(2)
public class RoleAuthorizationFilter implements WebFilter {

    private static final String ROLE_DRIVER = "DRIVER";
    private static final String ROLE_COMPANY = "COMPANY";
    private static final String ROLE_ADMIN = "ADMIN";

    private static final Map<String, Set<String>> PATH_ROLE_RULES = Map.of(
            "/api/drivers/", Set.of(ROLE_DRIVER, ROLE_COMPANY, ROLE_ADMIN),
            "/api/rides/", Set.of(ROLE_DRIVER, ROLE_COMPANY, ROLE_ADMIN),
            "/api/companies/", Set.of(ROLE_DRIVER, ROLE_COMPANY, ROLE_ADMIN),
            "/api/campaigns/", Set.of(ROLE_DRIVER, ROLE_COMPANY, ROLE_ADMIN),
            "/api/messages/", Set.of(ROLE_DRIVER, ROLE_COMPANY, ROLE_ADMIN)
    );

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();

        boolean isApiPath = PATH_ROLE_RULES.keySet().stream().anyMatch(path::startsWith);
        if (!isApiPath) {
            return chain.filter(exchange);
        }

        List<String> roleHeader = exchange.getRequest().getHeaders().get("X-User-Role");
        if (roleHeader == null || roleHeader.isEmpty()) {
            return Mono.error(new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing role claim"));
        }
        String role = roleHeader.getFirst();

        Set<String> allowed = PATH_ROLE_RULES.entrySet().stream()
                .filter(e -> path.startsWith(e.getKey()))
                .map(Map.Entry::getValue)
                .findFirst()
                .orElse(Set.of());

        if (!allowed.contains(role)) {
            return Mono.error(new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Role " + role + " is not permitted to access " + path));
        }

        return chain.filter(exchange);
    }
}
