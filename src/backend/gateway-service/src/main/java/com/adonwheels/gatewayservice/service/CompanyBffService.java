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
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
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

    // Caller headers come from the inbound exchange and must be re-stamped on
    // every outbound WebClient call so the per-endpoint owner-id check (A1)
    // can verify caller==companyId/driverId downstream.
    public Mono<List<ApplicationWithDriver>> getApplicationsWithDrivers(Long companyId, String callerId, String callerRole) {
        return campaignClient.get()
                .uri("/campaigns")
                .headers(h -> stampCallerHeaders(h, callerId, callerRole))
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<List<Campaign>>>() {})
                .map(ApiResponse::getData)
                .flatMap(campaigns -> {
                    List<Campaign> companyCampaigns = campaigns.stream()
                            .filter(c -> c.companyId() != null && c.companyId().equals(companyId))
                            .toList();

                    if (companyCampaigns.isEmpty()) {
                        return Mono.just(Collections.<ApplicationWithDriver>emptyList());
                    }

                    return campaignClient.get()
                            .uri("/campaigns/{companyId}/applications", companyId)
                            .headers(h -> stampCallerHeaders(h, callerId, callerRole))
                            .retrieve()
                            .bodyToMono(new ParameterizedTypeReference<ApiResponse<List<Application>>>() {})
                            .map(ApiResponse::getData)
                            .flatMap(applications -> {
                                List<Long> campaignIds = companyCampaigns.stream()
                                        .map(Campaign::id)
                                        .toList();

                                List<Application> ownApplications = applications.stream()
                                        .filter(app -> campaignIds.contains(app.campaignId()))
                                        .toList();

                                if (ownApplications.isEmpty()) {
                                    return Mono.just(Collections.<ApplicationWithDriver>emptyList());
                                }

                                List<Long> driverIds = ownApplications.stream()
                                        .map(Application::driverId)
                                        .filter(java.util.Objects::nonNull)
                                        .distinct()
                                        .toList();

                                Map<Long, String> campaignNameById = companyCampaigns.stream()
                                        .collect(Collectors.toMap(Campaign::id, Campaign::name, (a, b) -> a));

                                return fetchDriversBatch(driverIds).map(drivers -> {
                                    Map<Long, Driver> driverById = drivers.stream()
                                            .collect(Collectors.toMap(Driver::id, Function.identity(), (a, b) -> a));

                                    return ownApplications.stream()
                                            .map(app -> new ApplicationWithDriver(
                                                    app.id(),
                                                    app.campaignId(),
                                                    campaignNameById.getOrDefault(app.campaignId(), ""),
                                                    app.status(),
                                                    driverById.get(app.driverId())
                                            ))
                                            .toList();
                                });
                            });
                })
                .defaultIfEmpty(Collections.emptyList());
    }

    // /drivers/{id} requires caller==id; a company cannot satisfy that. The
    // batch /drivers?ids endpoint accepts X-User-Role: ADMIN so the BFF can
    // fan out once for all driverIds belonging to its own campaigns. The
    // outer call has already proved companyId == callerId.
    private Mono<List<Driver>> fetchDriversBatch(List<Long> ids) {
        if (ids.isEmpty()) {
            return Mono.just(Collections.emptyList());
        }
        String csv = ids.stream().map(String::valueOf).collect(Collectors.joining(","));
        return driverClient.get()
                .uri(uriBuilder -> uriBuilder.path("/drivers").queryParam("ids", csv).build())
                .headers(CompanyBffService::stampAdminHeaders)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<List<Driver>>>() {})
                .map(ApiResponse::getData);
    }

    public Mono<List<CampaignWithStats>> getCampaignStats(Long companyId, String callerId, String callerRole) {
        return campaignClient.get()
                .uri("/campaigns/company/{companyId}", companyId)
                .headers(h -> stampCallerHeaders(h, callerId, callerRole))
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
                            .headers(h -> stampCallerHeaders(h, callerId, callerRole))
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

    public Mono<byte[]> exportEnrichedCsv(Long companyId, String callerId, String callerRole) {
        return getCampaignStats(companyId, callerId, callerRole).map(stats -> {
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

    private static void stampCallerHeaders(org.springframework.http.HttpHeaders headers,
                                           String callerId, String callerRole) {
        if (callerId != null) {
            headers.set("X-User-Id", callerId);
        }
        if (callerRole != null) {
            headers.set("X-User-Role", callerRole);
        }
    }

    // Internal cross-role aggregation: a company-scoped BFF needs to read driver
    // profiles for applicants to its campaigns. Stamping role ADMIN tells the
    // downstream per-endpoint check to bypass; the outer call has already
    // proved the caller owns the company. X-User-Id is irrelevant on ADMIN
    // paths but kept for log-correlation symmetry.
    private static void stampAdminHeaders(org.springframework.http.HttpHeaders headers) {
        headers.set("X-User-Id", "0");
        headers.set("X-User-Role", "ADMIN");
    }
}
