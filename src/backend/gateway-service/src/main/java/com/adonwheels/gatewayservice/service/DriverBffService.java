package com.adonwheels.gatewayservice.service;

import com.adonwheels.dto.ApiResponse;
import com.adonwheels.gatewayservice.dto.Campaign;
import com.adonwheels.gatewayservice.dto.Driver;
import com.adonwheels.gatewayservice.dto.DriverHomePageResponse;
import com.adonwheels.gatewayservice.dto.Ride;
import com.adonwheels.gatewayservice.dto.RideStatistics;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Collections;
import java.util.List;

@Service
public class DriverBffService {

    private final WebClient driverClient;
    private final WebClient campaignClient;
    private final WebClient rideClient;

    public DriverBffService(@Qualifier("driverClient") WebClient driverClient,
                            @Qualifier("campaignClient") WebClient campaignClient,
                            @Qualifier("rideClient") WebClient rideClient) {
        this.driverClient = driverClient;
        this.campaignClient = campaignClient;
        this.rideClient = rideClient;
    }

    // After A1, every downstream /drivers/{id} and /rides/{driverId}/* enforces
    // X-User-Id == driverId. The outbound WebClients here would otherwise drop
    // those headers (they only live on the inbound exchange), so we forward
    // them per call. ADMIN bypasses the downstream check via X-User-Role.
    public Mono<DriverHomePageResponse> getDriverHomePage(Long driverId, String callerId, String callerRole) {
        return driverClient.get()
                .uri("/drivers/{id}", driverId)
                .headers(h -> stampCallerHeaders(h, callerId, callerRole))
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<Driver>>() {})
                .map(ApiResponse::getData)
                .flatMap(driver -> {
                    Mono<Ride> activeRideMono = rideClient.get()
                            .uri("/rides/{driverId}/active", driverId)
                            .headers(h -> stampCallerHeaders(h, callerId, callerRole))
                            .retrieve()
                            .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                            .bodyToMono(new ParameterizedTypeReference<ApiResponse<Ride>>() {})
                            .map(ApiResponse::getData)
                            .onErrorResume(e -> Mono.empty());

                    Mono<RideStatistics> statisticsMono = rideClient.get()
                            .uri("/rides/{driverId}/statistics", driverId)
                            .headers(h -> stampCallerHeaders(h, callerId, callerRole))
                            .retrieve()
                            .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                            .bodyToMono(new ParameterizedTypeReference<ApiResponse<RideStatistics>>() {})
                            .map(ApiResponse::getData)
                            .onErrorResume(e -> Mono.empty());

                    return Mono.zip(
                            activeRideMono.defaultIfEmpty(EMPTY_RIDE),
                            statisticsMono.defaultIfEmpty(EMPTY_STATS)
                    ).flatMap(tuple -> {
                        Ride activeRide = tuple.getT1().id() != null ? tuple.getT1() : null;
                        RideStatistics statistics = tuple.getT2();

                        if (activeRide != null && activeRide.campaignId() != null) {
                            return campaignClient.get()
                                    .uri("/campaigns/{id}", activeRide.campaignId())
                                    .headers(h -> stampCallerHeaders(h, callerId, callerRole))
                                    .retrieve()
                                    .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                                    .bodyToMono(new ParameterizedTypeReference<ApiResponse<Campaign>>() {})
                                    .map(ApiResponse::getData)
                                    .map(campaign -> new DriverHomePageResponse(driver, activeRide, campaign, statistics))
                                    .onErrorReturn(new DriverHomePageResponse(driver, activeRide, null, statistics))
                                    .defaultIfEmpty(new DriverHomePageResponse(driver, activeRide, null, statistics));
                        } else {
                            return Mono.just(new DriverHomePageResponse(driver, activeRide, null, statistics));
                        }
                    });
                });
    }

    public Mono<RideStatistics> getDriverStatistics(Long driverId, String callerId, String callerRole) {
        return rideClient.get()
                .uri("/rides/{driverId}/statistics", driverId)
                .headers(h -> stampCallerHeaders(h, callerId, callerRole))
                .retrieve()
                .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<RideStatistics>>() {})
                .map(ApiResponse::getData)
                .onErrorReturn(EMPTY_STATS)
                .defaultIfEmpty(EMPTY_STATS);
    }

    public Mono<List<Ride>> getDriverRideHistory(Long driverId, Integer limit, String callerId, String callerRole) {
        return rideClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/rides/{driverId}/history")
                        .queryParam("limit", limit)
                        .build(driverId))
                .headers(h -> stampCallerHeaders(h, callerId, callerRole))
                .retrieve()
                .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<List<Ride>>>() {})
                .map(ApiResponse::getData)
                .onErrorReturn(Collections.emptyList())
                .defaultIfEmpty(Collections.emptyList());
    }

    public Mono<Void> deleteDriverRideHistory(Long driverId, String callerId, String callerRole) {
        return rideClient.delete()
                .uri("/rides/{driverId}/history", driverId)
                .headers(h -> stampCallerHeaders(h, callerId, callerRole))
                .retrieve()
                .bodyToMono(Void.class);
    }

    private static void stampCallerHeaders(org.springframework.http.HttpHeaders headers,
                                           String callerId, String callerRole) {
        if (callerId != null) {
            headers.set("X-User-Id", callerId);
        }
        if (callerRole != null) {
            headers.set("X-User-Role", callerRole);
        }
    }

    private static final Ride EMPTY_RIDE = new Ride(
            null, null, null, null, null, null, null, null,
            null, null, null, null, null, null, null, null);

    private static final RideStatistics EMPTY_STATS = new RideStatistics(
            0L, 0L, 0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
}
