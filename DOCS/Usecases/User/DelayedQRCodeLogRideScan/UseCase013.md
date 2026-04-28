# UC13: Deferred Ride Reconstruction

Deferred reconstruction is the fallback path to **UC01**. It lets a
driver who drove with an advertisement mounted but forgot to start a
ride through the application recover the drive retroactively. It
addresses **FR.11** and extends **UC01** as an alternative ride-creation
path.


## Actors

Driver.


## Preconditions

a. The driver is signed in.
b. The driver has at least one accepted campaign.
c. No active ride exists for this driver.
d. The driver needs to record a drive they did not start through
   **UC01** so that the kilometers are credited toward their earnings.


## Basic Flow

1. While the driver has an accepted campaign but no active ride, the
   system collects position samples in the background.
2. The driver chooses the QR verification step without having started a
   ride.
3. The system detects no active ride and offers to reconstruct the
   recent drive as a deferred ride.
4. The driver confirms.
5. The system computes the distance, duration, average speed, and
   earnings of the reconstructed drive, and records it as a deferred,
   unverified ride.
6. The system shows the reconstructed totals to the driver and enters
   the ride into the driver's ride history.


## Alternative Flows

**3a. The system has not collected enough position samples to
reconstruct a drive.** The system does not offer the reconstruction and
the use case ends without creating a ride.

**4a. The driver declines the offer.** The system discards the
collected samples and the use case ends without creating a ride.

**5a. The reconstruction cannot be recorded.** The system retains the
collected samples and lets the driver retry.


## Postconditions

a. Either a deferred, unverified ride exists with its reconstructed
   distance, duration, average speed, and earnings, or no ride is
   created.
b. A reconstructed ride is visible in the driver's ride history.
