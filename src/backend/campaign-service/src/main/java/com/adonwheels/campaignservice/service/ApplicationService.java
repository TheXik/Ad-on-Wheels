package com.adonwheels.campaignservice.service;

import com.adonwheels.campaignservice.model.Application;
import com.adonwheels.campaignservice.model.ApplicationStatus;
import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.exception.ActiveCampaignException;
import com.adonwheels.campaignservice.exception.ApplicationNotFoundException;
import com.adonwheels.campaignservice.exception.DuplicateApplicationException;
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
        if (applicationRepository.existsByDriverIdAndCampaignId(driverId, campaignId)) {
            throw new DuplicateApplicationException(driverId, campaignId);
        }
        if (applicationRepository.existsByDriverIdAndStatus(driverId, ApplicationStatus.ACCEPTED)) {
            throw new ActiveCampaignException(driverId);
        }
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

    public List<Application> findByDriverId(Long driverId) {
        return applicationRepository.findByDriverId(driverId);
    }

    @Transactional
    public void deleteByCampaignId(Long campaignId) {
        List<Application> apps = applicationRepository.findByCampaignId(campaignId);
        applicationRepository.deleteAll(apps);
    }

    @Transactional
    public Application accept(Long id) {
        Application app = applicationRepository.findById(id).orElseThrow(() -> new ApplicationNotFoundException(id));
        app.setStatus(ApplicationStatus.ACCEPTED);
        Application saved = applicationRepository.save(app);

        List<Application> otherPending = applicationRepository
                .findByDriverIdAndStatusAndIdNot(app.getDriverId(), ApplicationStatus.APPLIED, id);
        for (Application other : otherPending) {
            other.setStatus(ApplicationStatus.DECLINED);
        }
        applicationRepository.saveAll(otherPending);

        return saved;
    }

    @Transactional
    public Application decline(Long id) {
        Application app = applicationRepository.findById(id).orElseThrow(() -> new ApplicationNotFoundException(id));
        app.setStatus(ApplicationStatus.DECLINED);
        return applicationRepository.save(app);
    }
}
