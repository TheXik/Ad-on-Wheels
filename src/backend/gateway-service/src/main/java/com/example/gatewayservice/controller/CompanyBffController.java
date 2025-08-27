package com.example.gatewayservice.controller;

import com.example.gatewayservice.dto.ApplicationWithDriver;
import com.example.gatewayservice.service.CompanyBffService;
import org.springframework.beans.factory.annotation.Autowired;
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
    public Mono<List<ApplicationWithDriver>> getApplicationsWithDrivers(@PathVariable Long companyId) {
        return companyBffService.getApplicationsWithDrivers(companyId);
    }
} 