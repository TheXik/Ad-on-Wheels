package com.example.driverservice.dto;

public class StartRideRequest {

    private Long campaignId; // Optional

    private String startLocation; // Optional

    public StartRideRequest() {
    }

    public StartRideRequest(Long campaignId, String startLocation) {
        this.campaignId = campaignId;
        this.startLocation = startLocation;
    }

    // Getters and Setters
    public Long getCampaignId() {
        return campaignId;
    }

    public void setCampaignId(Long campaignId) {
        this.campaignId = campaignId;
    }

    public String getStartLocation() {
        return startLocation;
    }

    public void setStartLocation(String startLocation) {
        this.startLocation = startLocation;
    }
}
