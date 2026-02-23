package com.example.driverservice.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.driverservice.model.Ride;
import com.example.driverservice.model.RideStatus;

@Repository
public interface RideRepository extends JpaRepository<Ride, Long> {
    
    // Find all rides for a driver
    List<Ride> findByDriverId(Long driverId);
    
    // Find active ride for a driver
    Optional<Ride> findByDriverIdAndStatus(Long driverId, RideStatus status);
    
    // Find ride history (ordered by start time, newest first)
    List<Ride> findByDriverIdOrderByStartTimeDesc(Long driverId);
    
    // Find rides after a certain date (for weekly/monthly stats)
    List<Ride> findByDriverIdAndStartTimeAfterOrderByStartTimeDesc(Long driverId, LocalDateTime startTime);
    
    // Sum of distance for driver
    @Query("SELECT COALESCE(SUM(r.distanceKm), 0) FROM Ride r WHERE r.driverId = :driverId AND r.status IN ('COMPLETED', 'VERIFIED')")
    Double sumDistanceByDriverId(@Param("driverId") Long driverId);
    
    // Sum of earnings for driver
    @Query("SELECT COALESCE(SUM(r.earnings), 0) FROM Ride r WHERE r.driverId = :driverId AND r.status IN ('COMPLETED', 'VERIFIED')")
    Double sumEarningsByDriverId(@Param("driverId") Long driverId);
    
    // Sum of distance for driver after date
    @Query("SELECT COALESCE(SUM(r.distanceKm), 0) FROM Ride r WHERE r.driverId = :driverId AND r.startTime >= :startTime AND r.status IN ('COMPLETED', 'VERIFIED')")
    Double sumDistanceByDriverIdAndStartTimeAfter(@Param("driverId") Long driverId, @Param("startTime") LocalDateTime startTime);
    
    // Sum of earnings for driver after date
    @Query("SELECT COALESCE(SUM(r.earnings), 0) FROM Ride r WHERE r.driverId = :driverId AND r.startTime >= :startTime AND r.status IN ('COMPLETED', 'VERIFIED')")
    Double sumEarningsByDriverIdAndStartTimeAfter(@Param("driverId") Long driverId, @Param("startTime") LocalDateTime startTime);
    
    // Average speed for driver
    @Query("SELECT COALESCE(AVG(r.averageSpeedKmh), 0) FROM Ride r WHERE r.driverId = :driverId AND r.averageSpeedKmh IS NOT NULL")
    Double avgSpeedByDriverId(@Param("driverId") Long driverId);
}
