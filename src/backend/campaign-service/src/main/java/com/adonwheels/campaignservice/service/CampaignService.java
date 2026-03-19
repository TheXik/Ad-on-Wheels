package com.adonwheels.campaignservice.service;

import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.CampaignStatus;
import com.adonwheels.campaignservice.repository.CampaignRepository;
import com.adonwheels.campaignservice.exception.CampaignNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CampaignService {
    private final CampaignRepository repository;

    public CampaignService(CampaignRepository repository) {
        this.repository = repository;
    }

    public List<Campaign> findAll() {
        return repository.findAll();
    }

    public Campaign findById(Long id) {
        return repository.findById(id).orElseThrow(() -> new CampaignNotFoundException(id));
    }

    @Transactional
    public Campaign save(Campaign campaign) {
        return repository.save(campaign);
    }

    public List<Campaign> findByCompanyId(Long companyId) {
        return repository.findByCompanyId(companyId);
    }

    public List<Campaign> findByCompanyIdAndStatus(Long companyId, CampaignStatus status) {
        return repository.findByCompanyIdAndStatus(companyId, status);
    }

    public List<Campaign> findByStatus(CampaignStatus status) {
        return repository.findByStatus(status);
    }
} 