package com.example.campaignservice.service;

import com.example.campaignservice.model.Application;
import com.example.campaignservice.model.Campaign;
import com.example.campaignservice.exception.ApplicationNotFoundException;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class ApplicationService {
    private final Map<Long, Application> applications = new HashMap<>();
    private final AtomicLong idGen = new AtomicLong(1);

    public Application apply(Long campaignId, Long driverId) {
        Long appId = idGen.getAndIncrement();
        Application app = new Application(appId, campaignId, driverId, "applied");
        applications.put(appId, app);
        return app;
    }

    public List<Application> findByCompanyCampaigns(List<Campaign> companyCampaigns) {
        Set<Long> campaignIds = new HashSet<>();
        for (Campaign c : companyCampaigns) {
            campaignIds.add(c.getId());
        }
        List<Application> result = new ArrayList<>();
        for (Application app : applications.values()) {
            if (campaignIds.contains(app.getCampaignId())) {
                result.add(app);
            }
        }
        return result;
    }

    public Application accept(Long id) {
        Application app = applications.get(id);
        if (app == null) throw new ApplicationNotFoundException(id);
        app.setStatus("accepted");
        return app;
    }

    public Application decline(Long id) {
        Application app = applications.get(id);
        if (app == null) throw new ApplicationNotFoundException(id);
        app.setStatus("declined");
        return app;
    }
} 