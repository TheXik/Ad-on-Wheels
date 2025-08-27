package com.example.campaignservice.controller;

import com.example.campaignservice.model.Campaign;
import com.example.campaignservice.model.Application;
import com.example.campaignservice.service.CampaignService;
import com.example.campaignservice.service.ApplicationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/campaigns")
public class CampaignController {
    private final CampaignService campaignService;
    private final ApplicationService applicationService;

    public CampaignController(CampaignService campaignService, ApplicationService applicationService) {
        this.campaignService = campaignService;
        this.applicationService = applicationService;
    }

    // GET /campaigns - List all campaigns
    @GetMapping
    public List<Campaign> getAllCampaigns() {
        return campaignService.findAll();
    }

    // POST /campaigns - Create a new campaign
    @PostMapping
    public ResponseEntity<Campaign> createCampaign(@RequestBody Campaign campaign) {
        Campaign saved = campaignService.save(campaign);
        return ResponseEntity.ok(saved);
    }

    // POST /campaigns/{id}/apply - Driver applies to campaign
    @PostMapping("/{id}/apply")
    public ResponseEntity<Application> applyToCampaign(@PathVariable Long id, @RequestParam Long driverId) {
        campaignService.findById(id); // Throws if not found
        Application app = applicationService.apply(id, driverId);
        return ResponseEntity.ok(app);
    }

    // GET /campaigns/{companyId}/applications - Company views applications to their campaigns
    @GetMapping("/{companyId}/applications")
    public List<Application> getApplicationsForCompany(@PathVariable Long companyId) {
        return applicationService.findByCompanyCampaigns(campaignService.findByCompanyId(companyId));
    }

    // POST /applications/{id}/accept - Accept application
    @PostMapping("/applications/{id}/accept")
    public ResponseEntity<Application> acceptApplication(@PathVariable Long id) {
        Application app = applicationService.accept(id);
        return ResponseEntity.ok(app);
    }

    // POST /applications/{id}/decline - Decline application
    @PostMapping("/applications/{id}/decline")
    public ResponseEntity<Application> declineApplication(@PathVariable Long id) {
        Application app = applicationService.decline(id);
        return ResponseEntity.ok(app);
    }
} 