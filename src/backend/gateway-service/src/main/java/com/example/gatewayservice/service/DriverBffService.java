package com.example.gatewayservice.service;

import com.example.gatewayservice.dto.ApiResponseWrapper;
import com.example.gatewayservice.dto.Campaign;
import com.example.gatewayservice.dto.Driver;
import com.example.gatewayservice.dto.DriverHomePageResponse;
import com.example.gatewayservice.dto.Ride;
import com.example.gatewayservice.dto.RideStatistics;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

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
                    // Fetch active ride (optional - might not exist)
                    return driverClient.get()
                            .uri("/rides/{driverId}/active", driverId)
                            .retrieve()
                            .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<Ride>>() {})
                            .map(ApiResponseWrapper::getData)
                            .onErrorResume(e -> Mono.just((Ride) null))
                            .flatMap(activeRide -> {
                                // Fetch ride statistics (optional)
                                return driverClient.get()
                                        .uri("/rides/{driverId}/statistics", driverId)
                                        .retrieve()
                                        .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<RideStatistics>>() {})
                                        .map(ApiResponseWrapper::getData)
                                        .onErrorResume(e -> Mono.just((RideStatistics) null))
                                        .flatMap(statistics -> {
                                            // If there's an active ride with a campaign, fetch campaign details
                                            if (activeRide != null && activeRide.getCampaignId() != null) {
                                                return campaignClient.get()
                                                        .uri("/campaigns/{id}", activeRide.getCampaignId())
                                                        .retrieve()
                                                        .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<Campaign>>() {})
                                                        .map(ApiResponseWrapper::getData)
                                                        .map(campaign -> new DriverHomePageResponse(driver, activeRide, campaign, statistics))
                                                        .onErrorReturn(new DriverHomePageResponse(driver, activeRide, null, statistics));
                                            } else {
                                                return Mono.just(new DriverHomePageResponse(driver, activeRide, null, statistics));
                                            }
                                        });
                            });
                });
    }
}
