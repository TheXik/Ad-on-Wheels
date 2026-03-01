package com.adonwheels.rideservice.service;

import com.adonwheels.rideservice.dto.EndRideResponse;
import com.adonwheels.rideservice.dto.StartRideResponse;
import com.adonwheels.rideservice.model.LocationPoint;
import com.adonwheels.rideservice.model.RideSession;
import com.adonwheels.rideservice.repository.RideRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class RideService {

    private final RideRepository repository;

    public RideService(RideRepository repository) {
        this.repository = repository;
    }

    /**
     * Creates a new ride session for the given driver.
     *
     * @return response containing the generated rideId
     */
    public StartRideResponse startRide(String driverId) {
        String rideId = UUID.randomUUID().toString();
        RideSession session = new RideSession(rideId, driverId, LocalDateTime.now());
        repository.save(session);
        return new StartRideResponse(rideId);
    }

    /**
     * Appends a GPS point to the session's route history.
     * Designed for fast, fire-and-forget tracking.
     */
    public void trackPoint(String rideId, double lat, double lon) {
        RideSession session = requireSession(rideId);
        session.addPoint(new LocationPoint(lat, lon, LocalDateTime.now()));
    }

    /**
     * Finalises the ride: calculates total distance via Haversine over all
     * recorded {@link LocationPoint}s, then removes the session from the store.
     *
     * @return summary with total distance (km) and duration (seconds)
     */
    public EndRideResponse endRide(String rideId) {
        RideSession session = requireSession(rideId);

        double totalDistanceKm = calculateTotalDistance(session.getRouteHistory());
        long durationSeconds = Duration.between(session.getStartTime(), LocalDateTime.now()).getSeconds();

        repository.deleteById(rideId);

        return new EndRideResponse(totalDistanceKm, durationSeconds);
    }

    // -------------------------------------------------------------------------
    // Internal helpers
    // -------------------------------------------------------------------------

    private RideSession requireSession(String rideId) {
        return repository.findById(rideId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "No active ride found for id: " + rideId));
    }

    /**
     * Sums Haversine distances between consecutive points in the route.
     * Returns 0.0 if fewer than 2 points have been recorded.
     */
    private double calculateTotalDistance(List<LocationPoint> route) {
        double total = 0.0;
        for (int i = 1; i < route.size(); i++) {
            total += haversineKm(route.get(i - 1), route.get(i));
        }
        return total;
    }

    /**
     * Haversine formula — great-circle distance between two GPS coordinates.
     *
     * @return distance in kilometres
     */
    private double haversineKm(LocationPoint a, LocationPoint b) {
        final double R = 6371.0; // Earth's mean radius in km
        double dLat = Math.toRadians(b.getLat() - a.getLat());
        double dLon = Math.toRadians(b.getLon() - a.getLon());
        double sinDLat = Math.sin(dLat / 2);
        double sinDLon = Math.sin(dLon / 2);
        double h = sinDLat * sinDLat
                + Math.cos(Math.toRadians(a.getLat()))
                * Math.cos(Math.toRadians(b.getLat()))
                * sinDLon * sinDLon;
        return R * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
    }
}
