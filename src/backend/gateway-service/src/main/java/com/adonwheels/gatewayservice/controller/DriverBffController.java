package com.adonwheels.gatewayservice.controller;

import com.adonwheels.gatewayservice.dto.ApiResponseWrapper;
import com.adonwheels.gatewayservice.dto.DriverHomePageResponse;
import com.adonwheels.gatewayservice.dto.Ride;
import com.adonwheels.gatewayservice.dto.RideStatistics;
import com.adonwheels.gatewayservice.service.DriverBffService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/api/drivers")
public class DriverBffController {
    private final DriverBffService driverBffService;

    public DriverBffController(DriverBffService driverBffService) {
        this.driverBffService = driverBffService;
    }

    @GetMapping(value = "/{driverId}/home", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ApiResponseWrapper<DriverHomePageResponse>> getDriverHomePage(@PathVariable("driverId") Long driverId) {
        return driverBffService.getDriverHomePage(driverId)
                .map(ApiResponseWrapper::success);
    }
    
    @GetMapping(value = "/{driverId}/statistics", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ApiResponseWrapper<RideStatistics>> getDriverStatistics(@PathVariable("driverId") Long driverId) {
        return driverBffService.getDriverStatistics(driverId)
                .map(ApiResponseWrapper::success);
    }
    
    @GetMapping(value = "/{driverId}/rides", produces = MediaType.APPLICATION_JSON_VALUE)
    public Mono<ApiResponseWrapper<List<Ride>>> getDriverRideHistory(
            @PathVariable("driverId") Long driverId,
            @RequestParam(value = "limit", required = false, defaultValue = "50") Integer limit) {
        return driverBffService.getDriverRideHistory(driverId, limit)
                .map(ApiResponseWrapper::success);
    }
}
