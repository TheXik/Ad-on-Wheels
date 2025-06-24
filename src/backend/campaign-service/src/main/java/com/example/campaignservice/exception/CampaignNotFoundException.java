package com.example.campaignservice.exception;

public class CampaignNotFoundException extends RuntimeException {
    public CampaignNotFoundException(Long id) {
        super("Could not find campaign " + id);
    }
} 