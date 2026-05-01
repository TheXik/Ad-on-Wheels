#if DEBUG
import Foundation
import CoreLocation
import MapKit
import Combine

@MainActor
final class StreetRouteSimulator {

    var onLocationUpdate: ((CLLocation) -> Void)?

    private(set) var isRunning = false

    private var routePoints: [CLLocationCoordinate2D] = []
    private var currentSegmentIndex: Int = 0
    private var progressAlongSegment: Double = 0.0
    private var travelledOnRoute: Double = 0.0

    private var nextRoutePoints: [CLLocationCoordinate2D]?
    private var isPrefetchingNext = false

    private var simulationTimer: AnyCancellable?
    private let tickInterval: TimeInterval = 0.1

    private var currentSpeedMps: Double = 0.0
    private var cruiseSpeedMps: Double = 11.0

    private var lastEmittedCoordinate: CLLocationCoordinate2D?
    private var isFetchingRoute = false

    static let defaultStart = CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378)

    func start(from coordinate: CLLocationCoordinate2D?) {
        isRunning = true
        let origin = coordinate ?? Self.defaultStart
        lastEmittedCoordinate = origin
        cruiseSpeedMps = Double.random(in: 8.3...13.9)
        Task {
            await fetchAndStartRoute(from: origin)
        }
    }

    func stop() {
        isRunning = false
        simulationTimer?.cancel()
        simulationTimer = nil
        routePoints = []
        nextRoutePoints = nil
        currentSegmentIndex = 0
        progressAlongSegment = 0.0
        travelledOnRoute = 0.0
        currentSpeedMps = 0.0
        isFetchingRoute = false
        isPrefetchingNext = false
    }

    private func fetchAndStartRoute(from origin: CLLocationCoordinate2D, retryCount: Int = 0) async {
        guard isRunning else { return }
        isFetchingRoute = true

        let destination = randomDestination(from: origin)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        do {
            let response = try await MKDirections(request: request).calculate()
            guard isRunning else { return }

            if let route = response.routes.first {
                let coords = extractCoordinates(from: route.polyline)
                if coords.count >= 2 {
                    routePoints = coords
                    currentSegmentIndex = 0
                    progressAlongSegment = 0.0
                    travelledOnRoute = 0.0
                    cruiseSpeedMps = Double.random(in: 8.3...13.9)
                    nextRoutePoints = nil
                    isPrefetchingNext = false
                    isFetchingRoute = false
                    startTimer()
                    return
                }
            }
            // Route had < 2 points, retry
            if retryCount < 3 {
                await fetchAndStartRoute(from: origin, retryCount: retryCount + 1)
            } else {
                useFallbackRoute(from: origin)
            }
        } catch {
            guard isRunning else { return }
            if retryCount < 3 {
                await fetchAndStartRoute(from: origin, retryCount: retryCount + 1)
            } else {
                useFallbackRoute(from: origin)
            }
        }
    }

    private func prefetchNextRoute(from origin: CLLocationCoordinate2D) async {
        guard isRunning else { return }

        let destination = randomDestination(from: origin)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        do {
            let response = try await MKDirections(request: request).calculate()
            guard isRunning else { return }
            if let route = response.routes.first {
                let coords = extractCoordinates(from: route.polyline)
                if coords.count >= 2 {
                    nextRoutePoints = coords
                    return
                }
            }
        } catch {
            // Prefetch failed -- will be handled when route ends
        }
        isPrefetchingNext = false
    }

    private func useFallbackRoute(from origin: CLLocationCoordinate2D) {
        let bearing = Double.random(in: 0..<360) * .pi / 180.0
        var points: [CLLocationCoordinate2D] = [origin]
        for i in 1...10 {
            let dist = Double(i) * 80.0
            points.append(offsetCoordinate(origin, bearing: bearing, distanceMeters: dist))
        }
        routePoints = points
        currentSegmentIndex = 0
        progressAlongSegment = 0.0
        travelledOnRoute = 0.0
        cruiseSpeedMps = Double.random(in: 6.0...10.0)
        nextRoutePoints = nil
        isPrefetchingNext = false
        isFetchingRoute = false
        startTimer()
    }

    private func startTimer() {
        guard simulationTimer == nil else { return }
        simulationTimer = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard isRunning, routePoints.count >= 2 else { return }

        updateSpeed()
        let distanceThisTick = currentSpeedMps * tickInterval
        advancePosition(by: distanceThisTick)
        checkPrefetch()
    }

    private func advancePosition(by distance: Double) {
        var remaining = distance

        while remaining > 0 && currentSegmentIndex < routePoints.count - 1 {
            let start = routePoints[currentSegmentIndex]
            let end = routePoints[currentSegmentIndex + 1]
            let segmentLength = Self.distanceMeters(from: start, to: end)

            if segmentLength < 0.01 {
                currentSegmentIndex += 1
                progressAlongSegment = 0.0
                continue
            }

            let distanceIntoSegment = progressAlongSegment * segmentLength
            let distanceRemaining = segmentLength - distanceIntoSegment

            if remaining <= distanceRemaining {
                progressAlongSegment += remaining / segmentLength
                travelledOnRoute += remaining
                remaining = 0
            } else {
                remaining -= distanceRemaining
                travelledOnRoute += distanceRemaining
                currentSegmentIndex += 1
                progressAlongSegment = 0.0
            }
        }

        if currentSegmentIndex >= routePoints.count - 1 {
            transitionToNextRoute()
            return
        }

        emitLocation()
    }

    private func emitLocation() {
        guard currentSegmentIndex < routePoints.count - 1 else { return }

        let start = routePoints[currentSegmentIndex]
        let end = routePoints[currentSegmentIndex + 1]

        let lat = start.latitude + (end.latitude - start.latitude) * progressAlongSegment
        let lon = start.longitude + (end.longitude - start.longitude) * progressAlongSegment
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)

        let course = Self.bearing(from: start, to: end)

        let location = CLLocation(
            coordinate: coord,
            altitude: 200,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            course: course,
            speed: currentSpeedMps,
            timestamp: Date()
        )

        lastEmittedCoordinate = coord
        onLocationUpdate?(location)
    }

    private func transitionToNextRoute() {
        if let next = nextRoutePoints, next.count >= 2 {
            routePoints = next
            nextRoutePoints = nil
            isPrefetchingNext = false
            currentSegmentIndex = 0
            progressAlongSegment = 0.0
            travelledOnRoute = 0.0
            cruiseSpeedMps = Double.random(in: 8.3...13.9)
            return
        }

        // Next route not ready -- stop and fetch
        simulationTimer?.cancel()
        simulationTimer = nil
        currentSpeedMps = 0.0

        if let coord = lastEmittedCoordinate {
            let stopLocation = CLLocation(
                coordinate: coord,
                altitude: 200,
                horizontalAccuracy: 5,
                verticalAccuracy: 5,
                course: -1,
                speed: 0,
                timestamp: Date()
            )
            onLocationUpdate?(stopLocation)
        }

        let origin = lastEmittedCoordinate ?? Self.defaultStart
        Task {
            await fetchAndStartRoute(from: origin)
        }
    }

    private func checkPrefetch() {
        guard routePoints.count >= 2, !isPrefetchingNext, nextRoutePoints == nil else { return }
        let progress = Double(currentSegmentIndex) / Double(routePoints.count - 1)
        if progress > 0.8 {
            isPrefetchingNext = true
            let lastPoint = routePoints.last ?? Self.defaultStart
            Task {
                await prefetchNextRoute(from: lastPoint)
            }
        }
    }

    private func updateSpeed() {
        let totalRouteLength = totalRouteDistance()
        let distanceToEnd = totalRouteLength - travelledOnRoute
        let targetSpeed: Double

        if distanceToEnd < 50 {
            let ratio = max(0, distanceToEnd / 50.0)
            targetSpeed = 2.0 + (cruiseSpeedMps - 2.0) * ratio
        } else if travelledOnRoute < 30 {
            let ratio = min(1, travelledOnRoute / 30.0)
            targetSpeed = 2.0 + (cruiseSpeedMps - 2.0) * ratio
        } else {
            let turnAngle = currentTurnAngle()
            if turnAngle > 60 {
                targetSpeed = cruiseSpeedMps * 0.5
            } else if turnAngle > 30 {
                targetSpeed = cruiseSpeedMps * 0.75
            } else {
                targetSpeed = cruiseSpeedMps
            }
        }

        let accel: Double = currentSpeedMps < targetSpeed ? 2.0 : 3.0
        let maxChange = accel * tickInterval
        let diff = targetSpeed - currentSpeedMps

        if abs(diff) < maxChange {
            currentSpeedMps = targetSpeed
        } else {
            currentSpeedMps += diff > 0 ? maxChange : -maxChange
        }
        currentSpeedMps = max(0, currentSpeedMps)
    }

    private func currentTurnAngle() -> Double {
        guard currentSegmentIndex > 0, currentSegmentIndex < routePoints.count - 1 else { return 0 }
        let prev = routePoints[currentSegmentIndex - 1]
        let curr = routePoints[currentSegmentIndex]
        let next = routePoints[currentSegmentIndex + 1]

        let bearing1 = Self.bearing(from: prev, to: curr)
        let bearing2 = Self.bearing(from: curr, to: next)

        var angle = abs(bearing2 - bearing1)
        if angle > 180 { angle = 360 - angle }
        return angle
    }

    private func totalRouteDistance() -> Double {
        var total = 0.0
        for i in 0..<routePoints.count - 1 {
            total += Self.distanceMeters(from: routePoints[i], to: routePoints[i + 1])
        }
        return total
    }


    private func randomDestination(from origin: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let bearing = Double.random(in: 0..<360) * .pi / 180.0
        let distance = Double.random(in: 500...1000)
        return offsetCoordinate(origin, bearing: bearing, distanceMeters: distance)
    }

    private func offsetCoordinate(
        _ origin: CLLocationCoordinate2D,
        bearing: Double,
        distanceMeters: Double
    ) -> CLLocationCoordinate2D {
        let earthRadius = 6_371_000.0
        let lat1 = origin.latitude * .pi / 180.0
        let lon1 = origin.longitude * .pi / 180.0

        let lat2 = asin(
            sin(lat1) * cos(distanceMeters / earthRadius) +
            cos(lat1) * sin(distanceMeters / earthRadius) * cos(bearing)
        )
        let lon2 = lon1 + atan2(
            sin(bearing) * sin(distanceMeters / earthRadius) * cos(lat1),
            cos(distanceMeters / earthRadius) - sin(lat1) * sin(lat2)
        )

        return CLLocationCoordinate2D(
            latitude: lat2 * 180.0 / .pi,
            longitude: lon2 * 180.0 / .pi
        )
    }

    private func extractCoordinates(from polyline: MKPolyline) -> [CLLocationCoordinate2D] {
        let count = polyline.pointCount
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: count)
        polyline.getCoordinates(&coords, range: NSRange(location: 0, length: count))
        return coords
    }

    private static func distanceMeters(
        from a: CLLocationCoordinate2D,
        to b: CLLocationCoordinate2D
    ) -> Double {
        CLLocation(latitude: a.latitude, longitude: a.longitude)
            .distance(from: CLLocation(latitude: b.latitude, longitude: b.longitude))
    }

    private static func bearing(
        from a: CLLocationCoordinate2D,
        to b: CLLocationCoordinate2D
    ) -> Double {
        let lat1 = a.latitude * .pi / 180.0
        let lat2 = b.latitude * .pi / 180.0
        let dLon = (b.longitude - a.longitude) * .pi / 180.0

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        var degrees = atan2(y, x) * 180.0 / .pi
        if degrees < 0 { degrees += 360 }
        return degrees
    }
}
#endif
