package com.adonwheels.gatewayservice.dto;

import java.util.List;

/**
 * Aggregated coverage data for a single campaign: every completed ride
 * contributed by accepted drivers, each tagged with its verification flag.
 */
public class CampaignCoverage {
    private Long campaignId;
    private List<RideRoute> routes;

    public CampaignCoverage() {
    }

    public CampaignCoverage(Long campaignId, List<RideRoute> routes) {
        this.campaignId = campaignId;
        this.routes = routes;
    }

    public Long getCampaignId() { return campaignId; }
    public void setCampaignId(Long campaignId) { this.campaignId = campaignId; }

    public List<RideRoute> getRoutes() { return routes; }
    public void setRoutes(List<RideRoute> routes) { this.routes = routes; }
}
