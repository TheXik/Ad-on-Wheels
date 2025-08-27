package com.example.campaignservice.service;

import com.example.campaignservice.model.Campaign;
import com.example.campaignservice.repository.CampaignRepository;
import com.example.campaignservice.exception.CampaignNotFoundException;
import org.springframework.stereotype.Service;

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

    public Campaign save(Campaign campaign) {
        return repository.save(campaign);
    }

    public List<Campaign> findByCompanyId(Long companyId) {
        return repository.findByCompanyId(companyId);
    }
} 