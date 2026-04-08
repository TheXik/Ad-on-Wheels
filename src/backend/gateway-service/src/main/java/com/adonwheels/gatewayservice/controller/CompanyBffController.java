package com.adonwheels.gatewayservice.controller;

import com.adonwheels.gatewayservice.dto.ApiResponseWrapper;
import com.adonwheels.gatewayservice.dto.ApplicationWithDriver;
import com.adonwheels.gatewayservice.dto.CampaignWithStats;
import com.adonwheels.gatewayservice.service.CompanyBffService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/api/companies")
public class CompanyBffController {
    private final CompanyBffService companyBffService;

    @Autowired
    public CompanyBffController(CompanyBffService companyBffService) {
        this.companyBffService = companyBffService;
    }

    @GetMapping(value = "/{companyId}/applications-with-drivers", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ApiResponseWrapper<List<ApplicationWithDriver>>> getApplicationsWithDrivers(@PathVariable Long companyId) {
        return companyBffService.getApplicationsWithDrivers(companyId)
                .map(ApiResponseWrapper::success);
    }

    @GetMapping(value = "/{companyId}/campaign-stats", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ApiResponseWrapper<List<CampaignWithStats>>> getCampaignStats(@PathVariable Long companyId) {
        return companyBffService.getCampaignStats(companyId)
                .map(ApiResponseWrapper::success);
    }

    @GetMapping(value = "/{companyId}/export-csv", produces = "text/csv")
    public Mono<byte[]> exportEnrichedCsv(@PathVariable Long companyId) {
        return companyBffService.exportEnrichedCsv(companyId);
    }
}
