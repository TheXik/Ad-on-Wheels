package com.adonwheels.campaignservice.service;

import com.adonwheels.campaignservice.model.Application;
import com.adonwheels.campaignservice.model.ApplicationStatus;
import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.CampaignStatus;
import com.adonwheels.campaignservice.repository.ApplicationRepository;
import com.adonwheels.campaignservice.repository.CampaignRepository;
import com.adonwheels.dto.ApiResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// Catches campaigns that ran out of time before filling, and ends the cooperation
// with their accepted drivers by transitioning ACCEPTED applications to EXPIRED.
// The capacity-fill path is handled inline in ApplicationService.accept and only
// flips campaign status (driving continues until the end date).
@Component
public class CampaignLifecycleScheduler {

    private static final Logger logger = LoggerFactory.getLogger(CampaignLifecycleScheduler.class);

    private final CampaignRepository campaignRepository;
    private final ApplicationRepository applicationRepository;
    private final RestClient rideClient;

    public CampaignLifecycleScheduler(CampaignRepository campaignRepository,
                                      ApplicationRepository applicationRepository,
                                      @Qualifier("rideClient") RestClient rideClient) {
        this.campaignRepository = campaignRepository;
        this.applicationRepository = applicationRepository;
        this.rideClient = rideClient;
    }

    @Scheduled(cron = "0 0 1 * * *", zone = "UTC")
    @Transactional
    public void transitionExpiredCampaigns() {
        LocalDate today = LocalDate.now();

        // Pass 1: campaigns that ran out of time before filling
        // (RECRUITING + endDate<today). Flip to COMPLETED and cascade
        // ACCEPTED applications to EXPIRED.
        List<Campaign> expired = campaignRepository.findByStatusAndEndDateBefore(
                CampaignStatus.RECRUITING, today);
        int recruitingExpired = 0;
        int recruitingAppsExpired = 0;
        if (!expired.isEmpty()) {
            expired.forEach(c -> c.setStatus(CampaignStatus.COMPLETED));
            campaignRepository.saveAll(expired);
            recruitingExpired = expired.size();
            recruitingAppsExpired = expireAcceptedApplications(
                    expired.stream().map(Campaign::getId).toList());
        }

        // Pass 2: end-date cascade for campaigns that already filled
        // (COMPLETED via maxDrivers fill in ApplicationService.accept) but
        // whose endDate has now passed. Their ACCEPTED applications stay
        // ACCEPTED until this pass marks them EXPIRED so dashboards can
        // distinguish active cooperations from terminated ones.
        List<Campaign> endDatePassed = campaignRepository.findByStatusAndEndDateBefore(
                CampaignStatus.COMPLETED, today);
        int endDateAppsExpired = 0;
        int endDateCampaignsProcessed = 0;
        if (!endDatePassed.isEmpty()) {
            endDateAppsExpired = expireAcceptedApplications(
                    endDatePassed.stream().map(Campaign::getId).toList());
            endDateCampaignsProcessed = endDatePassed.size();
        }

        if (recruitingExpired > 0 || recruitingAppsExpired > 0) {
            logger.info("Lifecycle scheduler: transitioned {} expired campaigns to COMPLETED " +
                    "and {} accepted applications to EXPIRED",
                    recruitingExpired, recruitingAppsExpired);
        }
        if (endDateCampaignsProcessed > 0 || endDateAppsExpired > 0) {
            logger.info("End-date EXPIRED cascade: {} campaigns processed, {} applications expired",
                    endDateCampaignsProcessed, endDateAppsExpired);
        }

        // Pass 3: budget enforcement (A13). Walk RECRUITING campaigns whose
        // cumulative verified earnings (paid driver compensation) have hit or
        // exceeded their declared budget. Flip to COMPLETED and cascade
        // ACCEPTED applications to EXPIRED -- same terminal state as the
        // capacity-fill and end-date paths so dashboards stay consistent.
        runBudgetEnforcementPass();
    }

    void runBudgetEnforcementPass() {
        List<Campaign> recruiting = campaignRepository.findByStatus(CampaignStatus.RECRUITING);
        if (recruiting.isEmpty()) {
            return;
        }
        List<Long> ids = recruiting.stream().map(Campaign::getId).toList();
        Map<Long, BigDecimal> totals = fetchEarningsTotals(ids);
        if (totals.isEmpty()) {
            return;
        }
        List<Campaign> overBudget = recruiting.stream()
                .filter(c -> {
                    BigDecimal spent = totals.get(c.getId());
                    return spent != null && c.getBudget() != null
                            && spent.compareTo(c.getBudget()) >= 0;
                })
                .toList();
        if (overBudget.isEmpty()) {
            return;
        }
        overBudget.forEach(c -> c.setStatus(CampaignStatus.COMPLETED));
        campaignRepository.saveAll(overBudget);
        int appsExpired = expireAcceptedApplications(
                overBudget.stream().map(Campaign::getId).toList());
        logger.info("Budget enforcement: {} campaigns flipped to COMPLETED, {} applications expired",
                overBudget.size(), appsExpired);
    }

    // Cross-service call to ride-service. Returns an empty map on error so a
    // ride-service outage does not crash the lifecycle pass; budget enforcement
    // simply waits for the next daily run.
    private Map<Long, BigDecimal> fetchEarningsTotals(List<Long> campaignIds) {
        try {
            String ids = campaignIds.stream().map(String::valueOf).reduce((a, b) -> a + "," + b).orElse("");
            ApiResponse<Map<Long, BigDecimal>> response = rideClient.get()
                    .uri("/rides/campaigns/earnings-totals?ids={ids}", ids)
                    .retrieve()
                    .body(new ParameterizedTypeReference<ApiResponse<Map<Long, BigDecimal>>>() {});
            if (response == null || response.getData() == null) {
                return Map.of();
            }
            // Jackson may deserialise the JSON-object keys as Strings; normalise.
            Map<Long, BigDecimal> normalised = new HashMap<>();
            response.getData().forEach((k, v) -> {
                Long key = (k instanceof Long l) ? l : Long.valueOf(String.valueOf(k));
                normalised.put(key, v);
            });
            return normalised;
        } catch (Exception e) {
            logger.warn("Budget pass: failed to fetch earnings totals from ride-service: {}", e.getMessage());
            return Map.of();
        }
    }

    // Flips every ACCEPTED application of the given campaigns to EXPIRED.
    // Returns the number of applications mutated.
    private int expireAcceptedApplications(List<Long> campaignIds) {
        if (campaignIds.isEmpty()) {
            return 0;
        }
        List<Application> acceptedApps = applicationRepository.findByCampaignIdIn(campaignIds).stream()
                .filter(a -> a.getStatus() == ApplicationStatus.ACCEPTED)
                .toList();
        if (acceptedApps.isEmpty()) {
            return 0;
        }
        acceptedApps.forEach(a -> a.setStatus(ApplicationStatus.EXPIRED));
        applicationRepository.saveAll(acceptedApps);
        return acceptedApps.size();
    }
}
