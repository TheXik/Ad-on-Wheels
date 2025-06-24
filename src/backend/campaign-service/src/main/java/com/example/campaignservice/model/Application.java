package com.example.campaignservice.model;

public class Application {
    private Long id;
    private Long campaignId;
    private Long driverId;
    private String status; // "applied", "accepted", "declined"

    public Application() {}

    public Application(Long id, Long campaignId, Long driverId, String status) {
        this.id = id;
        this.campaignId = campaignId;
        this.driverId = driverId;
        this.status = status;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getCampaignId() { return campaignId; }
    public void setCampaignId(Long campaignId) { this.campaignId = campaignId; }
    public Long getDriverId() { return driverId; }
    public void setDriverId(Long driverId) { this.driverId = driverId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
} 