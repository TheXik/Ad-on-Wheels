package com.adonwheels.rideservice.service;

import com.adonwheels.rideservice.model.LocationPoint;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RideServiceUnitTest {

    private static LocationPoint at(double lat, double lon, int secondsFromStart) {
        return new LocationPoint(lat, lon, LocalDateTime.of(2026, 1, 1, 12, 0).plusSeconds(secondsFromStart));
    }

    @Test
    void emptyOrSinglePointTrackReturnsZeroDistance() {
        assertEquals(0.0, RideService.calculateTotalDistance(null));
        assertEquals(0.0, RideService.calculateTotalDistance(List.of()));
        assertEquals(0.0, RideService.calculateTotalDistance(List.of(at(50.0, 14.0, 0))));
    }

    @Test
    void straightOneKilometerSegmentIsCountedRoughlyAsOneKilometer() {
        // 0.009 deg latitude ~= 1.0 km on the meridian.
        List<LocationPoint> route = List.of(
                at(50.0000, 14.0, 0),
                at(50.0090, 14.0, 60)
        );
        double km = RideService.calculateTotalDistance(route);
        assertEquals(1.0, km, 0.05);
    }

    @Test
    void glitchSegmentImplyingOver200KmhIsDiscarded() {
        // ~5 km in 5 seconds -> implied speed ~3600 km/h -> must be filtered.
        List<LocationPoint> route = List.of(
                at(50.0000, 14.0, 0),
                at(50.0450, 14.0, 5)
        );
        double km = RideService.calculateTotalDistance(route);
        assertEquals(0.0, km);
    }

    @Test
    void jitterSegmentsUnderTenMetersAreDiscarded() {
        // Two consecutive points 5 m apart (lat delta ~4.5e-5).
        List<LocationPoint> route = List.of(
                at(50.0000, 14.0, 0),
                at(50.000045, 14.0, 5)
        );
        double km = RideService.calculateTotalDistance(route);
        assertEquals(0.0, km);
    }

    @Test
    void typicalUrbanRouteAccumulatesAllValidSegments() {
        List<LocationPoint> route = List.of(
                at(50.0000, 14.0000, 0),
                at(50.0090, 14.0000, 60),   // +1 km
                at(50.0090, 14.0140, 120),  // +1 km east at this latitude (cos 50 ≈ 0.643, 0.014 deg ≈ 1 km)
                at(50.0180, 14.0140, 180)   // +1 km
        );
        double km = RideService.calculateTotalDistance(route);
        assertTrue(km > 2.7 && km < 3.3, "Expected ~3 km, got " + km);
    }

    @Test
    void haversineKmMatchesKnownDistance() {
        // Prague (50.0755 N, 14.4378 E) to Brno (49.1951 N, 16.6068 E) ~= 184 km.
        LocationPoint prague = new LocationPoint(50.0755, 14.4378, LocalDateTime.now());
        LocationPoint brno = new LocationPoint(49.1951, 16.6068, LocalDateTime.now());
        double km = RideService.haversineKm(prague, brno);
        assertTrue(km > 180 && km < 190, "Expected ~184 km, got " + km);
    }
}
