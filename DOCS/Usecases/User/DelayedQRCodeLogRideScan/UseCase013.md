# UC13: Deferred Ride Reconstruction

**Addresses:** FR.11. Extends **UC01** as a fallback ride-creation path.

A driver who drove with an advertisement mounted but forgot to start a
ride through UC01 must be able to recover the drive retroactively.


## Actors
Driver.


## Preconditions
- The driver is logged in and has at least one accepted campaign
  application.
- The mobile application has been *observable on the device* during the
  drive (foreground or in a system-observable state), so that it was
  able to sample position data.
- No active ride session exists on the backend for the driver at the
  moment of recovery.

> The scope of the mechanism in the initial version is limited to
> drives during which the application was observable on the device.
> Covering true background collection is *not required* in this version.


## Basic Flow
1. The driver opens the mobile application.
2. The system checks for an active ride session and finds none.
3. The system inspects the bounded recent history of position samples
   collected while the application was observable. If enough data has
   been collected to make reconstruction meaningful, the system offers
   to reconstruct a deferred ride.
4. The driver confirms.
5. The client submits the buffered position samples to the backend.
6. The backend computes total distance, duration, average speed, and
   earnings from the submitted samples and persists a new ride with
   status **`DEFERRED`**.
7. The system returns the driver to the updated home screen with the
   new ride included in the cumulative statistics.


## Alternative Flows

**3a. Insufficient position data.** The system does not offer deferred
reconstruction. The use case ends without creating a ride.

**4a. Driver declines.** The buffered samples are discarded. The use
case ends without creating a ride.


## Postconditions
A ride entry with status `DEFERRED` is persisted with the reconstructed
distance, duration, average speed, and earnings; the driver's
cumulative statistics include the new ride.


## Design Notes
Verification via QR scan is not part of this flow. Deferred rides are
inherently unverified and may be treated differently by payout logic;
the platform must retain the `DEFERRED` status column so this
distinction is preserved in the data model.
