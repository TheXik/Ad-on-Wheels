package com.adonwheels.rideservice.repository;

import com.adonwheels.rideservice.model.RideSession;

import java.util.Optional;

public interface RideRepository {

    void save(RideSession session);

    Optional<RideSession> findById(String rideId);

    Optional<RideSession> findByDriverId(String driverId);

    void deleteById(String rideId);
}
