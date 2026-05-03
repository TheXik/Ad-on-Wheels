# UC11: View Ride Route

A driver opens any of their completed rides and sees the route as a
polyline on a map. It addresses **FR.15**.


## Actors

Driver.


## Preconditions

a. The driver is signed in.
b. The driver has at least one completed ride (verified, unverified, or
   deferred) with a recorded position trace.
c. The driver needs to inspect the geographic path of a past ride.


## Basic Flow

1. The driver chooses a completed ride from the ride history.
2. The system retrieves the position trace recorded for that ride.
3. The system renders the trace as a polyline on a map, fits the map's
   viewport to the trace bounds, and shows the ride's headline metrics
   (distance, duration, average speed, earnings, verification status)
   alongside the map.
4. The driver chooses to close the route view or to return to the ride
   list.


## Alternative Flows

**2a. The ride has no recorded position trace** (a deferred ride
reconstructed from too few samples, or a ride for which the device
produced no usable points). The system tells the driver the route
cannot be drawn and shows the headline metrics only.

**3a. The trace cannot be fetched.** The system tells the driver the
request failed and offers to retry; previously cached values, if any,
remain visible.


## Postconditions

a. The driver has seen the geographic path the system recorded for the
   chosen ride.
b. No persistent state changes.
