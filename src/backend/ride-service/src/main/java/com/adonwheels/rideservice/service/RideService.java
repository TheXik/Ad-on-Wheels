package com.adonwheels.rideservice.service;

import com.adonwheels.rideservice.dto.ActiveRideResponse;
import com.adonwheels.rideservice.dto.DeferredRideRequest;
import com.adonwheels.rideservice.dto.EndRideResponse;
import com.adonwheels.rideservice.dto.RideHistoryResponse;
import com.adonwheels.rideservice.dto.RideStatisticsResponse;
import com.adonwheels.rideservice.dto.StartRideResponse;
import com.adonwheels.rideservice.model.CompletedRide;
import com.adonwheels.rideservice.model.LocationPoint;
import com.adonwheels.rideservice.model.RideSession;
import com.adonwheels.rideservice.repository.RideHistoryRepository;
import com.adonwheels.rideservice.repository.RideRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class RideService {

    // TODO: replace with campaign-based pricing
    private static final double EARNINGS_RATE_PER_KM = 0.10;

    private final RideRepository repository;
    private final RideHistoryRepository historyRepository;

    public RideService(RideRepository repository, RideHistoryRepository historyRepository) {
        this.repository = repository;
        this.historyRepository = historyRepository;
    }

    public Optional<ActiveRideResponse> getActiveRide(Long driverId) {
        return repository.findByDriverId(String.valueOf(driverId))
                .map(session -> new ActiveRideResponse(driverId, session.getStartTime()));
    }

    @Transactional
    public StartRideResponse startRide(String driverId) {
        String rideId = UUID.randomUUID().toString();
        RideSession session = new RideSession(rideId, driverId, LocalDateTime.now());
        repository.save(session);
        return new StartRideResponse(rideId);
    }

    @Transactional
    public void trackPoint(String rideId, double lat, double lon) {
        RideSession session = requireSession(rideId);
        session.addPoint(new LocationPoint(lat, lon, LocalDateTime.now()));
        repository.save(session);
    }

    @Transactional
    public EndRideResponse endRide(String rideId) {
        RideSession session = requireSession(rideId);

        LocalDateTime endTime = LocalDateTime.now();
        double totalDistanceKm = calculateTotalDistance(session.getRouteHistory());
        long durationSeconds = Duration.between(session.getStartTime(), endTime).getSeconds();
        double averageSpeedKmh = durationSeconds > 0
                ? totalDistanceKm / (durationSeconds / 3600.0)
                : 0.0;

        CompletedRide ride = new CompletedRide();
        ride.setDriverId(Long.parseLong(session.getDriverId()));
        ride.setStartTime(session.getStartTime());
        ride.setEndTime(endTime);
        ride.setDuration((int) durationSeconds);
        ride.setDistanceKm(totalDistanceKm);
        ride.setAverageSpeedKmh(averageSpeedKmh);
        ride.setEarnings(totalDistanceKm * EARNINGS_RATE_PER_KM);
        ride.setStatus("COMPLETED");
        historyRepository.save(ride);

        repository.deleteById(rideId);

        return new EndRideResponse(totalDistanceKm, durationSeconds);
    }

    /**
     * UC013 – Deferred ride: reconstructs a completed ride from buffered GPS
     * points that the iOS app collected in the background while the driver
     * was driving without having started a ride via QR scan.
     */
    @Transactional
    public EndRideResponse logDeferredRide(DeferredRideRequest request) {
        List<DeferredRideRequest.LocationPointDto> points = request.getLocationPoints();

        if (points == null || points.size() < 2) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "At least 2 location points are required for a deferred ride");
        }

        // Sort points by timestamp to ensure correct order
        points.sort((a, b) -> a.getCapturedAt().compareTo(b.getCapturedAt()));

        // Derive start and end times from the GPS data
        LocalDateTime startTime = LocalDateTime.parse(points.get(0).getCapturedAt());
        LocalDateTime endTime = LocalDateTime.parse(points.get(points.size() - 1).getCapturedAt());

        // Convert to LocationPoint model for distance calculation
        List<LocationPoint> route = points.stream()
                .map(p -> new LocationPoint(p.getLat(), p.getLon(), LocalDateTime.parse(p.getCapturedAt())))
                .toList();

        double totalDistanceKm = calculateTotalDistance(route);
        long durationSeconds = Duration.between(startTime, endTime).getSeconds();
        double averageSpeedKmh = durationSeconds > 0
                ? totalDistanceKm / (durationSeconds / 3600.0)
                : 0.0;

        CompletedRide ride = new CompletedRide();
        ride.setDriverId(Long.parseLong(request.getDriverId()));
        ride.setStartTime(startTime);
        ride.setEndTime(endTime);
        ride.setDuration((int) durationSeconds);
        ride.setDistanceKm(totalDistanceKm);
        ride.setAverageSpeedKmh(averageSpeedKmh);
        ride.setEarnings(totalDistanceKm * EARNINGS_RATE_PER_KM);
        ride.setStatus("DEFERRED");
        historyRepository.save(ride);

        return new EndRideResponse(totalDistanceKm, durationSeconds);
    }

    public List<RideHistoryResponse> getHistory(Long driverId, int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        List<CompletedRide> rides = historyRepository.findByDriverIdOrderByStartTimeDesc(driverId, pageable);
        return rides.stream().map(this::toHistoryResponse).collect(Collectors.toList());
    }

    public RideStatisticsResponse getStatistics(Long driverId) {
        List<CompletedRide> allRides = historyRepository.findByDriverId(driverId);

        LocalDateTime weekAgo = LocalDateTime.now().minusDays(7);
        LocalDateTime monthAgo = LocalDateTime.now().minusDays(30);

        long totalRides = allRides.size();
        int totalDuration = allRides.stream().mapToInt(CompletedRide::getDuration).sum();
        int avgDuration = totalRides > 0 ? (int) (totalDuration / totalRides) : 0;

        double totalDistance = allRides.stream().mapToDouble(CompletedRide::getDistanceKm).sum();
        double weeklyDistance = allRides.stream()
                .filter(r -> r.getStartTime().isAfter(weekAgo))
                .mapToDouble(CompletedRide::getDistanceKm).sum();
        double monthlyDistance = allRides.stream()
                .filter(r -> r.getStartTime().isAfter(monthAgo))
                .mapToDouble(CompletedRide::getDistanceKm).sum();

        double totalEarnings = allRides.stream().mapToDouble(CompletedRide::getEarnings).sum();
        double weeklyEarnings = allRides.stream()
                .filter(r -> r.getStartTime().isAfter(weekAgo))
                .mapToDouble(CompletedRide::getEarnings).sum();
        double monthlyEarnings = allRides.stream()
                .filter(r -> r.getStartTime().isAfter(monthAgo))
                .mapToDouble(CompletedRide::getEarnings).sum();

        double avgSpeed = allRides.stream()
                .mapToDouble(CompletedRide::getAverageSpeedKmh).average().orElse(0.0);

        return new RideStatisticsResponse(
                totalRides, totalRides, 0L,
                totalDuration, avgDuration, 0L,
                totalDistance, weeklyDistance, monthlyDistance,
                totalEarnings, weeklyEarnings, monthlyEarnings,
                avgSpeed, null
        );
    }

    private RideHistoryResponse toHistoryResponse(CompletedRide ride) {
        return new RideHistoryResponse(
                ride.getId(), ride.getDriverId(), null,
                ride.getStartTime(), ride.getEndTime(),
                null, null,
                ride.getDuration(), null,
                ride.getStatus(), ride.getDistanceKm(),
                ride.getAverageSpeedKmh(), ride.getEarnings()
        );
    }

    private RideSession requireSession(String rideId) {
        return repository.findById(rideId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "No active ride found for id: " + rideId));
    }

    private double calculateTotalDistance(List<LocationPoint> route) {
        if (route == null || route.size() < 2) {
            return 0.0;
        }
        double total = 0.0;
        for (int i = 1; i < route.size(); i++) {
            total += haversineKm(route.get(i - 1), route.get(i));
        }
        return total;
    }

    private double haversineKm(LocationPoint a, LocationPoint b) {
        final double R = 6371.0;
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
