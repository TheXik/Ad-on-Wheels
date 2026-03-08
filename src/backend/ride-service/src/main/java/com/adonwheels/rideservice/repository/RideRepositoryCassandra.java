package com.adonwheels.rideservice.repository;

import com.adonwheels.rideservice.model.DriverActiveRide;
import com.adonwheels.rideservice.model.RideSession;
import org.springframework.context.annotation.Primary;
import org.springframework.data.cassandra.core.CassandraOperations;
import org.springframework.data.cassandra.core.InsertOptions;
import org.springframework.stereotype.Repository;

import java.time.Duration;
import java.util.Optional;

@Primary
@Repository
public class RideRepositoryCassandra implements RideRepository {

    private static final Duration TTL = Duration.ofHours(24);

    private final CassandraOperations cassandraOps;

    public RideRepositoryCassandra(CassandraOperations cassandraOps) {
        this.cassandraOps = cassandraOps;
    }

    @Override
    public void save(RideSession session) {
        InsertOptions options = InsertOptions.builder().ttl(TTL).build();
        cassandraOps.insert(session, options);
        cassandraOps.insert(new DriverActiveRide(session.getDriverId(), session.getRideId()), options);
    }

    @Override
    public Optional<RideSession> findById(String rideId) {
        return Optional.ofNullable(cassandraOps.selectOneById(rideId, RideSession.class));
    }

    @Override
    public Optional<RideSession> findByDriverId(String driverId) {
        DriverActiveRide index = cassandraOps.selectOneById(driverId, DriverActiveRide.class);
        if (index == null) {
            return Optional.empty();
        }
        return findById(index.getRideId());
    }

    @Override
    public void deleteById(String rideId) {
        findById(rideId).ifPresent(session ->
                cassandraOps.deleteById(session.getDriverId(), DriverActiveRide.class)
        );
        cassandraOps.deleteById(rideId, RideSession.class);
    }
}
