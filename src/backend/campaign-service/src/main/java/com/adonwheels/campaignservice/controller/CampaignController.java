package com.adonwheels.campaignservice.controller;

import com.adonwheels.campaignservice.model.Campaign;
import com.adonwheels.campaignservice.model.CampaignStatus;
import com.adonwheels.campaignservice.model.Application;
import com.adonwheels.campaignservice.model.ApplicationStatus;
import com.adonwheels.campaignservice.service.CampaignService;
import com.adonwheels.campaignservice.service.ApplicationService;
import com.adonwheels.campaignservice.service.ImageStorageService;
import com.adonwheels.campaignservice.dto.ApplicationWithCampaign;
import com.adonwheels.dto.ApiResponse;
import com.adonwheels.dto.AppErrorCode;
import com.adonwheels.dto.exception.BusinessException;
import jakarta.validation.Valid;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping("/campaigns")
public class CampaignController {
    private final CampaignService campaignService;
    private final ApplicationService applicationService;
    private final ImageStorageService imageStorageService;

    public CampaignController(CampaignService campaignService,
                              ApplicationService applicationService,
                              ImageStorageService imageStorageService) {
        this.campaignService = campaignService;
        this.applicationService = applicationService;
        this.imageStorageService = imageStorageService;
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
            @RequestParam(required = false) CampaignStatus status,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        // A company may only list its own campaigns; ADMIN bypasses.
        requireOwnership(callerId, callerRole, companyId);
        List<Campaign> campaigns = (status != null)
                ? campaignService.findByCompanyIdAndStatus(companyId, status)
                : campaignService.findByCompanyId(companyId);
        return ResponseEntity.ok(ApiResponse.success(campaigns));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Campaign>> createCampaign(
            @Valid @RequestBody Campaign campaign,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        // companyId travels in the body; pin it to the caller (ADMIN bypasses).
        requireOwnership(callerId, callerRole, campaign.getCompanyId());
        Campaign saved = campaignService.save(campaign);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(saved));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCampaign(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        // Look up the campaign to find the owning companyId, then check ownership.
        Campaign existing = campaignService.findById(id);
        requireOwnership(callerId, callerRole, existing.getCompanyId());
        applicationService.deleteByCampaignId(id);
        campaignService.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @GetMapping("/driver/{driverId}")
    public ResponseEntity<ApiResponse<List<Campaign>>> getCampaignsByDriver(
            @PathVariable Long driverId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, driverId);
        List<Application> accepted = applicationService.findByDriverIdAndStatus(driverId, ApplicationStatus.ACCEPTED);
        List<Long> campaignIds = accepted.stream().map(Application::getCampaignId).toList();
        List<Campaign> campaigns = campaignIds.stream()
                .map(campaignService::findById)
                .toList();
        return ResponseEntity.ok(ApiResponse.success(campaigns));
    }

    @GetMapping("/driver/{driverId}/applications")
    public ResponseEntity<ApiResponse<List<ApplicationWithCampaign>>> getApplicationsByDriver(
            @PathVariable Long driverId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, driverId);
        List<Application> apps = applicationService.findByDriverId(driverId);
        List<ApplicationWithCampaign> result = apps.stream().map(app -> {
            Campaign campaign = campaignService.findById(app.getCampaignId());
            return new ApplicationWithCampaign(
                    app.getId(), app.getCampaignId(),
                    campaign.getName(), campaign.getCompanyId(), app.getStatus().name());
        }).toList();
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @PostMapping("/{id}/apply")
    public ResponseEntity<ApiResponse<Application>> applyToCampaign(
            @PathVariable Long id,
            @RequestParam Long driverId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, driverId);
        Campaign campaign = campaignService.findById(id);
        Application app = applicationService.apply(campaign, driverId);
        return ResponseEntity.ok(ApiResponse.success(app));
    }

