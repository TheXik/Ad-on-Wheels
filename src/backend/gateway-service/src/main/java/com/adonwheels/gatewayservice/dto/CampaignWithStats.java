package com.adonwheels.gatewayservice.dto;

public class CampaignWithStats {
    private Campaign campaign;
    private CampaignRideStats rideStats;

    public CampaignWithStats() {
    }

    public CampaignWithStats(Campaign campaign, CampaignRideStats rideStats) {
        this.campaign = campaign;
        this.rideStats = rideStats;
    }

    public Campaign getCampaign() { return campaign; }
    public void setCampaign(Campaign campaign) { this.campaign = campaign; }

    public CampaignRideStats getRideStats() { return rideStats; }
    public void setRideStats(CampaignRideStats rideStats) { this.rideStats = rideStats; }
}
