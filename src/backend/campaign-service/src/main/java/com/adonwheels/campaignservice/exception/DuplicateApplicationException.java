package com.adonwheels.campaignservice.exception;

public class DuplicateApplicationException extends RuntimeException {
    public DuplicateApplicationException(Long driverId, Long campaignId) {
        super("Driver " + driverId + " has already applied to campaign " + campaignId);
    }
}
