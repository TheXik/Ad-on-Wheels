package com.example.gatewayservice.service;

import com.example.gatewayservice.dto.Application;
import com.example.gatewayservice.dto.ApplicationWithDriver;
import com.example.gatewayservice.dto.Campaign;
import com.example.gatewayservice.dto.Driver;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import java.util.List;

@Service
public class CompanyBffService {

    // Inject the pre-configured WebClient beans instead of the builder
    private final WebClient campaignClient;
    private final WebClient driverClient;


    public CompanyBffService(@Qualifier("campaignClient") WebClient campaignClient,
                             @Qualifier("driverClient") WebClient driverClient) {
        this.campaignClient = campaignClient;
        this.driverClient = driverClient;
    }

    public Mono<List<ApplicationWithDriver>> getApplicationsWithDrivers(Long companyId) {
        // The clients are now ready to be used directly. No more building!
        return campaignClient.get()
                .uri("/campaigns")
                .retrieve()
                .bodyToFlux(Campaign.class)
                .filter(c -> c.getCompanyId() != null && c.getCompanyId().equals(companyId))
                .collectList()
                .flatMapMany(campaigns -> {
                    if (campaigns.isEmpty()) {
                        return Mono.empty();
                    }
                    List<Long> campaignIds = campaigns.stream().map(Campaign::getId).toList();
                    return campaignClient.get()
                            .uri("/campaigns/{companyId}/applications", companyId)
                            .retrieve()
                            .bodyToFlux(Application.class)
                            .filter(app -> campaignIds.contains(app.getCampaignId()))
                            .flatMap(app -> {
                                Mono<Driver> driverMono = driverClient.get()
                                        .uri("/drivers/{id}", app.getDriverId())
                                        .retrieve()
                                        .bodyToMono(Driver.class);
                                String campaignName = campaigns.stream()
                                        .filter(c -> c.getId().equals(app.getCampaignId()))
                                        .map(Campaign::getName)
                                        .findFirst().orElse("");
                                return driverMono.map(driver -> new ApplicationWithDriver(
                                        app.getId(),
                                        app.getCampaignId(),
                                        campaignName,
                                        app.getStatus(),
                                        driver
                                ));
                            });
                })
                .collectList();
    }
}
