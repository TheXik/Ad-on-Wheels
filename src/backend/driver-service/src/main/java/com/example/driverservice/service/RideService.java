package com.example.driverservice.service;

import com.example.driverservice.dto.RideStatistics;
import com.example.driverservice.model.Ride;
import com.example.driverservice.model.RideStatus;
import com.example.driverservice.repository.RideRepository;
import dto.AppErrorCode;
import dto.exception.BusinessException;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class RideService {
    
    private final RideRepository rideRepository;

    public RideService(RideRepository rideRepository) {
        this.rideRepository = rideRepository;
    }

    // Start a new ride
    public Ride startRide(Long driverId, Long campaignId) {
        return startRide(driverId, campaignId, null);
    }

    // Start a new ride with location
    public Ride startRide(Long driverId, Long campaignId, String startLocation) {
        if (driverId == null) {
            throw new BusinessException(AppErrorCode.VALIDATION_ERROR, "driverId is required");
        }

        // Check if driver already has an active ride
        Optional<Ride> activeRide = rideRepository.findByDriverIdAndStatus(driverId, RideStatus.ACTIVE);
        if (activeRide.isPresent()) {
            throw new BusinessException(AppErrorCode.RIDE_ALREADY_STARTED);
        }

        // Create new ride
        Ride ride = new Ride();
        ride.setDriverId(driverId);
        ride.setCampaignId(campaignId);
        ride.setStartTime(LocalDateTime.now());
        ride.setStartLocation(startLocation);
        ride.setStatus(RideStatus.ACTIVE);

        return rideRepository.save(ride);
    }

    // Stop an active ride
    public Ride stopRide(Long driverId) {
        return stopRide(driverId, null, null, null);
    }

    // Stop an active ride with location
    public Ride stopRide(Long driverId, String endLocation) {
        return stopRide(driverId, endLocation, null, null);
    }

    // Stop an active ride with all details
    public Ride stopRide(Long driverId, String endLocation, Double distanceKm, Double averageSpeedKmh) {
        if (driverId == null) {
            throw new BusinessException(AppErrorCode.VALIDATION_ERROR, "driverId is required");
        }

        // Find active ride
        Optional<Ride> activeRideOpt = rideRepository.findByDriverIdAndStatus(driverId, RideStatus.ACTIVE);
        if (activeRideOpt.isEmpty()) {
            throw new BusinessException(AppErrorCode.RIDE_NOT_ACTIVE);
        }

        Ride ride = activeRideOpt.get();
        ride.setEndTime(LocalDateTime.now());
        ride.setEndLocation(endLocation);
        
        // Calculate duration in seconds
        Duration duration = Duration.between(ride.getStartTime(), ride.getEndTime());
        ride.setDuration((int) duration.getSeconds());
        
        // Set distance and speed if provided
        if (distanceKm != null) {
            ride.setDistanceKm(distanceKm);
        }
        if (averageSpeedKmh != null) {
            ride.setAverageSpeedKmh(averageSpeedKmh);
        }
        
        // Calculate earnings based on distance (example: 0.15€ per km)
        if (distanceKm != null && distanceKm > 0) {
            double earningsRate = 0.15; // € per km
            ride.setEarnings(distanceKm * earningsRate);
        }
        
        ride.setStatus(RideStatus.COMPLETED);

        return rideRepository.save(ride);
    }

    // Get ride history for a driver
    public List<Ride> getRideHistory(Long driverId) {
        return rideRepository.findByDriverIdOrderByStartTimeDesc(driverId);
    }
    
    // Get ride history for a driver with limit
    public List<Ride> getRideHistory(Long driverId, int limit) {
        List<Ride> rides = rideRepository.findByDriverIdOrderByStartTimeDesc(driverId);
        if (rides.size() > limit) {
            return rides.subList(0, limit);
        }
        return rides;
    }

    // Get active ride for a driver
    public Ride getActiveRide(Long driverId) {
        return rideRepository.findByDriverIdAndStatus(driverId, RideStatus.ACTIVE)
                .orElseThrow(() -> new BusinessException(AppErrorCode.RIDE_NOT_ACTIVE));
    }
    
    // Check if driver has active ride
    public Optional<Ride> findActiveRide(Long driverId) {
        return rideRepository.findByDriverIdAndStatus(driverId, RideStatus.ACTIVE);
    }

    // Verify a ride with QR code
    public Ride verifyRide(Long rideId, String qrCodeData) {
        if (qrCodeData == null || qrCodeData.isEmpty()) {
            throw new BusinessException(AppErrorCode.VALIDATION_ERROR, "qrCodeData is required");
        }

        Ride ride = rideRepository.findById(rideId)
                .orElseThrow(() -> new BusinessException(AppErrorCode.RIDE_NOT_ACTIVE, "Ride not found"));

        if (ride.getStatus() != RideStatus.COMPLETED) {
            throw new BusinessException(AppErrorCode.VALIDATION_ERROR, "Only completed rides can be verified");
        }

        ride.setQrCodeData(qrCodeData);
        ride.setStatus(RideStatus.VERIFIED);

        return rideRepository.save(ride);
    }

    // Get ride statistics for a driver
    public RideStatistics getRideStatistics(Long driverId) {
        if (driverId == null) {
            throw new BusinessException(AppErrorCode.VALIDATION_ERROR, "driverId is required");
        }

        List<Ride> allRides = rideRepository.findByDriverIdOrderByStartTimeDesc(driverId);

        long totalRides = allRides.size();
        long completedRides = allRides.stream()
                .filter(r -> r.getStatus() == RideStatus.COMPLETED || r.getStatus() == RideStatus.VERIFIED)
                .count();
        long verifiedRides = allRides.stream()
                .filter(r -> r.getStatus() == RideStatus.VERIFIED)
                .count();
        long activeRides = allRides.stream()
                .filter(r -> r.getStatus() == RideStatus.ACTIVE)
                .count();

        int totalDuration = allRides.stream()
                .filter(r -> r.getDuration() != null)
                .mapToInt(Ride::getDuration)
                .sum();

        int averageDuration = completedRides > 0 ?
                (int) (totalDuration / (double) completedRides) : 0;

        // Calculate distance and earnings using optimized queries
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime weekAgo = now.minusDays(7);
        LocalDateTime monthAgo = now.minusDays(30);

        Double totalDistanceKm = rideRepository.sumDistanceByDriverId(driverId);
        Double weeklyDistanceKm = rideRepository.sumDistanceByDriverIdAndStartTimeAfter(driverId, weekAgo);
        Double monthlyDistanceKm = rideRepository.sumDistanceByDriverIdAndStartTimeAfter(driverId, monthAgo);
        
        Double totalEarnings = rideRepository.sumEarningsByDriverId(driverId);
        Double weeklyEarnings = rideRepository.sumEarningsByDriverIdAndStartTimeAfter(driverId, weekAgo);
        Double monthlyEarnings = rideRepository.sumEarningsByDriverIdAndStartTimeAfter(driverId, monthAgo);
        
        Double averageSpeedKmh = rideRepository.avgSpeedByDriverId(driverId);

        RideStatistics stats = new RideStatistics(
                totalRides,
                completedRides,
                verifiedRides,
                totalDuration,
                averageDuration,
                activeRides
        );
        
        // Set new statistics fields
        stats.setTotalDistanceKm(totalDistanceKm != null ? totalDistanceKm : 0.0);
        stats.setWeeklyDistanceKm(weeklyDistanceKm != null ? weeklyDistanceKm : 0.0);
        stats.setMonthlyDistanceKm(monthlyDistanceKm != null ? monthlyDistanceKm : 0.0);
        stats.setTotalEarnings(totalEarnings != null ? totalEarnings : 0.0);
        stats.setWeeklyEarnings(weeklyEarnings != null ? weeklyEarnings : 0.0);
        stats.setMonthlyEarnings(monthlyEarnings != null ? monthlyEarnings : 0.0);
        stats.setAverageSpeedKmh(averageSpeedKmh != null ? averageSpeedKmh : 0.0);
        
        return stats;
    }
}
