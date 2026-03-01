package com.adonwheels.rideservice.repository;

import com.adonwheels.rideservice.model.RideSession;

import java.util.Optional;

/**
 * Storage contract for active ride sessions.
 *
 * <p>Currently backed by {@link RideRepositoryMem} (in-memory).
 * Swap the bean for {@code RideRepositoryRedis} when ready — zero other changes required.</p>
 */
public interface RideRepository {

    void save(RideSession session);

    Optional<RideSession> findById(String rideId);

    void deleteById(String rideId);
}
