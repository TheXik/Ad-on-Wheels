package com.example.campaignservice.service;

import com.example.campaignservice.model.Campaign;
import com.example.campaignservice.exception.CampaignNotFoundException;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class CampaignService {
    private final Map<Long, Campaign> campaigns = new HashMap<>();
    private final AtomicLong idGen = new AtomicLong(3);

    public CampaignService() {
        // Sample data
        campaigns.put(1L, new Campaign(1L, "Spring Promo", "Advertise with us this spring!", 100L));
        campaigns.put(2L, new Campaign(2L, "Summer Drive", "Join our summer campaign.", 101L));
    }

    public List<Campaign> findAll() {
        return new ArrayList<>(campaigns.values());
    }

    public Campaign findById(Long id) {
        Campaign campaign = campaigns.get(id);
        if (campaign == null) throw new CampaignNotFoundException(id);
        return campaign;
    }

    public Campaign save(Campaign campaign) {
        if (campaign.getId() == null) {
            campaign.setId(idGen.getAndIncrement());
        }
        campaigns.put(campaign.getId(), campaign);
        return campaign;
    }

    public List<Campaign> findByCompanyId(Long companyId) {
        List<Campaign> result = new ArrayList<>();
        for (Campaign c : campaigns.values()) {
            if (c.getCompanyId().equals(companyId)) {
                result.add(c);
            }
        }
        return result;
    }
} 