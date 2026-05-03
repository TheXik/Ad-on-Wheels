package com.adonwheels.gatewayservice.dto;

import java.util.List;

public record CampaignCoverage(Long campaignId, List<RideRoute> routes) {}
