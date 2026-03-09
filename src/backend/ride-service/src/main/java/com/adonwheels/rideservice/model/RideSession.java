package com.adonwheels.rideservice.model;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.cassandra.core.mapping.Column;
import org.springframework.data.cassandra.core.mapping.PrimaryKey;
import org.springframework.data.cassandra.core.mapping.Table;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@Table("ride_sessions")
public class RideSession {

    @PrimaryKey("ride_id")
    private String rideId;

    @Column("driver_id")
    private String driverId;

    @Column("start_time")
    private LocalDateTime startTime;

    @Column("route_history")
    private List<LocationPoint> routeHistory = new ArrayList<>();

    @Column("total_distance_km")
    private double totalDistanceKm;

    public RideSession(String rideId, String driverId, LocalDateTime startTime) {
        this.rideId = rideId;
        this.driverId = driverId;
        this.startTime = startTime;
    }

    public void addPoint(LocationPoint point) {
        if (routeHistory == null) {
            routeHistory = new ArrayList<>();
        }
        routeHistory.add(point);
    }
}
