package com.adonwheels.gatewayservice.service;

import com.adonwheels.gatewayservice.dto.ApiResponseWrapper;
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
                .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<List<Campaign>>>() {})
                .map(ApiResponseWrapper::getData)
                .flatMapMany(campaigns -> {
                    List<Campaign> companyCampaigns = campaigns.stream()
                            .filter(c -> c.getCompanyId() != null && c.getCompanyId().equals(companyId))
                            .toList();

                    if (companyCampaigns.isEmpty()) {
                        return Flux.empty();
                    }

                    return campaignClient.get()
                            .uri("/campaigns/{companyId}/applications", companyId)
                            .retrieve()
                            .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<List<Application>>>() {})
                            .map(ApiResponseWrapper::getData)
                            .flatMapMany(applications -> {
                                List<Long> campaignIds = companyCampaigns.stream()
                                        .map(Campaign::getId)
                                        .toList();

                                return Flux.fromIterable(applications)
                                        .filter(app -> campaignIds.contains(app.getCampaignId()))
                                        .flatMap(app -> {
                                            String campaignName = companyCampaigns.stream()
                                                    .filter(c -> c.getId().equals(app.getCampaignId()))
                                                    .map(Campaign::getName)
                                                    .findFirst().orElse("");

                                            return driverClient.get()
                                                    .uri("/drivers/{id}", app.getDriverId())
                                                    .retrieve()
                                                    .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<Driver>>() {})
                                                    .map(ApiResponseWrapper::getData)
                                                    .map(driver -> new ApplicationWithDriver(
                                                            app.getId(),
                                                            app.getCampaignId(),
                                                            campaignName,
                                                            app.getStatus(),
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
                .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<List<Campaign>>>() {})
                .map(ApiResponseWrapper::getData)
                .flatMap(campaigns -> {
                    if (campaigns.isEmpty()) {
                        return Mono.just(Collections.<CampaignWithStats>emptyList());
                    }

                    String ids = campaigns.stream()
                            .map(c -> String.valueOf(c.getId()))
                            .collect(Collectors.joining(","));

                    return rideClient.get()
                            .uri(uriBuilder -> uriBuilder
                                    .path("/rides/campaigns/statistics")
                                    .queryParam("ids", ids)
                                    .build())
                            .retrieve()
                            .bodyToMono(new ParameterizedTypeReference<ApiResponseWrapper<List<CampaignRideStats>>>() {})
                            .map(ApiResponseWrapper::getData)
                            .map(statsList -> {
                                Map<Long, CampaignRideStats> statsMap = statsList.stream()
                                        .collect(Collectors.toMap(CampaignRideStats::getCampaignId, s -> s));

                                return campaigns.stream().map(campaign -> {
                                    CampaignRideStats stats = statsMap.getOrDefault(campaign.getId(),
                                            new CampaignRideStats(campaign.getId(), 0, 0.0, 0, 0.0, 0));
                                    return new CampaignWithStats(campaign, stats);
                                }).toList();
                            })
                            .onErrorReturn(campaigns.stream()
                                    .map(c -> new CampaignWithStats(c, new CampaignRideStats(c.getId(), 0, 0.0, 0, 0.0, 0)))
                                    .toList());
                });
    }

    public Mono<byte[]> exportEnrichedCsv(Long companyId) {
        return getCampaignStats(companyId).map(stats -> {
            StringBuilder csv = new StringBuilder();
            csv.append("Campaign ID,Name,Status,Start Date,End Date,Budget,Max Drivers,Est. Reach,Km Driven,Rides,Earnings Paid,Active Drivers\n");
            for (CampaignWithStats cs : stats) {
                Campaign c = cs.getCampaign();
                CampaignRideStats r = cs.getRideStats();
                csv.append(c.getId()).append(",\"")
                   .append(c.getName().replace("\"", "\"\"")).append("\",")
                   .append(c.getStatus()).append(",")
                   .append(c.getStartDate()).append(",")
                   .append(c.getEndDate()).append(",")
                   .append(c.getBudget()).append(",")
                   .append(c.getMaxDrivers()).append(",")
                   .append(c.getEstimatedReach() != null ? c.getEstimatedReach() : "N/A").append(",")
                   .append(String.format("%.2f", r.getTotalDistanceKm())).append(",")
                   .append(r.getTotalRides()).append(",")
                   .append(String.format("%.2f", r.getTotalEarnings())).append(",")
                   .append(r.getActiveDriverCount())
                   .append("\n");
            }
            return csv.toString().getBytes();
        });
    }
}
