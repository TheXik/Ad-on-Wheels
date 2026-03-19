package com.adonwheels.campaignservice.repository;

import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.CampaignStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CampaignRepository extends JpaRepository<Campaign, Long> {
    List<Campaign> findByCompanyId(Long companyId);
    List<Campaign> findByCompanyIdAndStatus(Long companyId, CampaignStatus status);
    List<Campaign> findByStatus(CampaignStatus status);
} 