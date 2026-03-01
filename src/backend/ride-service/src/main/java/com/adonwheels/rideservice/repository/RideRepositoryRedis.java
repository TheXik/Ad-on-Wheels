package com.adonwheels.rideservice.repository;

import com.adonwheels.rideservice.model.RideSession;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Primary;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.concurrent.TimeUnit;

/**
 * Redis-backed implementation of {@link RideRepository}.
 *
 * <p>Storage layout:
 * <pre>
 *   Key:   ride:{rideId}          (plain String)
 *   Value: JSON-serialized RideSession
 *   TTL:   24 hours — auto-expires sessions from drivers who never called /end
 * </pre>
 *
 * <p>This is the active implementation ({@code @Primary}). The in-memory
 * {@code RideRepositoryMem} has been removed.
 */
@Primary
@Repository
public class RideRepositoryRedis implements RideRepository {

    private static final String KEY_PREFIX = "ride:";
    private static final long TTL_HOURS = 24;

    private final RedisTemplate<String, String> redis;
    private final ObjectMapper mapper;

    public RideRepositoryRedis(RedisTemplate<String, String> redis, ObjectMapper mapper) {
        this.redis = redis;
        this.mapper = mapper;
    }

    @Override
    public void save(RideSession session) {
        String key = key(session.getRideId());
        String json = serialize(session);
        redis.opsForValue().set(key, json, TTL_HOURS, TimeUnit.HOURS);
    }

    @Override
    public Optional<RideSession> findById(String rideId) {
        String json = redis.opsForValue().get(key(rideId));
        if (json == null) {
            return Optional.empty();
        }
        return Optional.of(deserialize(json));
    }

    @Override
    public void deleteById(String rideId) {
        redis.delete(key(rideId));
    }

    // -------------------------------------------------------------------------

    private String key(String rideId) {
        return KEY_PREFIX + rideId;
    }

    private String serialize(RideSession session) {
        try {
            return mapper.writeValueAsString(session);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Failed to serialize RideSession to JSON", e);
        }
    }

    private RideSession deserialize(String json) {
        try {
            return mapper.readValue(json, RideSession.class);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Failed to deserialize RideSession from JSON", e);
        }
    }
}
