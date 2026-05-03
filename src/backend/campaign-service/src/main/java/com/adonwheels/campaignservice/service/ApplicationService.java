package com.adonwheels.campaignservice.service;

import com.adonwheels.campaignservice.model.Application;
import com.adonwheels.campaignservice.model.ApplicationStatus;
import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.CampaignStatus;
import com.adonwheels.campaignservice.exception.ActiveCampaignException;
import com.adonwheels.campaignservice.exception.ApplicationNotFoundException;
import com.adonwheels.campaignservice.exception.DuplicateApplicationException;
import com.adonwheels.campaignservice.repository.ApplicationRepository;
import com.adonwheels.campaignservice.repository.CampaignRepository;
import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ApplicationService {
    private final ApplicationRepository applicationRepository;
    private final CampaignRepository campaignRepository;

    public ApplicationService(ApplicationRepository applicationRepository,
                              CampaignRepository campaignRepository) {
        this.applicationRepository = applicationRepository;
        this.campaignRepository = campaignRepository;
    }

    @Transactional
    public Application apply(Campaign campaign, Long driverId) {
        Long campaignId = campaign.getId();
        if (applicationRepository.existsByDriverIdAndCampaignId(driverId, campaignId)) {
            throw new DuplicateApplicationException(driverId, campaignId);
        }
        if (applicationRepository.existsByDriverIdAndStatus(driverId, ApplicationStatus.ACCEPTED)) {
            throw new ActiveCampaignException(driverId);
        }
        if (campaign.getEndDate() != null && campaign.getEndDate().isBefore(LocalDate.now())) {
            throw new BusinessException(AppErrorCode.CAMPAIGN_EXPIRED);
        }
        long acceptedCount = applicationRepository.countByCampaignIdAndStatus(campaignId, ApplicationStatus.ACCEPTED);
        if (campaign.getMaxDrivers() != null && acceptedCount >= campaign.getMaxDrivers()) {
            throw new BusinessException(AppErrorCode.CAMPAIGN_FULL);
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

        // Flip campaign to COMPLETED once it hits maxDrivers, so it
        // disappears from RECRUITING-filtered driver decks.
        campaignRepository.findById(saved.getCampaignId()).ifPresent(campaign -> {
            if (campaign.getStatus() == CampaignStatus.RECRUITING && campaign.getMaxDrivers() != null) {
                long acceptedCount = applicationRepository.countByCampaignIdAndStatus(
                        campaign.getId(), ApplicationStatus.ACCEPTED);
                if (acceptedCount >= campaign.getMaxDrivers()) {
                    campaign.setStatus(CampaignStatus.COMPLETED);
                    campaignRepository.save(campaign);
                }
            }
        });

        return saved;
    }

    @Transactional
    public Application decline(Long id) {
        Application app = applicationRepository.findById(id).orElseThrow(() -> new ApplicationNotFoundException(id));
        app.setStatus(ApplicationStatus.DECLINED);
        return applicationRepository.save(app);
    }

    @Transactional
    public void withdraw(Long applicationId, Long driverId) {
        Application app = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new ApplicationNotFoundException(applicationId));
        if (!app.getDriverId().equals(driverId)) {
            throw new BusinessException(AppErrorCode.ACCESS_DENIED,
                    "Driver " + driverId + " cannot withdraw application " + applicationId);
        }
        if (app.getStatus() != ApplicationStatus.APPLIED) {
            throw new BusinessException(AppErrorCode.VALIDATION_ERROR,
                    "Only pending applications can be withdrawn");
        }
        applicationRepository.delete(app);
    }
}
