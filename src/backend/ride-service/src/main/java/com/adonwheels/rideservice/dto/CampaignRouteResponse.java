package com.adonwheels.rideservice.dto;

import java.util.List;

public class CampaignRouteResponse {

    private Long rideId;
    private Long driverId;
    private Double distanceKm;
    private String status;
    private Boolean verified;
    private List<LatLng> trackPoints;

    public CampaignRouteResponse() {
    }

    public CampaignRouteResponse(Long rideId, Long driverId, Double distanceKm,
                                 String status, Boolean verified, List<LatLng> trackPoints) {
        this.rideId = rideId;
        this.driverId = driverId;
        this.distanceKm = distanceKm;
        this.status = status;
        this.verified = verified;
        this.trackPoints = trackPoints;
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
