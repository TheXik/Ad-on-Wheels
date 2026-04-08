package com.adonwheels.rideservice.repository;

import com.adonwheels.rideservice.model.CompletedRide;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RideHistoryRepository extends JpaRepository<CompletedRide, Long> {

    List<CompletedRide> findByDriverIdOrderByStartTimeDesc(Long driverId, Pageable pageable);

    List<CompletedRide> findByDriverId(Long driverId);

    List<CompletedRide> findByCampaignId(Long campaignId);

    List<CompletedRide> findByCampaignIdIn(List<Long> campaignIds);

    void deleteByDriverId(Long driverId);
}
