package com.adonwheels.gatewayservice.dto;

import java.time.LocalDateTime;

public record Driver(
        Long id,
        String name,
        String email,
        String vehicleMake,
        String vehicleModel,
        String vehicleYear,
        String vehiclePlate,
        String vehicleImageUrl,
        Double monthlyGoalKm,
        Boolean onboardingCompleted,
        LocalDateTime memberSince
) {}
