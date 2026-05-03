package com.adonwheels.rideservice.service;

import com.adonwheels.rideservice.dto.ActiveRideResponse;
import com.adonwheels.rideservice.dto.CampaignRideStatsResponse;
import com.adonwheels.rideservice.dto.CampaignRouteResponse;
import com.adonwheels.rideservice.dto.DeferredRideRequest;
import com.adonwheels.rideservice.dto.EndRideResponse;
import com.adonwheels.rideservice.dto.LatLng;
import com.adonwheels.rideservice.dto.RideHistoryResponse;
import com.adonwheels.rideservice.dto.RideStatisticsResponse;
import com.adonwheels.rideservice.dto.RoutePointDto;
import com.adonwheels.rideservice.dto.StartRideResponse;
import com.adonwheels.rideservice.model.CompletedRide;
import com.adonwheels.rideservice.model.LocationPoint;
import com.adonwheels.rideservice.model.RideSession;
import com.adonwheels.rideservice.exception.InvalidDeferredRideException;
import com.adonwheels.rideservice.exception.RideNotFoundException;
import com.adonwheels.rideservice.exception.RideSessionNotFoundException;
import com.adonwheels.rideservice.repository.RideHistoryRepository;
import com.adonwheels.rideservice.repository.RideRepository;
import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class RideService {

    // Fallback when no campaign rate is supplied; per-campaign rates override this.
    private static final double DEFAULT_EARNINGS_RATE_PER_KM = 0.10;

    private final RideRepository repository;
    private final RideHistoryRepository historyRepository;
    private final ObjectMapper objectMapper;

    public RideService(RideRepository repository,
                       RideHistoryRepository historyRepository,
                       ObjectMapper objectMapper) {
        this.repository = repository;
        this.historyRepository = historyRepository;
        this.objectMapper = objectMapper;
    }

    public Optional<ActiveRideResponse> getActiveRide(Long driverId) {
        return repository.findByDriverId(String.valueOf(driverId))
                .map(session -> ActiveRideResponse.active(driverId, session.getStartTime()));
    }

    public StartRideResponse startRide(String driverId, Long campaignId, Double ratePerKm) {
        if (repository.findByDriverId(driverId).isPresent()) {
            throw new BusinessException(AppErrorCode.RIDE_ALREADY_STARTED);
        }
        String rideId = UUID.randomUUID().toString();
        RideSession session = new RideSession(rideId, driverId, LocalDateTime.now(), campaignId, ratePerKm);
        repository.save(session);
        return new StartRideResponse(rideId);
    }

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
        ride.setCampaignId(session.getCampaignId());
        ride.setStartTime(session.getStartTime());
        ride.setEndTime(endTime);
        ride.setDuration((int) durationSeconds);
        ride.setDistanceKm(totalDistanceKm);
        ride.setAverageSpeedKmh(averageSpeedKmh);
        double rate = session.getRatePerKm() != null ? session.getRatePerKm() : DEFAULT_EARNINGS_RATE_PER_KM;
        ride.setEarnings(totalDistanceKm * rate);
        ride.setStatus("COMPLETED");
        ride.setVerified(false);
        extractGeoCoords(ride, session.getRouteHistory());
        ride.setRoutePointsJson(serializeRoute(session.getRouteHistory()));
        CompletedRide saved = historyRepository.save(ride);

        repository.deleteById(rideId);

        return new EndRideResponse(saved.getId(), totalDistanceKm, durationSeconds);
    }

    @Transactional
    public EndRideResponse logDeferredRide(DeferredRideRequest request) {
        List<DeferredRideRequest.LocationPointDto> points = request.locationPoints();

        if (points == null || points.size() < 2) {
            throw new InvalidDeferredRideException(
                    "At least 2 location points are required for a deferred ride");
        }

        points.sort((a, b) -> a.capturedAt().compareTo(b.capturedAt()));

        LocalDateTime startTime = LocalDateTime.parse(points.get(0).capturedAt(), DateTimeFormatter.ISO_DATE_TIME);
        LocalDateTime endTime = LocalDateTime.parse(points.get(points.size() - 1).capturedAt(), DateTimeFormatter.ISO_DATE_TIME);

        List<LocationPoint> route = points.stream()
                .map(p -> new LocationPoint(p.lat(), p.lon(), LocalDateTime.parse(p.capturedAt(), DateTimeFormatter.ISO_DATE_TIME)))
                .toList();

        double totalDistanceKm = calculateTotalDistance(route);
        long durationSeconds = Duration.between(startTime, endTime).getSeconds();
        double averageSpeedKmh = durationSeconds > 0
                ? totalDistanceKm / (durationSeconds / 3600.0)
                : 0.0;

        CompletedRide ride = new CompletedRide();
        ride.setDriverId(Long.parseLong(request.driverId()));
        ride.setCampaignId(request.campaignId());
        ride.setStartTime(startTime);
        ride.setEndTime(endTime);
        ride.setDuration((int) durationSeconds);
        ride.setDistanceKm(totalDistanceKm);
        ride.setAverageSpeedKmh(averageSpeedKmh);
        double rate = request.ratePerKm() != null ? request.ratePerKm() : DEFAULT_EARNINGS_RATE_PER_KM;
        ride.setEarnings(totalDistanceKm * rate);
        ride.setStatus("DEFERRED");
        ride.setVerified(false);
        extractGeoCoords(ride, route);
        ride.setRoutePointsJson(serializeRoute(route));
        CompletedRide saved = historyRepository.save(ride);

        return new EndRideResponse(saved.getId(), totalDistanceKm, durationSeconds);
    }

    @Transactional
    public void verifyRide(Long rideId) {
        CompletedRide ride = historyRepository.findById(rideId)
                .orElseThrow(() -> new RideNotFoundException(rideId));
        ride.setVerified(true);
        historyRepository.save(ride);
    }

    public List<RideHistoryResponse> getHistory(Long driverId, int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        List<CompletedRide> rides = historyRepository.findByDriverIdOrderByStartTimeDesc(driverId, pageable);
        return rides.stream().map(this::toHistoryResponse).collect(Collectors.toList());
    }

    @Transactional
    public void deleteAllRides(Long driverId) {
        historyRepository.deleteByDriverId(driverId);
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

        // Only verified rides contribute to earnings; counts and distance
        // include unverified rides too.
        java.util.function.Predicate<CompletedRide> isVerified =
                r -> Boolean.TRUE.equals(r.getVerified());
        double totalEarnings = allRides.stream().filter(isVerified)
                .mapToDouble(CompletedRide::getEarnings).sum();
        double weeklyEarnings = allRides.stream().filter(isVerified)
                .filter(r -> r.getStartTime().isAfter(weekAgo))
                .mapToDouble(CompletedRide::getEarnings).sum();
        double monthlyEarnings = allRides.stream().filter(isVerified)
                .filter(r -> r.getStartTime().isAfter(monthAgo))
                .mapToDouble(CompletedRide::getEarnings).sum();

        double avgSpeed = allRides.stream()
                .mapToDouble(CompletedRide::getAverageSpeedKmh).average().orElse(0.0);

        return new RideStatisticsResponse(
                totalRides, totalRides,
                totalDuration,
                totalDistance, weeklyDistance, monthlyDistance,
                totalEarnings, weeklyEarnings, monthlyEarnings,
                avgSpeed
        );
    }

    public List<RoutePointDto> getRoute(Long rideId, Long callerDriverId) {
        CompletedRide ride = historyRepository.findById(rideId)
                .orElseThrow(() -> new RideNotFoundException(rideId));

        if (callerDriverId == null || !callerDriverId.equals(ride.getDriverId())) {
            throw new BusinessException(AppErrorCode.ACCESS_DENIED);
        }

        return deserializeRoute(ride.getRoutePointsJson()).stream()
                .map(p -> new RoutePointDto(p.lat(), p.lon()))
                .toList();
    }

    public List<CampaignRouteResponse> getCampaignRoutes(Long campaignId) {
        return historyRepository.findByCampaignId(campaignId).stream()
                .map(ride -> new CampaignRouteResponse(
                        ride.getId(),
                        ride.getDriverId(),
                        ride.getDistanceKm(),
                        ride.getStatus(),
                        ride.getVerified(),
                        deserializeRoute(ride.getRoutePointsJson())))
                .toList();
    }

    public CampaignRideStatsResponse getCampaignStatistics(Long campaignId) {
        List<CompletedRide> rides = historyRepository.findByCampaignId(campaignId);
        return buildCampaignStats(campaignId, rides);
    }

    public List<CampaignRideStatsResponse> getCampaignStatistics(List<Long> campaignIds) {
        List<CompletedRide> allRides = historyRepository.findByCampaignIdIn(campaignIds);
        return campaignIds.stream().map(cid -> {
            List<CompletedRide> campaignRides = allRides.stream()
                    .filter(r -> cid.equals(r.getCampaignId()))
                    .toList();
            return buildCampaignStats(cid, campaignRides);
        }).toList();
    }

    private CampaignRideStatsResponse buildCampaignStats(Long campaignId, List<CompletedRide> rides) {
        long totalRides = rides.size();
        double totalDistance = rides.stream().mapToDouble(CompletedRide::getDistanceKm).sum();
        long totalDuration = rides.stream().mapToLong(CompletedRide::getDuration).sum();
        // Earnings count verified rides only.
        double totalEarnings = rides.stream()
                .filter(r -> Boolean.TRUE.equals(r.getVerified()))
                .mapToDouble(CompletedRide::getEarnings).sum();
        long driverCount = rides.stream().map(CompletedRide::getDriverId).distinct().count();

        return new CampaignRideStatsResponse(
                campaignId, totalRides, totalDistance, totalDuration, totalEarnings, driverCount);
    }

    private RideHistoryResponse toHistoryResponse(CompletedRide ride) {
        return new RideHistoryResponse(
                ride.getId(), ride.getDriverId(), ride.getCampaignId(),
                ride.getStartTime(), ride.getEndTime(),
                ride.getDuration(),
                ride.getStatus(), ride.getDistanceKm(),
                ride.getAverageSpeedKmh(), ride.getEarnings(),
                ride.getStartLat(), ride.getStartLon(),
                ride.getEndLat(), ride.getEndLon(),
                deserializeRoute(ride.getRoutePointsJson()),
                Boolean.TRUE.equals(ride.getVerified())
        );
    }

    private String serializeRoute(List<LocationPoint> route) {
        if (route == null || route.isEmpty()) {
            return null;
        }
        List<LatLng> points = route.stream()
                .map(p -> new LatLng(p.getLat(), p.getLon()))
                .toList();
        try {
            return objectMapper.writeValueAsString(points);
        } catch (JsonProcessingException e) {
            return null;
        }
    }

    private List<LatLng> deserializeRoute(String json) {
        if (json == null || json.isBlank()) {
            return Collections.emptyList();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<LatLng>>() {});
        } catch (JsonProcessingException e) {
            return Collections.emptyList();
        }
    }

    private void extractGeoCoords(CompletedRide ride, List<LocationPoint> route) {
        if (route != null && !route.isEmpty()) {
            LocationPoint first = route.get(0);
            LocationPoint last = route.get(route.size() - 1);
            ride.setStartLat(first.getLat());
            ride.setStartLon(first.getLon());
            ride.setEndLat(last.getLat());
            ride.setEndLon(last.getLon());
        }
    }

    private RideSession requireSession(String rideId) {
        return repository.findById(rideId)
                .orElseThrow(() -> new RideSessionNotFoundException(rideId));
    }

    static double calculateTotalDistance(List<LocationPoint> route) {
        if (route == null || route.size() < 2) {
            return 0.0;
        }
        double total = 0.0;
        for (int i = 1; i < route.size(); i++) {
            LocationPoint a = route.get(i - 1);
            LocationPoint b = route.get(i);
            double segmentKm = haversineKm(a, b);

            // Drop segments faster than 200 km/h (GPS glitch).
            long dtSeconds = java.time.Duration.between(a.getCapturedAt(), b.getCapturedAt()).getSeconds();
            if (dtSeconds > 0) {
                double impliedSpeedKmh = segmentKm / (dtSeconds / 3600.0);
                if (impliedSpeedKmh > 200) {
                    continue;
                }
            }

            // Drop segments under 10 m (jitter while parked).
            if (segmentKm < 0.01) {
                continue;
            }

            total += segmentKm;
        }
        return total;
    }

    static double haversineKm(LocationPoint a, LocationPoint b) {
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
