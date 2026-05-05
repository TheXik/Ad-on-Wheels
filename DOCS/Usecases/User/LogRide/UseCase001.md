# UC01: Log a Ride with QR Verification

Logging a ride is the central use case of the platform. It addresses
requirements **FR.9**, **FR.10**, and the verification aspect of **FR.14**.


## Actors

Driver.


## Preconditions

a. The driver is signed in.
b. The driver has at least one accepted campaign.
c. The driver needs to record the kilometers driven so that they are
   credited toward their earnings.


## Basic Flow

1. The driver chooses to start a ride.
2. The system records the start of the ride and shows the driver the
   running ride status with the current speed and cumulative distance.
3. At the cadence required by **NFR.4**, the system records position
   samples and updates the running distance.
4. The driver chooses to end the ride.
5. The system computes the total distance, total duration, average
   speed, and earnings, and shows them to the driver.
6. The system asks the driver to scan the QR code on the vehicle.
7. The driver scans the QR code, and the system marks the ride as
   *verified*.


## Alternative Flows

**3a. Position is temporarily stale.** The system marks the live speed as
unavailable, retains the last known position, and resumes step 3 when a
new position is available.

**6a. The QR code is not immediately decoded.** The system continues
looking for a decodable code; once a code is read, the basic flow
continues at step 7.

**6b. The driver leaves the verification step without scanning.** The
system records the ride as *unverified*, and its earnings do not
contribute to the driver's cumulative totals. The driver can return
later and complete the scan to promote the ride to *verified*. The use
case ends.


## Postconditions

a. A ride is recorded with its position trace, total distance, total
   duration, average speed, earnings, and a verification status:
   *verified* if the QR scan completed, *unverified* otherwise.
b. The ride appears in the driver's ride history regardless of
   verification status.
c. The earnings of the ride contribute to the driver's cumulative totals
   only if the ride is verified.
