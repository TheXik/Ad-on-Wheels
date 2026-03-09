package com.adonwheels.rideservice.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.cassandra.core.mapping.Column;
import org.springframework.data.cassandra.core.mapping.PrimaryKey;
import org.springframework.data.cassandra.core.mapping.Table;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table("driver_active_ride")
public class DriverActiveRide {

    @PrimaryKey("driver_id")
    private String driverId;

    @Column("ride_id")
    private String rideId;
}
