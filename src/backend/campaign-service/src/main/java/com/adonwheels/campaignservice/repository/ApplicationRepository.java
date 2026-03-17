package com.adonwheels.campaignservice.repository;

import com.adonwheels.campaignservice.model.Application;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ApplicationRepository extends JpaRepository<Application, Long> {
    List<Application> findByCampaignIdIn(List<Long> campaignIds);
    List<Application> findByCampaignId(Long campaignId);
} 