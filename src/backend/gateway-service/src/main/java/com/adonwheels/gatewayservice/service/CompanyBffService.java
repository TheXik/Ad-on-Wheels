package com.adonwheels.gatewayservice.service;

import com.adonwheels.gatewayservice.dto.ApiResponseWrapper;
import com.adonwheels.gatewayservice.dto.Application;
import com.adonwheels.gatewayservice.dto.ApplicationWithDriver;
import com.adonwheels.gatewayservice.dto.Campaign;
import com.adonwheels.gatewayservice.dto.Driver;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.Collections;
import java.util.List;

@Service
public class CompanyBffService {

    private final WebClient campaignClient;
    private final WebClient driverClient;

    public CompanyBffService(@Qualifier("campaignClient") WebClient campaignClient,
                             @Qualifier("driverClient") WebClient driverClient) {
        this.campaignClient = campaignClient;
        this.driverClient = driverClient;
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
}
