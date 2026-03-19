package com.adonwheels.campaignservice.service;

import com.adonwheels.campaignservice.model.Application;
import com.adonwheels.campaignservice.model.ApplicationStatus;
import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.exception.ApplicationNotFoundException;
import com.adonwheels.campaignservice.repository.ApplicationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ApplicationService {
    private final ApplicationRepository applicationRepository;

    public ApplicationService(ApplicationRepository applicationRepository) {
        this.applicationRepository = applicationRepository;
    }

    @Transactional
    public Application apply(Long campaignId, Long driverId) {
        Application app = new Application();
        app.setCampaignId(campaignId);
        app.setDriverId(driverId);
        app.setStatus(ApplicationStatus.APPLIED);
        return applicationRepository.save(app);
    }

    public List<Application> findByCompanyCampaigns(List<Campaign> companyCampaigns) {
        List<Long> campaignIds = companyCampaigns.stream().map(Campaign::getId).collect(Collectors.toList());
        return applicationRepository.findByCampaignIdIn(campaignIds);
    }

    public List<Application> findByCampaignId(Long campaignId) {
        return applicationRepository.findByCampaignId(campaignId);
    }

    public List<Application> findByDriverIdAndStatus(Long driverId, ApplicationStatus status) {
        return applicationRepository.findByDriverIdAndStatus(driverId, status);
    }

    @Transactional
    public Application accept(Long id) {
        Application app = applicationRepository.findById(id).orElseThrow(() -> new ApplicationNotFoundException(id));
        app.setStatus(ApplicationStatus.ACCEPTED);
        return applicationRepository.save(app);
    }

    @Transactional
    public Application decline(Long id) {
        Application app = applicationRepository.findById(id).orElseThrow(() -> new ApplicationNotFoundException(id));
        app.setStatus(ApplicationStatus.DECLINED);
        return applicationRepository.save(app);
    }
}
