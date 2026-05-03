package com.adonwheels.gatewayservice.dto;

// Coordinate emitted by the coverage / heat-map aggregator. Mirrors RoutePointDto
// from ride-service.
public record RoutePoint(double lat, double lon) {}
