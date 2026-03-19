package com.adonwheels.gatewayservice.dto;

public class DriverHomePageResponse {
    private Driver driver;
    private Ride activeRide;
    private Campaign currentCampaign;
    private RideStatistics statistics;

    public DriverHomePageResponse() {
    }

    public DriverHomePageResponse(Driver driver, Ride activeRide, Campaign currentCampaign, RideStatistics statistics) {
        this.driver = driver;
        this.activeRide = activeRide;
        this.currentCampaign = currentCampaign;
        this.statistics = statistics;
    }

    // Getters and Setters
    public Driver getDriver() {
        return driver;
    }

    public void setDriver(Driver driver) {
        this.driver = driver;
    }

    public Ride getActiveRide() {
        return activeRide;
    }

    public void setActiveRide(Ride activeRide) {
        this.activeRide = activeRide;
    }

    public Campaign getCurrentCampaign() {
        return currentCampaign;
    }

    public void setCurrentCampaign(Campaign currentCampaign) {
        this.currentCampaign = currentCampaign;
    }

    public RideStatistics getStatistics() {
        return statistics;
    }

    public void setStatistics(RideStatistics statistics) {
        this.statistics = statistics;
    }
}
