# UC01: Log a Ride with QR Verification

**Addresses:** FR.9, FR.10, and the verification aspect of FR.14.

This is the central use case of the platform; it exercises on-device
position tracking, backend ride processing, and the post-ride QR
verification gesture.


## Actors
Driver.


## Preconditions
- The driver is logged in.
- The driver has at least one accepted campaign application.
- The driver has granted the application *while-in-use* location permission.


## Basic Flow
1. The driver opens the home screen and taps **Start Ride**.
2. The system creates a ride session on the backend, activates on-device
   position tracking, and transitions to the riding screen showing a live
   map, running timer, current speed, and cumulative distance.
3. At the sampling interval specified by **NFR.4** (at most five seconds),
   the client uploads the most recent position sample to the backend and
   updates the distance display locally.
4. When the driver taps **End Ride**, the backend computes total
   distance, duration, average speed, and earnings from the stored
   position samples and returns the result.
5. The system transitions to the QR scan screen and prompts the driver
   to scan the QR code on the vehicle.
6. On a successful scan, the system confirms, marks the ride as
   **verified**, and returns the driver to the updated home screen.


## Alternative Flows

**3a. Position fixes temporarily stale.** The client invalidates the
live speed display, the periodic upload loop keeps running with the last
known fix, and normal operation resumes when a new fix arrives.

**5a. QR code not immediately decoded.** The camera stays active; frames
without a decodable payload are silently discarded until a valid code is
read.

**5b. Driver leaves the QR screen without scanning.** The ride has
already been persisted with status **unverified** and the platform
treats unverified rides as not billable. The status can be moved to
**verified** only by a subsequent successful scan tied to the same
ride identifier.


## Postconditions
A ride entry is persisted with its position trace, distance, duration,
average speed, earnings, and verification status. The driver's
cumulative statistics include the new ride.


## Design Notes
Every completed ride must carry an explicit verification status
(`unverified` / `verified`). In the initial version a successful QR scan
is the only event that transitions a ride to `verified`; server-side
validation of the scanned value against the campaign's vehicle
identifier is identified as a future extension. The data model reserves
the status column from the outset so this extension does not require
schema changes.
