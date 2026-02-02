package com.example.driverservice.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
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
}
