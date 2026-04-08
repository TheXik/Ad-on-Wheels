package com.adonwheels.campaignservice.exception;

public class ActiveCampaignException extends RuntimeException {
    public ActiveCampaignException(Long driverId) {
        super("Driver " + driverId + " already has an active campaign");
    }
}
