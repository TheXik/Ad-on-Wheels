package com.adonwheels.rideservice.repository;

import com.adonwheels.rideservice.model.CompletedRide;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface RideHistoryRepository extends JpaRepository<CompletedRide, Long> {

    List<CompletedRide> findByDriverIdOrderByStartTimeDesc(Long driverId, Pageable pageable);

    List<CompletedRide> findByDriverId(Long driverId);

    List<CompletedRide> findByCampaignId(Long campaignId);

    List<CompletedRide> findByCampaignIdIn(List<Long> campaignIds);

    void deleteByDriverId(Long driverId);

    // Budget-tracking aggregate. Returns Object[] rows of (campaignId, sumEarnings)
    // for verified rides only. Used by campaign-service's CampaignLifecycleScheduler
    // to flip RECRUITING campaigns to COMPLETED once cumulative paid earnings
    // hit the campaign budget.
    @Query("SELECT r.campaignId, SUM(r.earnings) FROM CompletedRide r " +
           "WHERE r.verified = true AND r.campaignId IN :ids GROUP BY r.campaignId")
    List<Object[]> sumVerifiedEarningsByCampaignIds(@Param("ids") List<Long> ids);
}
