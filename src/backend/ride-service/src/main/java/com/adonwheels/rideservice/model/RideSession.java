package com.adonwheels.rideservice.model;

import org.springframework.data.cassandra.core.mapping.Column;
import org.springframework.data.cassandra.core.mapping.PrimaryKey;
import org.springframework.data.cassandra.core.mapping.Table;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Table("ride_sessions")
public class RideSession {

    @PrimaryKey("ride_id")
    private String rideId;

    @Column("driver_id")
    private String driverId;

    @Column("start_time")
    private LocalDateTime startTime;

    @Column("campaign_id")
    private Long campaignId;

    @Column("rate_per_km")
    private Double ratePerKm;

    @Column("route_history")
    private List<LocationPoint> routeHistory = new ArrayList<>();

    public RideSession() {
    }

    public RideSession(String rideId, String driverId, LocalDateTime startTime, Long campaignId, Double ratePerKm) {
        this.rideId = rideId;
        this.driverId = driverId;
        this.startTime = startTime;
        this.campaignId = campaignId;
        this.ratePerKm = ratePerKm;
    }

    public String getRideId() {
        return rideId;
    }

    public void setRideId(String rideId) {
        this.rideId = rideId;
    }

    public String getDriverId() {
        return driverId;
    }

    public void setDriverId(String driverId) {
        this.driverId = driverId;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public Long getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(Long campaignId) {
        this.campaignId = campaignId;
    }

    public Double getRatePerKm() {
        return ratePerKm;
    }

    public void setRatePerKm(Double ratePerKm) {
        this.ratePerKm = ratePerKm;
    }

    public List<LocationPoint> getRouteHistory() {
        return routeHistory;
    }

    public void setRouteHistory(List<LocationPoint> routeHistory) {
        this.routeHistory = routeHistory;
    }

    public void addPoint(LocationPoint point) {
        if (routeHistory == null) {
            routeHistory = new ArrayList<>();
        }
        routeHistory.add(point);
    }
}
