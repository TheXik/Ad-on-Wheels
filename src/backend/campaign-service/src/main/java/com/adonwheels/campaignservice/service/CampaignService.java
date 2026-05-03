package com.adonwheels.campaignservice.service;

import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.CampaignStatus;
import com.adonwheels.campaignservice.repository.CampaignRepository;
import com.adonwheels.campaignservice.exception.CampaignNotFoundException;
import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CampaignService {
    private final CampaignRepository repository;
    private final ImageStorageService imageStorageService;

    public CampaignService(CampaignRepository repository, ImageStorageService imageStorageService) {
        this.repository = repository;
        this.imageStorageService = imageStorageService;
    }

    public List<Campaign> findAll() {
        List<Campaign> campaigns = repository.findAll();
        campaigns.forEach(this::populateImageUrls);
        return campaigns;
    }

    public Campaign findById(Long id) {
        Campaign campaign = repository.findById(id).orElseThrow(() -> new CampaignNotFoundException(id));
        populateImageUrls(campaign);
        return campaign;
    }

    @Transactional
    public Campaign save(Campaign campaign) {
        if (campaign.getStartDate() != null && campaign.getEndDate() != null
                && !campaign.getStartDate().isBefore(campaign.getEndDate())) {
            throw new BusinessException(AppErrorCode.INVALID_CAMPAIGN_DATES);
        }
        Campaign saved = repository.save(campaign);
        populateImageUrls(saved);
        return saved;
    }

    public List<Campaign> findByCompanyId(Long companyId) {
        List<Campaign> campaigns = repository.findByCompanyId(companyId);
        campaigns.forEach(this::populateImageUrls);
        return campaigns;
    }

    public List<Campaign> findByCompanyIdAndStatus(Long companyId, CampaignStatus status) {
        List<Campaign> campaigns = repository.findByCompanyIdAndStatus(companyId, status);
        campaigns.forEach(this::populateImageUrls);
        return campaigns;
    }

    @Transactional
    public void deleteById(Long id) {
        if (!repository.existsById(id)) {
            throw new CampaignNotFoundException(id);
        }
        repository.deleteById(id);
    }

    public List<Campaign> findByStatus(CampaignStatus status) {
        List<Campaign> campaigns = repository.findByStatus(status);
        campaigns.forEach(this::populateImageUrls);
        return campaigns;
    }

    private void populateImageUrls(Campaign campaign) {
        if (campaign.getImageKeys() != null && !campaign.getImageKeys().isEmpty()) {
            campaign.setImageUrls(
                    campaign.getImageKeys().stream()
                            .map(imageStorageService::buildImageUrl)
                            .toList()
            );
        }
    }
} 