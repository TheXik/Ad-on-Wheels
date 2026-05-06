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
import com.adonwheels.rideservice.exception.RideNotFoundException;
import com.adonwheels.rideservice.exception.RideSessionNotFoundException;
import com.adonwheels.rideservice.model.CompletedRide;
import com.adonwheels.rideservice.model.RideSession;
import com.adonwheels.rideservice.repository.RideHistoryRepository;
import com.adonwheels.rideservice.repository.RideRepository;
import com.adonwheels.rideservice.service.RideService;
import com.adonwheels.dto.ApiResponse;
import com.adonwheels.dto.AppErrorCode;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/rides")
public class RideController {

    private final RideService rideService;
    private final RideRepository rideRepository;
    private final RideHistoryRepository historyRepository;

    public RideController(RideService rideService,
                          RideRepository rideRepository,
                          RideHistoryRepository historyRepository) {
        this.rideService = rideService;
        this.rideRepository = rideRepository;
        this.historyRepository = historyRepository;
    }

    @PostMapping("/start")
    public ResponseEntity<ApiResponse<StartRideResponse>> startRide(
            @Valid @RequestBody StartRideRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        // driverId travels in the body; pin it to the caller.
        requireDriverIdMatchesCaller(callerId, callerRole, request.driverId());
        StartRideResponse response = rideService.startRide(request.driverId(), request.campaignId(), request.ratePerKm());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
    }

    @PostMapping("/track")
    public ResponseEntity<Void> trackPoint(
            @Valid @RequestBody TrackRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        // /track does not carry driverId in the body; resolve it via the
        // session and confirm the caller owns this ride.
        requireSessionOwnership(callerId, callerRole, request.rideId());
        rideService.trackPoint(request.rideId(), request.lat(), request.lon());
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/end")
    public ResponseEntity<ApiResponse<EndRideResponse>> endRide(
            @Valid @RequestBody EndRideRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireSessionOwnership(callerId, callerRole, request.rideId());
        EndRideResponse response = rideService.endRide(request.rideId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/{completedRideId}/verify")
    public ResponseEntity<ApiResponse<Void>> verifyRide(
            @PathVariable("completedRideId") Long completedRideId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        // verify is the driver attesting to their own ride; look up the
        // owning driverId on the completed ride and check it matches.
        requireCompletedRideOwnership(callerId, callerRole, completedRideId);
        rideService.verifyRide(completedRideId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @GetMapping("/{rideId}/route")
    public ResponseEntity<ApiResponse<List<RoutePointDto>>> getRideRoute(
            @PathVariable("rideId") Long rideId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerDriverId) {
        // RideService.getRoute already enforces caller==driver via BusinessException.
        List<RoutePointDto> route = rideService.getRoute(rideId, callerDriverId);
        return ResponseEntity.ok(ApiResponse.success(route));
    }

    @PostMapping("/deferred")
    public ResponseEntity<ApiResponse<EndRideResponse>> logDeferredRide(
            @Valid @RequestBody DeferredRideRequest request,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireDriverIdMatchesCaller(callerId, callerRole, request.driverId());
        EndRideResponse response = rideService.logDeferredRide(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
    }

    @GetMapping("/{driverId}/active")
    public ResponseEntity<ApiResponse<ActiveRideResponse>> getActiveRide(
            @PathVariable("driverId") Long driverId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireDriverOwnership(callerId, callerRole, driverId);
        return rideService.getActiveRide(driverId)
                .map(ride -> ResponseEntity.ok(ApiResponse.success(ride)))
                .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.error(AppErrorCode.RIDE_NOT_ACTIVE)));
    }

    @DeleteMapping("/{driverId}/history")
    public ResponseEntity<ApiResponse<Void>> deleteAllRides(
            @PathVariable("driverId") Long driverId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireDriverOwnership(callerId, callerRole, driverId);
        rideService.deleteAllRides(driverId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @GetMapping("/{driverId}/history")
    public ResponseEntity<ApiResponse<List<RideHistoryResponse>>> getHistory(
            @PathVariable("driverId") Long driverId,
            @RequestParam(value = "limit", defaultValue = "50") int limit,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireDriverOwnership(callerId, callerRole, driverId);
        return ResponseEntity.ok(ApiResponse.success(rideService.getHistory(driverId, limit)));
    }

    @GetMapping("/{driverId}/statistics")
    public ResponseEntity<ApiResponse<RideStatisticsResponse>> getStatistics(
            @PathVariable("driverId") Long driverId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireDriverOwnership(callerId, callerRole, driverId);
        return ResponseEntity.ok(ApiResponse.success(rideService.getStatistics(driverId)));
    }

    // /campaign/* and /campaigns/statistics are cross-role reads (companies
    // read stats for their own campaigns). Server-side ownership of the
    // campaign id lives in campaign-service; verifying it from ride-service
    // would require a cross-service WebClient, breaking the
    // ride-service-self-contained property. We therefore trust the gateway
    // role-class gate (A3 keeps /api/rides/ open to DRIVER+COMPANY+ADMIN) and
    // rely on the caller knowing the campaign id; campaign ids are not
    // sensitive on their own and the leaked stats are aggregate.
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

    // Per-campaign verified-earnings sums. Consumed by campaign-service's
    // CampaignLifecycleScheduler to enforce budget caps (A13). Aggregate
    // financial data for the campaign owner; cross-role read.
    @GetMapping("/campaigns/earnings-totals")
    public ResponseEntity<ApiResponse<java.util.Map<Long, java.math.BigDecimal>>> getEarningsTotals(
            @RequestParam("ids") List<Long> campaignIds) {
        return ResponseEntity.ok(ApiResponse.success(rideService.getEarningsTotals(campaignIds)));
    }

    private void requireDriverOwnership(Long callerId, String callerRole, Long pathDriverId) {
        if ("ADMIN".equals(callerRole)) {
            return;
        }
        if (callerId == null || !callerId.equals(pathDriverId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Caller is not authorized to act on this driver's rides");
        }
    }

    private void requireDriverIdMatchesCaller(Long callerId, String callerRole, String bodyDriverId) {
        if ("ADMIN".equals(callerRole)) {
            return;
        }
        if (callerId == null || bodyDriverId == null) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Missing caller identity");
        }
        try {
            Long parsed = Long.valueOf(bodyDriverId);
            if (!callerId.equals(parsed)) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                        "Body driverId does not match authenticated caller");
            }
        } catch (NumberFormatException nfe) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Invalid driverId in body");
        }
    }

    private void requireSessionOwnership(Long callerId, String callerRole, String rideId) {
        if ("ADMIN".equals(callerRole)) {
            return;
        }
        RideSession session = rideRepository.findById(rideId)
                .orElseThrow(() -> new RideSessionNotFoundException(rideId));
        if (callerId == null || !String.valueOf(callerId).equals(session.getDriverId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Caller does not own this ride session");
        }
    }

    private void requireCompletedRideOwnership(Long callerId, String callerRole, Long completedRideId) {
        if ("ADMIN".equals(callerRole)) {
            return;
        }
        CompletedRide ride = historyRepository.findById(completedRideId)
                .orElseThrow(() -> new RideNotFoundException(completedRideId));
        if (callerId == null || !callerId.equals(ride.getDriverId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Caller does not own this ride");
        }
    }
}
