package com.example.driverservice.controller;

import com.example.driverservice.dto.RideStatistics;
import com.example.driverservice.dto.StartRideRequest;
import com.example.driverservice.dto.StopRideRequest;
import com.example.driverservice.dto.VerifyRideRequest;
import com.example.driverservice.model.Ride;
import com.example.driverservice.service.RideService;
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

    // POST /rides/{driverId}/start - Start a new ride
    @PostMapping("/{driverId}/start")
    public ResponseEntity<ApiResponse<Ride>> startRide(
            @PathVariable("driverId") Long driverId,
            @RequestBody(required = false) StartRideRequest request) {
        Long campaignId = request != null ? request.getCampaignId() : null;
        String startLocation = request != null ? request.getStartLocation() : null;
        Ride ride = rideService.startRide(driverId, campaignId, startLocation);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(ride));
    }

    // POST /rides/{driverId}/stop - Stop an active ride
    @PostMapping("/{driverId}/stop")
    public ResponseEntity<ApiResponse<Ride>> stopRide(
            @PathVariable("driverId") Long driverId,
            @RequestBody(required = false) StopRideRequest request) {
        String endLocation = request != null ? request.getEndLocation() : null;
        Double distanceKm = request != null ? request.getDistanceKm() : null;
        Double averageSpeedKmh = request != null ? request.getAverageSpeedKmh() : null;
        Ride ride = rideService.stopRide(driverId, endLocation, distanceKm, averageSpeedKmh);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(ride));
    }

    // GET /rides/{driverId}/history - Get ride history
    @GetMapping("/{driverId}/history")
    public ResponseEntity<ApiResponse<List<Ride>>> getRideHistory(@PathVariable("driverId") Long driverId) {
        List<Ride> rides = rideService.getRideHistory(driverId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(rides));
    }

    // GET /rides/{driverId}/active - Get active ride
    @GetMapping("/{driverId}/active")
    public ResponseEntity<ApiResponse<Ride>> getActiveRide(@PathVariable("driverId") Long driverId) {
        Ride ride = rideService.getActiveRide(driverId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(ride));
    }

    // POST /rides/{rideId}/verify - Verify ride with QR code
    @PostMapping("/{rideId}/verify")
    public ResponseEntity<ApiResponse<Ride>> verifyRide(
            @PathVariable("rideId") Long rideId,
            @Valid @RequestBody VerifyRideRequest request) {
        Ride ride = rideService.verifyRide(rideId, request.getQrCodeData());
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(ride));
    }

    // GET /rides/{driverId}/statistics - Get ride statistics for driver
    @GetMapping("/{driverId}/statistics")
    public ResponseEntity<ApiResponse<RideStatistics>> getRideStatistics(@PathVariable("driverId") Long driverId) {
        RideStatistics statistics = rideService.getRideStatistics(driverId);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(statistics));
    }
}
