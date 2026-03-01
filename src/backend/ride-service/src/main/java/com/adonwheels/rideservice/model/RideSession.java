package com.adonwheels.rideservice.model;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Active ride session stored in Redis as a JSON blob.
 *
 * <p>All fields are non-final so Jackson can deserialize from Redis.
 * Concurrency is handled at the Redis operation level (GET → mutate → SETEX),
 * not at the object level — hence plain {@link ArrayList} instead of
 * {@code CopyOnWriteArrayList}.</p>
 */
@Getter
@Setter
@NoArgsConstructor
public class RideSession {

    private String rideId;
    private String driverId;
    private LocalDateTime startTime;
    private List<LocationPoint> routeHistory = new ArrayList<>();
    private double totalDistanceKm;

    public RideSession(String rideId, String driverId, LocalDateTime startTime) {
        this.rideId = rideId;
        this.driverId = driverId;
        this.startTime = startTime;
    }

    public void addPoint(LocationPoint point) {
        routeHistory.add(point);
    }
}
