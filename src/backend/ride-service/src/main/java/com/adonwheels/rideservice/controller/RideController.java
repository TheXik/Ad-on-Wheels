package com.adonwheels.rideservice.controller;

import com.adonwheels.rideservice.dto.ActiveRideResponse;
import com.adonwheels.rideservice.dto.CampaignRideStatsResponse;
import com.adonwheels.rideservice.dto.CampaignRouteResponse;
import com.adonwheels.rideservice.dto.DeferredRideRequest;
import com.adonwheels.rideservice.dto.EndRideRequest;
import com.adonwheels.rideservice.dto.EndRideResponse;
import com.adonwheels.rideservice.dto.RideHistoryResponse;
import com.adonwheels.rideservice.dto.RideStatisticsResponse;
import com.adonwheels.rideservice.dto.RoutePointDto;
import com.adonwheels.rideservice.dto.StartRideRequest;
import com.adonwheels.rideservice.dto.StartRideResponse;
import com.adonwheels.rideservice.dto.TrackRequest;
import com.adonwheels.rideservice.service.RideService;
import com.adonwheels.dto.ApiResponse;
import com.adonwheels.dto.AppErrorCode;
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
        StartRideResponse response = rideService.startRide(request.driverId(), request.campaignId(), request.ratePerKm());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
    }

    @PostMapping("/track")
    public ResponseEntity<Void> trackPoint(@Valid @RequestBody TrackRequest request) {
        rideService.trackPoint(request.rideId(), request.lat(), request.lon());
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/end")
    public ResponseEntity<ApiResponse<EndRideResponse>> endRide(
            @Valid @RequestBody EndRideRequest request) {
        EndRideResponse response = rideService.endRide(request.rideId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/{completedRideId}/verify")
    public ResponseEntity<ApiResponse<Void>> verifyRide(@PathVariable("completedRideId") Long completedRideId) {
        rideService.verifyRide(completedRideId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * UC014 – Coverage / heat-map: returns the recorded GPS polyline for a
     * completed ride owned by the caller. Caller identity is supplied by the
     * gateway via {@code X-User-Id}.
     */
    @GetMapping("/{rideId}/route")
    public ResponseEntity<ApiResponse<List<RoutePointDto>>> getRideRoute(
            @PathVariable("rideId") Long rideId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerDriverId) {
        List<RoutePointDto> route = rideService.getRoute(rideId, callerDriverId);
        return ResponseEntity.ok(ApiResponse.success(route));
    }

    /**
     * UC013 – Deferred QR scan: logs a ride from buffered GPS data
     * when the driver forgot to scan the QR code at the start.
     */
    @PostMapping("/deferred")
    public ResponseEntity<ApiResponse<EndRideResponse>> logDeferredRide(
            @Valid @RequestBody DeferredRideRequest request) {
        EndRideResponse response = rideService.logDeferredRide(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
    }

    @GetMapping("/{driverId}/active")
    public ResponseEntity<ApiResponse<ActiveRideResponse>> getActiveRide(
            @PathVariable("driverId") Long driverId) {
        return rideService.getActiveRide(driverId)
                .map(ride -> ResponseEntity.ok(ApiResponse.success(ride)))
                .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.error(AppErrorCode.RIDE_NOT_ACTIVE)));
    }

    @DeleteMapping("/{driverId}/history")
    public ResponseEntity<ApiResponse<Void>> deleteAllRides(@PathVariable("driverId") Long driverId) {
        rideService.deleteAllRides(driverId);
        return ResponseEntity.ok(ApiResponse.success(null));
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

    @GetMapping("/campaign/{campaignId}/statistics")
    public ResponseEntity<ApiResponse<CampaignRideStatsResponse>> getCampaignStatistics(
            @PathVariable("campaignId") Long campaignId) {
        return ResponseEntity.ok(ApiResponse.success(rideService.getCampaignStatistics(campaignId)));
    }

    @GetMapping("/campaign/{campaignId}/routes")
    public ResponseEntity<ApiResponse<List<CampaignRouteResponse>>> getCampaignRoutes(
            @PathVariable("campaignId") Long campaignId) {
        return ResponseEntity.ok(ApiResponse.success(rideService.getCampaignRoutes(campaignId)));
    }

    @GetMapping("/campaigns/statistics")
    public ResponseEntity<ApiResponse<List<CampaignRideStatsResponse>>> getCampaignStatisticsBulk(
            @RequestParam("ids") List<Long> campaignIds) {
        return ResponseEntity.ok(ApiResponse.success(rideService.getCampaignStatistics(campaignIds)));
    }
}
