package com.adonwheels.rideservice.repository;

import com.adonwheels.rideservice.model.RideSession;

import java.util.Optional;

/**
 * Storage contract for active ride sessions.
 * Backed by Cassandra via {@link RideRepositoryCassandra}.
 */
public interface RideRepository {

    void save(RideSession session);

    Optional<RideSession> findById(String rideId);

    Optional<RideSession> findByDriverId(String driverId);

    void deleteById(String rideId);
}
