package com.adonwheels.campaignservice.service;

import com.adonwheels.campaignservice.model.Application;
import com.adonwheels.campaignservice.model.ApplicationStatus;
import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.CampaignStatus;
import com.adonwheels.campaignservice.repository.ApplicationRepository;
import com.adonwheels.campaignservice.repository.CampaignRepository;
import com.adonwheels.dto.ApiResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

// Covers the budget-enforcement pass (A13) in CampaignLifecycleScheduler.
// We mock the RestClient's fluent chain and the two repositories so the test
// stays unit-scope (no Spring context, no DB, no HTTP).
class CampaignLifecycleSchedulerTest {

    private CampaignRepository campaignRepository;
    private ApplicationRepository applicationRepository;
    private RestClient rideClient;
    private RestClient.RequestHeadersUriSpec<?> uriSpec;
    private RestClient.RequestHeadersSpec<?> headersSpec;
    private RestClient.ResponseSpec responseSpec;
    private CampaignLifecycleScheduler scheduler;

    @BeforeEach
    @SuppressWarnings("unchecked")
    void setUp() {
        campaignRepository = mock(CampaignRepository.class);
        applicationRepository = mock(ApplicationRepository.class);
        rideClient = mock(RestClient.class);
        uriSpec = mock(RestClient.RequestHeadersUriSpec.class);
        headersSpec = mock(RestClient.RequestHeadersSpec.class);
        responseSpec = mock(RestClient.ResponseSpec.class);

        when(rideClient.get()).thenReturn((RestClient.RequestHeadersUriSpec) uriSpec);
        when(uriSpec.uri(anyString(), any(Object[].class))).thenReturn((RestClient.RequestHeadersSpec) headersSpec);
        when(headersSpec.retrieve()).thenReturn(responseSpec);

        scheduler = new CampaignLifecycleScheduler(
                campaignRepository, applicationRepository, rideClient);
    }

    @Test
    void budgetPass_flipsCampaignToCompletedAndCascadesApplicationsWhenSpendMeetsBudget() {
        Campaign overBudget = campaign(1L, new BigDecimal("100.00"));
        Campaign underBudget = campaign(2L, new BigDecimal("500.00"));
        when(campaignRepository.findByStatus(CampaignStatus.RECRUITING))
                .thenReturn(List.of(overBudget, underBudget));

        // Cumulative paid earnings: campaign 1 has hit budget, campaign 2 has not.
        ApiResponse<Map<Long, BigDecimal>> apiResponse = ApiResponse.success(Map.of(
                1L, new BigDecimal("120.00"),
                2L, new BigDecimal("250.00")
        ));
        when(responseSpec.body(any(ParameterizedTypeReference.class))).thenReturn(apiResponse);

        Application accepted = application(10L, 1L, ApplicationStatus.ACCEPTED);
        Application stillApplied = application(11L, 1L, ApplicationStatus.APPLIED);
        when(applicationRepository.findByCampaignIdIn(List.of(1L)))
                .thenReturn(List.of(accepted, stillApplied));

        scheduler.runBudgetEnforcementPass();

        // Only campaign 1 flips.
        ArgumentCaptor<List<Campaign>> campaignsSaved = ArgumentCaptor.forClass(List.class);
        verify(campaignRepository).saveAll(campaignsSaved.capture());
        List<Campaign> saved = campaignsSaved.getValue();
        assertThat(saved).hasSize(1);
        assertThat(saved.get(0).getId()).isEqualTo(1L);
        assertThat(saved.get(0).getStatus()).isEqualTo(CampaignStatus.COMPLETED);

        // Only the ACCEPTED application cascades to EXPIRED; APPLIED is left alone.
        ArgumentCaptor<List<Application>> appsSaved = ArgumentCaptor.forClass(List.class);
        verify(applicationRepository).saveAll(appsSaved.capture());
        List<Application> savedApps = appsSaved.getValue();
        assertThat(savedApps).hasSize(1);
        assertThat(savedApps.get(0).getId()).isEqualTo(10L);
        assertThat(savedApps.get(0).getStatus()).isEqualTo(ApplicationStatus.EXPIRED);
    }

    @Test
    void budgetPass_doesNothingWhenNoCampaignHitsBudget() {
        Campaign safe = campaign(1L, new BigDecimal("100.00"));
        when(campaignRepository.findByStatus(CampaignStatus.RECRUITING)).thenReturn(List.of(safe));

        ApiResponse<Map<Long, BigDecimal>> apiResponse = ApiResponse.success(Map.of(
                1L, new BigDecimal("50.00")
        ));
        when(responseSpec.body(any(ParameterizedTypeReference.class))).thenReturn(apiResponse);

        scheduler.runBudgetEnforcementPass();

        verify(campaignRepository, never()).saveAll(any());
        verify(applicationRepository, never()).saveAll(any());
    }

    @Test
    void budgetPass_swallowsRideServiceFailureSoLifecyclePassStillFinishes() {
        when(campaignRepository.findByStatus(CampaignStatus.RECRUITING))
                .thenReturn(List.of(campaign(1L, new BigDecimal("100.00"))));
        when(responseSpec.body(any(ParameterizedTypeReference.class)))
                .thenThrow(new RuntimeException("ride-service is down"));

        // Must not throw.
        scheduler.runBudgetEnforcementPass();

        verify(campaignRepository, never()).saveAll(any());
        verify(applicationRepository, never()).saveAll(any());
    }

    private static Campaign campaign(Long id, BigDecimal budget) {
        Campaign c = new Campaign();
        c.setId(id);
        c.setBudget(budget);
        c.setStatus(CampaignStatus.RECRUITING);
        return c;
    }

    private static Application application(Long id, Long campaignId, ApplicationStatus status) {
        Application a = new Application();
        a.setId(id);
        a.setCampaignId(campaignId);
        a.setStatus(status);
        return a;
    }
}
