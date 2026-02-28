package com.example.gatewayservice.service;

import com.example.gatewayservice.dto.ApiResponseWrapper;
import com.example.gatewayservice.dto.Campaign;
import com.example.gatewayservice.dto.Driver;
import com.example.gatewayservice.dto.DriverHomePageResponse;
import com.example.gatewayservice.dto.Ride;
import com.example.gatewayservice.dto.RideStatistics;
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

    public DriverBffService(@Qualifier("driverClient") WebClient driverClient,
                            @Qualifier("campaignClient") WebClient campaignClient) {
        this.driverClient = driverClient;
        this.campaignClient = campaignClient;
    }

    public Mono<DriverHomePageResponse> getDriverHomePage(Long driverId) {
        // Fetch driver information (required)
        return driverClient.get()
                .uri("/drivers/{id}", driverId)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<Driver>>() {})
                .map(ApiResponseWrapper::getData)
                .flatMap(driver -> {
                    // Fetch active ride (optional - might not exist, 404 is expected)
                    Mono<Ride> activeRideMono = driverClient.get()
                            .uri("/rides/{driverId}/active", driverId)
                            .retrieve()
                            .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                            .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<Ride>>() {})
                            .map(ApiResponseWrapper::getData)
                            .onErrorResume(e -> Mono.empty());

                    // Fetch ride statistics (optional)
                    Mono<RideStatistics> statisticsMono = driverClient.get()
                            .uri("/rides/{driverId}/statistics", driverId)
                            .retrieve()
                            .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                            .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<RideStatistics>>() {})
                            .map(ApiResponseWrapper::getData)
                            .onErrorResume(e -> Mono.empty());

                    // Combine active ride and statistics
                    return Mono.zip(
                            activeRideMono.defaultIfEmpty(createEmptyRide()),
                            statisticsMono.defaultIfEmpty(createEmptyStatistics())
                    ).flatMap(tuple -> {
                        Ride activeRide = tuple.getT1().getId() != null ? tuple.getT1() : null;
                        RideStatistics statistics = tuple.getT2();

                        // If there's an active ride with a campaign, fetch campaign details
                        if (activeRide != null && activeRide.getCampaignId() != null) {
                            return campaignClient.get()
                                    .uri("/campaigns/{id}", activeRide.getCampaignId())
                                    .retrieve()
                                    .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                                    .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<Campaign>>() {})
                                    .map(ApiResponseWrapper::getData)
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
        return driverClient.get()
                .uri("/rides/{driverId}/statistics", driverId)
                .retrieve()
                .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<RideStatistics>>() {})
                .map(ApiResponseWrapper::getData)
                .onErrorReturn(createEmptyStatistics())
                .defaultIfEmpty(createEmptyStatistics());
    }
    
    public Mono<List<Ride>> getDriverRideHistory(Long driverId, Integer limit) {
        return driverClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/rides/{driverId}/history")
                        .queryParam("limit", limit)
                        .build(driverId))
                .retrieve()
                .onStatus(HttpStatusCode::is4xxClientError, response -> Mono.empty())
                .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<List<Ride>>>() {})
                .map(ApiResponseWrapper::getData)
                .onErrorReturn(Collections.emptyList())
                .defaultIfEmpty(Collections.emptyList());
    }

    private Ride createEmptyRide() {
        return new Ride(); // Marker for "no active ride"
    }

    private RideStatistics createEmptyStatistics() {
        return new RideStatistics(0L, 0L, 0L, 0, 0, 0L);
    }
}
