package com.adonwheels.rideservice.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RideHistoryResponse {

    private Long id;
    private Long driverId;
    private Long campaignId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String startLocation;
    private String endLocation;
    private Integer duration;
    private String qrCodeData;
    private String status;
    private Double distanceKm;
    private Double averageSpeedKmh;
    private Double earnings;
}
