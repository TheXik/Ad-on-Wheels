package com.adonwheels.gatewayservice.controller;

import com.adonwheels.gatewayservice.dto.ApiResponseWrapper;
import com.adonwheels.gatewayservice.dto.CampaignCoverage;
import com.adonwheels.gatewayservice.service.CoverageBffService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

/**
 * Coverage / heat-map BFF (UC014). Aggregates per-ride GPS polylines for a
 * single campaign so the company dashboard and iOS company app can render
 * a multi-route coverage map. Verified rides are flagged so clients can
 * style them solid; unverified rides render dashed / lighter.
 *
 * The path is registered under the gateway's WebFlux handler chain, which
 * runs before {@code spring.cloud.gateway.routes}, so this controller
 * intercepts the request locally instead of forwarding to campaign-service.
 */
@RestController
@RequestMapping("/api/campaigns")
public class CoverageBffController {

    private final CoverageBffService coverageBffService;

    @Autowired
    public CoverageBffController(CoverageBffService coverageBffService) {
        this.coverageBffService = coverageBffService;
    }

    @GetMapping(value = "/{campaignId}/coverage", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ApiResponseWrapper<CampaignCoverage>> getCoverage(@PathVariable Long campaignId) {
        return coverageBffService.getCampaignCoverage(campaignId)
                .map(ApiResponseWrapper::success);
    }
}
