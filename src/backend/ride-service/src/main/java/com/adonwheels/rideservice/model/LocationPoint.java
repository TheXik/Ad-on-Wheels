package com.adonwheels.rideservice.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.cassandra.core.mapping.Column;
import org.springframework.data.cassandra.core.mapping.UserDefinedType;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@UserDefinedType("location_point")
public class LocationPoint {
    private double lat;
    private double lon;
    @Column("captured_at")
    private LocalDateTime capturedAt;
}
