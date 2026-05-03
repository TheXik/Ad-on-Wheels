package com.adonwheels.gatewayservice.controller;

import com.adonwheels.dto.ApiResponse;
import com.adonwheels.gatewayservice.dto.CampaignCoverage;
import com.adonwheels.gatewayservice.service.CoverageBffService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/campaigns")
public class CoverageBffController {

    private final CoverageBffService coverageBffService;

    public CoverageBffController(CoverageBffService coverageBffService) {
        this.coverageBffService = coverageBffService;
    }

    @GetMapping(value = "/{campaignId}/coverage", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ApiResponse<CampaignCoverage>> getCoverage(@PathVariable Long campaignId) {
        return coverageBffService.getCampaignCoverage(campaignId)
                .map(ApiResponse::success);
    }
}
