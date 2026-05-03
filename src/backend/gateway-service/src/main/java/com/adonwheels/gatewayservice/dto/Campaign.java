package com.adonwheels.gatewayservice.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record Campaign(
        Long id,
        String name,
        String description,
        Long companyId,
        LocalDate startDate,
        LocalDate endDate,
        BigDecimal budget,
        Integer maxDrivers,
        BigDecimal ratePerKm,
        Long estimatedReach,
        String status,
        List<String> imageUrls
) {}
