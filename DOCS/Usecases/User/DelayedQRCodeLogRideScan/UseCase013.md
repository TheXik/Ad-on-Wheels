## Use Case: Deferred QR Scan to End Ride

**Actor:** Registered Car Owner

**Description:** The user forgot to scan the QR at ride start; at ride end they scan once and the app uses background‐tracked GPS data as the start.

**Preconditions:**
- User is logged in and in an active campaign
- App has been running background GPS & distance tracking since the drive began

**Flow:**
1. User returns to the app and taps **End Ride**.
2. The System opens the QR scanner.
3. User scans the QR code on the car.
4. The System detects no prior “start” scan, and prompts:  
   “No start scan found. Use tracked GPS data as ride start?”
5. User confirms.
6. The System calculates distance/time from the background GPS log, logs the ride, and updates campaign stats.

**Postconditions:**
- Ride is recorded using deferred start data.
- Campaign mileage and earnings counters update accordingly.  
