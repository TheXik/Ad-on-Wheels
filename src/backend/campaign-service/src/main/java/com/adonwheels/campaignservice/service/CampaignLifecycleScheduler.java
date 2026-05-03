package com.adonwheels.campaignservice.service;

import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.CampaignStatus;
import com.adonwheels.campaignservice.repository.CampaignRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

// Daily lifecycle pass that flips campaigns whose end date has passed from
// RECRUITING to COMPLETED. The capacity-fill transition is handled inline by
// ApplicationService.accept; this scheduler only catches the other path
// (campaigns that ran out of time before filling).
@Component
public class CampaignLifecycleScheduler {

    private static final Logger logger = LoggerFactory.getLogger(CampaignLifecycleScheduler.class);

    private final CampaignRepository campaignRepository;

    public CampaignLifecycleScheduler(CampaignRepository campaignRepository) {
        this.campaignRepository = campaignRepository;
    }

    @Scheduled(cron = "0 0 1 * * *", zone = "UTC")
    @Transactional
    public void transitionExpiredCampaigns() {
        List<Campaign> expired = campaignRepository.findByStatusAndEndDateBefore(
                CampaignStatus.RECRUITING, LocalDate.now());
        if (expired.isEmpty()) {
            return;
        }
        expired.forEach(c -> c.setStatus(CampaignStatus.COMPLETED));
        campaignRepository.saveAll(expired);
        logger.info("Lifecycle scheduler: transitioned {} expired campaigns to COMPLETED", expired.size());
    }
}
