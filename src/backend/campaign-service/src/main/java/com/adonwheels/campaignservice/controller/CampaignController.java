package com.adonwheels.campaignservice.controller;

import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.CampaignStatus;
import com.adonwheels.campaignservice.model.Application;
import com.adonwheels.campaignservice.service.CampaignService;
import com.adonwheels.campaignservice.service.ApplicationService;
import dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
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

    /**
     * UC008 – Export campaign stats as CSV.
     * Returns a downloadable CSV file with campaign details and application metrics.
     */
    @GetMapping("/{id}/export")
    public ResponseEntity<byte[]> exportCampaignStats(@PathVariable Long id) {
        Campaign campaign = campaignService.findById(id);
        List<Application> applications = applicationService.findByCampaignId(id);

        long accepted = applications.stream()
                .filter(a -> a.getStatus() == com.adonwheels.campaignservice.model.ApplicationStatus.ACCEPTED)
                .count();
        long declined = applications.stream()
                .filter(a -> a.getStatus() == com.adonwheels.campaignservice.model.ApplicationStatus.DECLINED)
                .count();
        long pending = applications.stream()
                .filter(a -> a.getStatus() == com.adonwheels.campaignservice.model.ApplicationStatus.APPLIED)
                .count();

        StringBuilder csv = new StringBuilder();
        csv.append("Metric,Value\n");
        csv.append("Campaign ID,").append(campaign.getId()).append("\n");
        csv.append("Campaign Name,\"").append(campaign.getName().replace("\"", "\"\"")).append("\"\n");
        csv.append("Status,").append(campaign.getStatus()).append("\n");
        csv.append("Start Date,").append(campaign.getStartDate()).append("\n");
        csv.append("End Date,").append(campaign.getEndDate()).append("\n");
        csv.append("Budget,").append(campaign.getBudget()).append("\n");
        csv.append("Max Drivers,").append(campaign.getMaxDrivers()).append("\n");
        csv.append("Estimated Reach,").append(campaign.getEstimatedReach() != null ? campaign.getEstimatedReach() : "N/A").append("\n");
        csv.append("Total Applications,").append(applications.size()).append("\n");
        csv.append("Accepted Drivers,").append(accepted).append("\n");
        csv.append("Declined Drivers,").append(declined).append("\n");
        csv.append("Pending Applications,").append(pending).append("\n");
        csv.append("\n");
        csv.append("Application ID,Driver ID,Status\n");
        for (Application app : applications) {
            csv.append(app.getId()).append(",")
               .append(app.getDriverId()).append(",")
               .append(app.getStatus()).append("\n");
        }

        String filename = "campaign_" + id + "_stats.csv";

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(csv.toString().getBytes());
    }

    /**
     * UC008 – Export all campaigns for a company as CSV.
     */
    @GetMapping("/company/{companyId}/export")
    public ResponseEntity<byte[]> exportAllCampaignStats(@PathVariable Long companyId) {
        List<Campaign> campaigns = campaignService.findByCompanyId(companyId);

        if (campaigns.isEmpty()) {
            return ResponseEntity.noContent().build();
        }

        StringBuilder csv = new StringBuilder();
        csv.append("Campaign ID,Name,Status,Start Date,End Date,Budget,Max Drivers,Estimated Reach\n");
        for (Campaign c : campaigns) {
            csv.append(c.getId()).append(",\"")
               .append(c.getName().replace("\"", "\"\"")).append("\",")
               .append(c.getStatus()).append(",")
               .append(c.getStartDate()).append(",")
               .append(c.getEndDate()).append(",")
               .append(c.getBudget()).append(",")
               .append(c.getMaxDrivers()).append(",")
               .append(c.getEstimatedReach() != null ? c.getEstimatedReach() : "N/A")
               .append("\n");
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"company_" + companyId + "_campaigns.csv\"")
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(csv.toString().getBytes());
    }
} 