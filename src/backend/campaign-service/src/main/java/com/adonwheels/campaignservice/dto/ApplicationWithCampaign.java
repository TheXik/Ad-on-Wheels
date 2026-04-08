package com.adonwheels.campaignservice.dto;

public class ApplicationWithCampaign {
    private Long id;
    private Long campaignId;
    private String campaignName;
    private Long companyId;
    private String status;

    public ApplicationWithCampaign(Long id, Long campaignId, String campaignName, Long companyId, String status) {
        this.id = id;
        this.campaignId = campaignId;
        this.campaignName = campaignName;
        this.companyId = companyId;
        this.status = status;
    }

    public Long getId() { return id; }
    public Long getCampaignId() { return campaignId; }
    public String getCampaignName() { return campaignName; }
    public Long getCompanyId() { return companyId; }
    public String getStatus() { return status; }
}
