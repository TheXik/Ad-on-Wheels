package com.example.gatewayservice.controller;

import com.example.gatewayservice.dto.DriverHomePageResponse;
import com.example.gatewayservice.service.DriverBffService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/drivers")
public class DriverBffController {
    private final DriverBffService driverBffService;

    public DriverBffController(DriverBffService driverBffService) {
        this.driverBffService = driverBffService;
    }

    @GetMapping(value = "/{driverId}/home", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<DriverHomePageResponse> getDriverHomePage(@PathVariable("driverId") Long driverId) {
        return driverBffService.getDriverHomePage(driverId);
    }
}
