package com.adonwheels.campaignservice.repository;

import com.adonwheels.campaignservice.model.Campaign;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CampaignRepository extends JpaRepository<Campaign, Long> {
    List<Campaign> findByCompanyId(Long companyId);
} 