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
        ride.setStatus(RideStatus.ACTIVE);

        return rideRepository.save(ride);
    }

    // Stop an active ride
    public Ride stopRide(Long driverId) {
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
        
        // Calculate duration in seconds
        Duration duration = Duration.between(ride.getStartTime(), ride.getEndTime());
        ride.setDuration((int) duration.getSeconds());
        
        ride.setStatus(RideStatus.COMPLETED);

        return rideRepository.save(ride);
    }

    // Get ride history for a driver
    public List<Ride> getRideHistory(Long driverId) {
        return rideRepository.findByDriverIdOrderByStartTimeDesc(driverId);
    }

    // Get active ride for a driver
    public Ride getActiveRide(Long driverId) {
        return rideRepository.findByDriverIdAndStatus(driverId, RideStatus.ACTIVE)
                .orElseThrow(() -> new BusinessException(AppErrorCode.RIDE_NOT_ACTIVE));
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

        return new RideStatistics(
                totalRides,
                completedRides,
                verifiedRides,
                totalDuration,
                averageDuration,
                activeRides
        );
    }
}
