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

    @Column("route_history")
    private List<LocationPoint> routeHistory = new ArrayList<>();

    @Column("total_distance_km")
    private double totalDistanceKm;

    public RideSession() {
    }

    public RideSession(String rideId, String driverId, LocalDateTime startTime, Long campaignId) {
        this.rideId = rideId;
        this.driverId = driverId;
        this.startTime = startTime;
        this.campaignId = campaignId;
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

    public List<LocationPoint> getRouteHistory() {
        return routeHistory;
    }

    public void setRouteHistory(List<LocationPoint> routeHistory) {
        this.routeHistory = routeHistory;
    }

    public double getTotalDistanceKm() {
        return totalDistanceKm;
    }

    public void setTotalDistanceKm(double totalDistanceKm) {
        this.totalDistanceKm = totalDistanceKm;
    }

    public void addPoint(LocationPoint point) {
        if (routeHistory == null) {
            routeHistory = new ArrayList<>();
        }
        routeHistory.add(point);
    }
}
