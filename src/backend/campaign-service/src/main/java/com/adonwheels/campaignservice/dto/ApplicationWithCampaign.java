package com.adonwheels.campaignservice.dto;

public record ApplicationWithCampaign(
        Long id,
        Long campaignId,
        String campaignName,
        Long companyId,
        String status
) {}
