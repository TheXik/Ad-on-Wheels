package com.adonwheels.gatewayservice.dto;

public class CampaignRideStats {
    private Long campaignId;
    private long totalRides;
    private double totalDistanceKm;
    private long totalDurationSeconds;
    private double totalEarnings;
    private long activeDriverCount;

    public CampaignRideStats() {
    }

    public CampaignRideStats(Long campaignId, long totalRides, double totalDistanceKm,
                             long totalDurationSeconds, double totalEarnings, long activeDriverCount) {
        this.campaignId = campaignId;
        this.totalRides = totalRides;
        this.totalDistanceKm = totalDistanceKm;
        this.totalDurationSeconds = totalDurationSeconds;
        this.totalEarnings = totalEarnings;
        this.activeDriverCount = activeDriverCount;
    }

    public Long getCampaignId() { return campaignId; }
    public void setCampaignId(Long campaignId) { this.campaignId = campaignId; }

    public long getTotalRides() { return totalRides; }
    public void setTotalRides(long totalRides) { this.totalRides = totalRides; }

    public double getTotalDistanceKm() { return totalDistanceKm; }
    public void setTotalDistanceKm(double totalDistanceKm) { this.totalDistanceKm = totalDistanceKm; }

    public long getTotalDurationSeconds() { return totalDurationSeconds; }
    public void setTotalDurationSeconds(long totalDurationSeconds) { this.totalDurationSeconds = totalDurationSeconds; }

    public double getTotalEarnings() { return totalEarnings; }
    public void setTotalEarnings(double totalEarnings) { this.totalEarnings = totalEarnings; }

    public long getActiveDriverCount() { return activeDriverCount; }
    public void setActiveDriverCount(long activeDriverCount) { this.activeDriverCount = activeDriverCount; }
}
