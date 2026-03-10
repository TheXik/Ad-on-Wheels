package com.adonwheels.campaignservice.controller;

import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.CampaignStatus;
import com.adonwheels.campaignservice.model.Application;
import com.adonwheels.campaignservice.service.CampaignService;
import com.adonwheels.campaignservice.service.ApplicationService;
import dto.ApiResponse;
import jakarta.validation.Valid;
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

    @GetMapping
    public ResponseEntity<ApiResponse<List<Campaign>>> getAllCampaigns(
            @RequestParam(required = false) CampaignStatus status) {
        List<Campaign> campaigns = (status != null)
                ? campaignService.findByStatus(status)
                : campaignService.findAll();
        return ResponseEntity.ok(ApiResponse.success(campaigns));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Campaign>> getCampaignById(@PathVariable Long id) {
        Campaign campaign = campaignService.findById(id);
        return ResponseEntity.ok(ApiResponse.success(campaign));
    }

    @GetMapping("/company/{companyId}")
    public ResponseEntity<ApiResponse<List<Campaign>>> getCampaignsByCompany(
            @PathVariable Long companyId,
            @RequestParam(required = false) CampaignStatus status) {
        List<Campaign> campaigns = (status != null)
                ? campaignService.findByCompanyIdAndStatus(companyId, status)
                : campaignService.findByCompanyId(companyId);
        return ResponseEntity.ok(ApiResponse.success(campaigns));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Campaign>> createCampaign(@Valid @RequestBody Campaign campaign) {
        Campaign saved = campaignService.save(campaign);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(saved));
    }

    @PostMapping("/{id}/apply")
    public ResponseEntity<ApiResponse<Application>> applyToCampaign(
            @PathVariable Long id, @RequestParam Long driverId) {
        campaignService.findById(id);
        Application app = applicationService.apply(id, driverId);
        return ResponseEntity.ok(ApiResponse.success(app));
    }

    @GetMapping("/{companyId}/applications")
    public ResponseEntity<ApiResponse<List<Application>>> getApplicationsForCompany(
            @PathVariable Long companyId) {
        List<Application> applications = applicationService.findByCompanyCampaigns(
                campaignService.findByCompanyId(companyId));
        return ResponseEntity.ok(ApiResponse.success(applications));
    }

    @PostMapping("/applications/{id}/accept")
    public ResponseEntity<ApiResponse<Application>> acceptApplication(@PathVariable Long id) {
        Application app = applicationService.accept(id);
        return ResponseEntity.ok(ApiResponse.success(app));
    }

    @PostMapping("/applications/{id}/decline")
    public ResponseEntity<ApiResponse<Application>> declineApplication(@PathVariable Long id) {
        Application app = applicationService.decline(id);
        return ResponseEntity.ok(ApiResponse.success(app));
    }
} 