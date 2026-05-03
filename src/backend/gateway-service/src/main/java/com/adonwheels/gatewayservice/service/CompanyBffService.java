package com.adonwheels.gatewayservice.service;

import com.adonwheels.dto.ApiResponse;
import com.adonwheels.gatewayservice.dto.Application;
import com.adonwheels.gatewayservice.dto.ApplicationWithDriver;
import com.adonwheels.gatewayservice.dto.Campaign;
import com.adonwheels.gatewayservice.dto.CampaignRideStats;
import com.adonwheels.gatewayservice.dto.CampaignWithStats;
import com.adonwheels.gatewayservice.dto.Driver;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class CompanyBffService {

    private final WebClient campaignClient;
    private final WebClient driverClient;
    private final WebClient rideClient;

    public CompanyBffService(@Qualifier("campaignClient") WebClient campaignClient,
                             @Qualifier("driverClient") WebClient driverClient,
                             @Qualifier("rideClient") WebClient rideClient) {
        this.campaignClient = campaignClient;
        this.driverClient = driverClient;
        this.rideClient = rideClient;
    }

    public Mono<List<ApplicationWithDriver>> getApplicationsWithDrivers(Long companyId) {
        return campaignClient.get()
                .uri("/campaigns")
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<List<Campaign>>>() {})
                .map(ApiResponse::getData)
                .flatMapMany(campaigns -> {
                    List<Campaign> companyCampaigns = campaigns.stream()
                            .filter(c -> c.companyId() != null && c.companyId().equals(companyId))
                            .toList();

                    if (companyCampaigns.isEmpty()) {
                        return Flux.empty();
                    }

                    return campaignClient.get()
                            .uri("/campaigns/{companyId}/applications", companyId)
                            .retrieve()
                            .bodyToMono(new ParameterizedTypeReference<ApiResponse<List<Application>>>() {})
                            .map(ApiResponse::getData)
                            .flatMapMany(applications -> {
                                List<Long> campaignIds = companyCampaigns.stream()
                                        .map(Campaign::id)
                                        .toList();

                                return Flux.fromIterable(applications)
                                        .filter(app -> campaignIds.contains(app.campaignId()))
                                        .flatMap(app -> {
                                            String campaignName = companyCampaigns.stream()
                                                    .filter(c -> c.id().equals(app.campaignId()))
                                                    .map(Campaign::name)
                                                    .findFirst().orElse("");

                                            return driverClient.get()
                                                    .uri("/drivers/{id}", app.driverId())
                                                    .retrieve()
                                                    .bodyToMono(new ParameterizedTypeReference<ApiResponse<Driver>>() {})
                                                    .map(ApiResponse::getData)
                                                    .map(driver -> new ApplicationWithDriver(
                                                            app.id(),
                                                            app.campaignId(),
                                                            campaignName,
                                                            app.status(),
                                                            driver
                                                    ));
                                        });
                            });
                })
                .collectList()
                .defaultIfEmpty(Collections.emptyList());
    }

    public Mono<List<CampaignWithStats>> getCampaignStats(Long companyId) {
        return campaignClient.get()
                .uri("/campaigns/company/{companyId}", companyId)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<List<Campaign>>>() {})
                .map(ApiResponse::getData)
                .flatMap(campaigns -> {
                    if (campaigns.isEmpty()) {
                        return Mono.just(Collections.<CampaignWithStats>emptyList());
                    }

                    String ids = campaigns.stream()
                            .map(c -> String.valueOf(c.id()))
                            .collect(Collectors.joining(","));

                    return rideClient.get()
                            .uri(uriBuilder -> uriBuilder
                                    .path("/rides/campaigns/statistics")
                                    .queryParam("ids", ids)
                                    .build())
                            .retrieve()
                            .bodyToMono(new ParameterizedTypeReference<ApiResponse<List<CampaignRideStats>>>() {})
                            .map(ApiResponse::getData)
                            .map(statsList -> {
                                Map<Long, CampaignRideStats> statsMap = statsList.stream()
                                        .collect(Collectors.toMap(CampaignRideStats::campaignId, s -> s));

                                return campaigns.stream().map(campaign -> {
                                    CampaignRideStats stats = statsMap.getOrDefault(campaign.id(),
                                            new CampaignRideStats(campaign.id(), 0, 0.0, 0, 0.0, 0));
                                    return new CampaignWithStats(campaign, stats);
                                }).toList();
                            })
                            .onErrorReturn(campaigns.stream()
                                    .map(c -> new CampaignWithStats(c, new CampaignRideStats(c.id(), 0, 0.0, 0, 0.0, 0)))
                                    .toList());
                });
    }

    public Mono<byte[]> exportEnrichedCsv(Long companyId) {
        return getCampaignStats(companyId).map(stats -> {
            StringBuilder csv = new StringBuilder();
            csv.append("Campaign ID,Name,Status,Start Date,End Date,Budget,Max Drivers,Est. Reach,Km Driven,Rides,Earnings Paid,Active Drivers\n");
            for (CampaignWithStats cs : stats) {
                Campaign c = cs.campaign();
                CampaignRideStats r = cs.rideStats();
                csv.append(c.id()).append(",\"")
                   .append(c.name().replace("\"", "\"\"")).append("\",")
                   .append(c.status()).append(",")
                   .append(c.startDate()).append(",")
                   .append(c.endDate()).append(",")
                   .append(c.budget()).append(",")
                   .append(c.maxDrivers()).append(",")
                   .append(c.estimatedReach() != null ? c.estimatedReach() : "N/A").append(",")
                   .append(String.format("%.2f", r.totalDistanceKm())).append(",")
                   .append(r.totalRides()).append(",")
                   .append(String.format("%.2f", r.totalEarnings())).append(",")
                   .append(r.activeDriverCount())
                   .append("\n");
            }
            return ('\uFEFF' + csv.toString()).getBytes(StandardCharsets.UTF_8);
        });
    }
}
