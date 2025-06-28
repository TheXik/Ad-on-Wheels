package com.example.campaignservice.service;

import com.example.campaignservice.model.Application;
import com.example.campaignservice.model.Campaign;
import com.example.campaignservice.exception.ApplicationNotFoundException;
import com.example.campaignservice.repository.ApplicationRepository;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ApplicationService {
    private final ApplicationRepository applicationRepository;

    @Autowired
    public ApplicationService(ApplicationRepository applicationRepository) {
        this.applicationRepository = applicationRepository;
    }

    public Application apply(Long campaignId, Long driverId) {
        Application app = new Application();
        app.setCampaignId(campaignId);
        app.setDriverId(driverId);
        app.setStatus("applied");
        return applicationRepository.save(app);
    }

    public List<Application> findByCompanyCampaigns(List<Campaign> companyCampaigns) {
        List<Long> campaignIds = companyCampaigns.stream().map(Campaign::getId).collect(Collectors.toList());
        return applicationRepository.findByCampaignIdIn(campaignIds);
    }

    public Application accept(Long id) {
        Application app = applicationRepository.findById(id).orElseThrow(() -> new ApplicationNotFoundException(id));
        app.setStatus("accepted");
        return applicationRepository.save(app);
    }

    public Application decline(Long id) {
        Application app = applicationRepository.findById(id).orElseThrow(() -> new ApplicationNotFoundException(id));
        applicationRepository.deleteById(id);
        return app;
    }
} 