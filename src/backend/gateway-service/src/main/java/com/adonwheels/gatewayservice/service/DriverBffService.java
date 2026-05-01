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

    public Mono<DriverHomePageResponse> getDriverHomePage(Long driverId) {
        return driverClient.get()
                .uri("/drivers/{id}", driverId)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<Driver>>() {})
                .map(ApiResponse::getData)
                .flatMap(driver -> {
                    Mono<Ride> activeRideMono = rideClient.get()
                            .uri("/rides/{driverId}/active", driverId)
                            .retrieve()
                            .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                            .bodyToMono(new ParameterizedTypeReference<ApiResponse<Ride>>() {})
                            .map(ApiResponse::getData)
                            .onErrorResume(e -> Mono.empty());

                    Mono<RideStatistics> statisticsMono = rideClient.get()
                            .uri("/rides/{driverId}/statistics", driverId)
                            .retrieve()
                            .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                            .bodyToMono(new ParameterizedTypeReference<ApiResponse<RideStatistics>>() {})
                            .map(ApiResponse::getData)
                            .onErrorResume(e -> Mono.empty());

                    return Mono.zip(
                            activeRideMono.defaultIfEmpty(createEmptyRide()),
                            statisticsMono.defaultIfEmpty(createEmptyStatistics())
                    ).flatMap(tuple -> {
                        Ride activeRide = tuple.getT1().getId() != null ? tuple.getT1() : null;
                        RideStatistics statistics = tuple.getT2();

                        if (activeRide != null && activeRide.getCampaignId() != null) {
                            return campaignClient.get()
                                    .uri("/campaigns/{id}", activeRide.getCampaignId())
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

    public Mono<RideStatistics> getDriverStatistics(Long driverId) {
        return rideClient.get()
                .uri("/rides/{driverId}/statistics", driverId)
                .retrieve()
                .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<RideStatistics>>() {})
                .map(ApiResponse::getData)
                .onErrorReturn(createEmptyStatistics())
                .defaultIfEmpty(createEmptyStatistics());
    }

    public Mono<List<Ride>> getDriverRideHistory(Long driverId, Integer limit) {
        return rideClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/rides/{driverId}/history")
                        .queryParam("limit", limit)
                        .build(driverId))
                .retrieve()
                .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<List<Ride>>>() {})
                .map(ApiResponse::getData)
                .onErrorReturn(Collections.emptyList())
                .defaultIfEmpty(Collections.emptyList());
    }

    public Mono<Void> deleteDriverRideHistory(Long driverId) {
        return rideClient.delete()
                .uri("/rides/{driverId}/history", driverId)
                .retrieve()
                .bodyToMono(Void.class);
    }

    private Ride createEmptyRide() {
        return new Ride();
    }

    private RideStatistics createEmptyStatistics() {
        return new RideStatistics(0L, 0L, 0L, 0, 0, 0L);
    }
}
