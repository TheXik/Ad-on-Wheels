package com.adonwheels.gatewayservice.dto;

import java.util.List;

// Aggregated coverage data for a single campaign: every completed ride
// contributed by accepted drivers, each tagged with its verification flag.
public record CampaignCoverage(Long campaignId, List<RideRoute> routes) {}
