package com.adonwheels.rideservice.controller;

import com.adonwheels.rideservice.dto.ActiveRideResponse;
import com.adonwheels.rideservice.dto.EndRideRequest;
import com.adonwheels.rideservice.dto.EndRideResponse;
import com.adonwheels.rideservice.dto.RideHistoryResponse;
import com.adonwheels.rideservice.dto.RideStatisticsResponse;
import com.adonwheels.rideservice.dto.StartRideRequest;
import com.adonwheels.rideservice.dto.StartRideResponse;
import com.adonwheels.rideservice.dto.TrackRequest;
import com.adonwheels.rideservice.service.RideService;
import dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/rides")
public class RideController {

    private final RideService rideService;

    public RideController(RideService rideService) {
        this.rideService = rideService;
    }

    @PostMapping("/start")
    public ResponseEntity<ApiResponse<StartRideResponse>> startRide(
            @Valid @RequestBody StartRideRequest request) {
        StartRideResponse response = rideService.startRide(request.getDriverId());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
    }

    @PostMapping("/track")
    public ResponseEntity<Void> trackPoint(@Valid @RequestBody TrackRequest request) {
        rideService.trackPoint(request.getRideId(), request.getLat(), request.getLon());
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/end")
    public ResponseEntity<ApiResponse<EndRideResponse>> endRide(
            @Valid @RequestBody EndRideRequest request) {
        EndRideResponse response = rideService.endRide(request.getRideId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/{driverId}/active")
    public ResponseEntity<ApiResponse<ActiveRideResponse>> getActiveRide(
            @PathVariable("driverId") Long driverId) {
        return rideService.getActiveRide(driverId)
                .map(ride -> ResponseEntity.ok(ApiResponse.success(ride)))
                .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.error(dto.AppErrorCode.RIDE_NOT_ACTIVE)));
    }

    @GetMapping("/{driverId}/history")
    public ResponseEntity<ApiResponse<List<RideHistoryResponse>>> getHistory(
            @PathVariable("driverId") Long driverId,
            @RequestParam(value = "limit", defaultValue = "50") int limit) {
        return ResponseEntity.ok(ApiResponse.success(rideService.getHistory(driverId, limit)));
    }

    @GetMapping("/{driverId}/statistics")
    public ResponseEntity<ApiResponse<RideStatisticsResponse>> getStatistics(
            @PathVariable("driverId") Long driverId) {
        return ResponseEntity.ok(ApiResponse.success(rideService.getStatistics(driverId)));
    }
}
