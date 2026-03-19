package com.adonwheels.rideservice.model;

import org.springframework.data.cassandra.core.mapping.Column;
import org.springframework.data.cassandra.core.mapping.PrimaryKey;
import org.springframework.data.cassandra.core.mapping.Table;

@Table("driver_active_ride")
public class DriverActiveRide {

    @PrimaryKey("driver_id")
    private String driverId;

    @Column("ride_id")
    private String rideId;

    public DriverActiveRide() {
    }

    public DriverActiveRide(String driverId, String rideId) {
        this.driverId = driverId;
        this.rideId = rideId;
    }

    public String getDriverId() {
        return driverId;
    }

    public void setDriverId(String driverId) {
        this.driverId = driverId;
    }

    public String getRideId() {
        return rideId;
    }

    public void setRideId(String rideId) {
        this.rideId = rideId;
    }
}
