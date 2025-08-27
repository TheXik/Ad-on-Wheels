package com.example.gatewayservice.dto;

public class ApplicationWithDriver {
    private Long id;
    private Long campaignId;
    private String campaignName;
    private String status;
    private Driver driver;

    public ApplicationWithDriver() {
    }

    public ApplicationWithDriver(Long id, Long campaignId, String campaignName, String status, Driver driver) {
        this.id = id;
        this.campaignId = campaignId;
        this.campaignName = campaignName;
        this.status = status;
        this.driver = driver;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(Long campaignId) {
        this.campaignId = campaignId;
    }

    public String getCampaignName() {
        return campaignName;
    }

    public void setCampaignName(String campaignName) {
        this.campaignName = campaignName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Driver getDriver() {
        return driver;
    }

    public void setDriver(Driver driver) {
        this.driver = driver;
    }
} 