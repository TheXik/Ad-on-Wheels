package com.example.driverservice.controller;

import com.example.driverservice.model.Ride;
import com.example.driverservice.service.RideService;
import dto.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/rides")
public class RideController {
    
    private final RideService rideService;

    public RideController(RideService rideService) {
        this.rideService = rideService;
    }

    // POST /rides/start - Start a new ride
    @PostMapping("/start")
    public ResponseEntity<ApiResponse<Ride>> startRide(@RequestBody Map<String, Long> request) {
        Long driverId = request.get("driverId");
        Long campaignId = request.get("campaignId");

        Ride ride = rideService.startRide(driverId, campaignId);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(ride));
    }

    // POST /rides/stop - Stop an active ride
    @PostMapping("/stop")
    public ResponseEntity<ApiResponse<Ride>> stopRide(@RequestBody Map<String, Long> request) {
        Long driverId = request.get("driverId");

        Ride ride = rideService.stopRide(driverId);
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
            @RequestBody Map<String, String> request) {
        String qrCodeData = request.get("qrCodeData");

        Ride ride = rideService.verifyRide(rideId, qrCodeData);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(ride));
    }
}