    @GetMapping("/{companyId}/applications")
    public ResponseEntity<ApiResponse<List<Application>>> getApplicationsForCompany(
            @PathVariable Long companyId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, companyId);
        List<Application> applications = applicationService.findByCompanyCampaigns(
                campaignService.findByCompanyId(companyId));
        return ResponseEntity.ok(ApiResponse.success(applications));
    }

    @PatchMapping("/applications/{id}")
    public ResponseEntity<ApiResponse<Application>> updateApplicationStatus(
            @PathVariable Long id,
            @RequestBody ApplicationStatusUpdate update,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        // Only the owning company (the campaign's companyId) may accept or decline.
        Application existing = applicationService.findById(id);
        Campaign campaign = campaignService.findById(existing.getCampaignId());
        requireOwnership(callerId, callerRole, campaign.getCompanyId());
        Application app = switch (update.status()) {
            case ACCEPTED -> applicationService.accept(id);
            case DECLINED -> applicationService.decline(id);
            case APPLIED, EXPIRED -> throw new BusinessException(
                    AppErrorCode.VALIDATION_ERROR,
                    "Application status can only be transitioned to ACCEPTED or DECLINED.");
        };
        return ResponseEntity.ok(ApiResponse.success(app));
    }

    public record ApplicationStatusUpdate(ApplicationStatus status) {}

    @DeleteMapping("/applications/{id}")
    public ResponseEntity<ApiResponse<Void>> withdrawApplication(
            @PathVariable Long id,
            @RequestParam Long driverId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        // Pin the body driverId to the caller; ApplicationService.withdraw also
        // re-checks the application's owning driverId for defence in depth.
        requireOwnership(callerId, callerRole, driverId);
        applicationService.withdraw(id, driverId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @GetMapping("/{id}/export")
    public ResponseEntity<byte[]> exportCampaignStats(
            @PathVariable Long id,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        Campaign campaign = campaignService.findById(id);
        requireOwnership(callerId, callerRole, campaign.getCompanyId());
        List<Application> applications = applicationService.findByCampaignId(id);

        long accepted = applications.stream()
                .filter(a -> a.getStatus() == ApplicationStatus.ACCEPTED)
                .count();
        long declined = applications.stream()
                .filter(a -> a.getStatus() == ApplicationStatus.DECLINED)
                .count();
        long pending = applications.stream()
                .filter(a -> a.getStatus() == ApplicationStatus.APPLIED)
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
                .contentType(MediaType.parseMediaType("text/csv; charset=UTF-8"))
                .body(('\uFEFF' + csv.toString()).getBytes(StandardCharsets.UTF_8));
    }

    @PostMapping("/{id}/images")
    public ResponseEntity<ApiResponse<Campaign>> uploadImages(
            @PathVariable Long id,
            @RequestParam("files") List<MultipartFile> files,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        Campaign campaign = campaignService.findById(id);
        requireOwnership(callerId, callerRole, campaign.getCompanyId());
        List<String> newKeys = imageStorageService.upload(id, files, campaign.getImageKeys().size());
        campaign.getImageKeys().addAll(newKeys);
        Campaign updated = campaignService.save(campaign);
        return ResponseEntity.ok(ApiResponse.success(updated));
    }

    @GetMapping("/images/{campaignId}/{filename}")
    public ResponseEntity<byte[]> getImage(
            @PathVariable Long campaignId,
            @PathVariable String filename) {
        String key = campaignId + "/" + filename;
        byte[] imageBytes = imageStorageService.download(key);
        String contentType = imageStorageService.getContentType(key);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .cacheControl(CacheControl.maxAge(7, TimeUnit.DAYS).cachePublic())
                .body(imageBytes);
    }

    @GetMapping("/company/{companyId}/export")
    public ResponseEntity<byte[]> exportAllCampaignStats(
            @PathVariable Long companyId,
            @RequestHeader(value = "X-User-Id", required = false) Long callerId,
            @RequestHeader(value = "X-User-Role", required = false) String callerRole) {
        requireOwnership(callerId, callerRole, companyId);
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
                .contentType(MediaType.parseMediaType("text/csv; charset=UTF-8"))
                .body(('\uFEFF' + csv.toString()).getBytes(StandardCharsets.UTF_8));
    }

    // Per-endpoint owner-id check. The gateway role-class gate (A3) only proves
    // the caller carries the correct role class; this pins the actual
    // companyId/driverId on the resource. ADMIN bypasses every check.
    private void requireOwnership(Long callerId, String callerRole, Long pathOwnerId) {
        if ("ADMIN".equals(callerRole)) {
            return;
        }
        if (callerId == null || pathOwnerId == null || !callerId.equals(pathOwnerId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Caller is not authorized to act on this resource");
        }
    }
}