package com.adonwheels.rideservice.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RideStatisticsResponse {

    private Long totalRides;
    private Long completedRides;
    private Long verifiedRides;
    private Integer totalDurationSeconds;
    private Integer averageDurationSeconds;
    private Long activeRidesCount;
    private Double totalDistanceKm;
    private Double weeklyDistanceKm;
    private Double monthlyDistanceKm;
    private Double totalEarnings;
    private Double weeklyEarnings;
    private Double monthlyEarnings;
    private Double averageSpeedKmh;
    private Double rating;
}
