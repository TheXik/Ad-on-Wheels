package com.adonwheels.campaignservice.controller;

import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.Application;
import com.adonwheels.campaignservice.service.CampaignService;
import com.adonwheels.campaignservice.service.ApplicationService;
import dto.ApiResponse;
import org.springframework.http.HttpStatus;
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
    public ResponseEntity<ApiResponse<List<Campaign>>> getAllCampaigns() {
        List<Campaign> campaigns = campaignService.findAll();
        return ResponseEntity.ok(ApiResponse.success(campaigns));
    }

    // GET /campaigns/{id} - Get single campaign by ID
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Campaign>> getCampaignById(@PathVariable Long id) {
        Campaign campaign = campaignService.findById(id);
        return ResponseEntity.ok(ApiResponse.success(campaign));
    }

    // POST /campaigns - Create a new campaign
    @PostMapping
    public ResponseEntity<ApiResponse<Campaign>> createCampaign(@RequestBody Campaign campaign) {
        Campaign saved = campaignService.save(campaign);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(saved));
    }

    // POST /campaigns/{id}/apply - Driver applies to campaign
    @PostMapping("/{id}/apply")
    public ResponseEntity<ApiResponse<Application>> applyToCampaign(@PathVariable Long id, @RequestParam Long driverId) {
        campaignService.findById(id); // Throws if not found
        Application app = applicationService.apply(id, driverId);
        return ResponseEntity.ok(ApiResponse.success(app));
    }

    // GET /campaigns/{companyId}/applications - Company views applications to their campaigns
    @GetMapping("/{companyId}/applications")
    public ResponseEntity<ApiResponse<List<Application>>> getApplicationsForCompany(@PathVariable Long companyId) {
        List<Application> applications = applicationService.findByCompanyCampaigns(campaignService.findByCompanyId(companyId));
        return ResponseEntity.ok(ApiResponse.success(applications));
    }

    // POST /applications/{id}/accept - Accept application
    @PostMapping("/applications/{id}/accept")
    public ResponseEntity<ApiResponse<Application>> acceptApplication(@PathVariable Long id) {
        Application app = applicationService.accept(id);
        return ResponseEntity.ok(ApiResponse.success(app));
    }

    // POST /applications/{id}/decline - Decline application
    @PostMapping("/applications/{id}/decline")
    public ResponseEntity<ApiResponse<Application>> declineApplication(@PathVariable Long id) {
        Application app = applicationService.decline(id);
        return ResponseEntity.ok(ApiResponse.success(app));
    }
} 