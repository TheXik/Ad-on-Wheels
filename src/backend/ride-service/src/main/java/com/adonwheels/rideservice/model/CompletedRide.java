package com.adonwheels.rideservice.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "rides")
@Getter
@Setter
@NoArgsConstructor
public class CompletedRide {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long driverId;

    @Column(nullable = false)
    private LocalDateTime startTime;

    @Column(nullable = false)
    private LocalDateTime endTime;

    @Column(nullable = false)
    private Integer duration;

    @Column(nullable = false)
    private Double distanceKm;

    @Column(nullable = false)
    private Double averageSpeedKmh;

    @Column(nullable = false)
    private Double earnings;

    @Column(nullable = false)
    private String status;
}
