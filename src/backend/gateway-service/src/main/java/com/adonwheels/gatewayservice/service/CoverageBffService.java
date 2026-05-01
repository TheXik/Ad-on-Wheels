package com.adonwheels.gatewayservice.service;

import com.adonwheels.dto.ApiResponse;
import com.adonwheels.gatewayservice.dto.CampaignCoverage;
import com.adonwheels.gatewayservice.dto.LatLng;
import com.adonwheels.gatewayservice.dto.RideRoute;
import com.adonwheels.gatewayservice.dto.RoutePoint;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Collections;
import java.util.List;

/**
 * Aggregator behind {@code GET /api/campaigns/{campaignId}/coverage}.
 * Reuses ride-service's {@code /rides/campaign/{id}/routes} endpoint, which
 * already returns one entry per completed ride with {@code verified} and
 * embedded track points, then reshapes it into the
 * {@link CampaignCoverage} DTO consumed by the iOS and web clients.
 *
 * Reads only - fully idempotent, fully non-blocking.
 */
@Service
public class CoverageBffService {

    private final WebClient rideClient;

    public CoverageBffService(@Qualifier("rideClient") WebClient rideClient) {
        this.rideClient = rideClient;
    }

    public Mono<CampaignCoverage> getCampaignCoverage(Long campaignId) {
        return rideClient.get()
                .uri("/rides/campaign/{campaignId}/routes", campaignId)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ApiResponse<List<CampaignRouteEntry>>>() {})
                .map(ApiResponse::getData)
                .map(entries -> {
                    if (entries == null || entries.isEmpty()) {
                        return new CampaignCoverage(campaignId, Collections.emptyList());
                    }
                    List<RideRoute> rides = entries.stream()
                            .map(e -> new RideRoute(
                                    e.getRideId(),
                                    e.getDriverId(),
                                    Boolean.TRUE.equals(e.getVerified()),
                                    toRoutePoints(e.getTrackPoints())
                            ))
                            .toList();
                    return new CampaignCoverage(campaignId, rides);
                })
                .onErrorReturn(new CampaignCoverage(campaignId, Collections.emptyList()));
    }

    private static List<RoutePoint> toRoutePoints(List<LatLng> points) {
        if (points == null || points.isEmpty()) {
            return Collections.emptyList();
        }
        return points.stream()
                .map(p -> new RoutePoint(p.lat(), p.lon(), null))
                .toList();
    }

    /**
     * Internal projection of the ride-service response. Mirrors the fields
     * we care about from {@code com.adonwheels.rideservice.dto.CampaignRouteResponse}.
     */
    public static class CampaignRouteEntry {
        private Long rideId;
        private Long driverId;
        private Double distanceKm;
        private String status;
        private Boolean verified;
        private List<LatLng> trackPoints;

        public CampaignRouteEntry() {
        }

        public Long getRideId() { return rideId; }
        public void setRideId(Long rideId) { this.rideId = rideId; }

        public Long getDriverId() { return driverId; }
        public void setDriverId(Long driverId) { this.driverId = driverId; }

        public Double getDistanceKm() { return distanceKm; }
        public void setDistanceKm(Double distanceKm) { this.distanceKm = distanceKm; }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }

        public Boolean getVerified() { return verified; }
        public void setVerified(Boolean verified) { this.verified = verified; }

        public List<LatLng> getTrackPoints() { return trackPoints; }
        public void setTrackPoints(List<LatLng> trackPoints) { this.trackPoints = trackPoints; }
    }
}
