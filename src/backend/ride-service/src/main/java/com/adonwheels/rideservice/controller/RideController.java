package com.adonwheels.rideservice.controller;

import com.adonwheels.rideservice.dto.EndRideRequest;
import com.adonwheels.rideservice.dto.EndRideResponse;
import com.adonwheels.rideservice.dto.StartRideRequest;
import com.adonwheels.rideservice.dto.StartRideResponse;
import com.adonwheels.rideservice.dto.TrackRequest;
import com.adonwheels.rideservice.service.RideService;
import dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/rides")
public class RideController {

    private final RideService rideService;

    public RideController(RideService rideService) {
        this.rideService = rideService;
    }

    /**
     * POST /rides/start
     * Creates a new ride session for the given driver.
     *
     * @return 201 Created with the generated {@code rideId}
     */
    @PostMapping("/start")
    public ResponseEntity<ApiResponse<StartRideResponse>> startRide(
            @Valid @RequestBody StartRideRequest request) {
        StartRideResponse response = rideService.startRide(request.getDriverId());
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }

    /**
     * POST /rides/track
     * Appends a GPS point to an active ride's route history.
     * Returns 202 Accepted immediately — designed for high-frequency, low-latency calls.
     *
     * @return 202 Accepted (no body)
     */
    @PostMapping("/track")
    public ResponseEntity<Void> trackPoint(
            @Valid @RequestBody TrackRequest request) {
        rideService.trackPoint(request.getRideId(), request.getLat(), request.getLon());
        return ResponseEntity.accepted().build();
    }

    /**
     * POST /rides/end
     * Finalises a ride: computes total distance (Haversine) and duration,
     * then removes the session from the store.
     *
     * @return 200 OK with {@code totalDistanceKm} and {@code durationSeconds}
     */
    @PostMapping("/end")
    public ResponseEntity<ApiResponse<EndRideResponse>> endRide(
            @Valid @RequestBody EndRideRequest request) {
        EndRideResponse response = rideService.endRide(request.getRideId());
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(ApiResponse.success(response));
    }
}
