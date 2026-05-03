package com.adonwheels.campaignservice.repository;

import com.adonwheels.campaignservice.model.Application;
import com.adonwheels.campaignservice.model.ApplicationStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ApplicationRepository extends JpaRepository<Application, Long> {
    List<Application> findByCampaignIdIn(List<Long> campaignIds);
    List<Application> findByCampaignId(Long campaignId);
    List<Application> findByDriverIdAndStatus(Long driverId, ApplicationStatus status);
    List<Application> findByDriverId(Long driverId);

    List<Application> findByDriverIdAndStatusAndIdNot(Long driverId, ApplicationStatus status, Long excludeId);

    boolean existsByDriverIdAndCampaignId(Long driverId, Long campaignId);

    boolean existsByDriverIdAndStatus(Long driverId, ApplicationStatus status);

    long countByCampaignIdAndStatus(Long campaignId, ApplicationStatus status);
}
