## Use Case : Log a Ride with QR Code

**Actor:** Registered Car Owner  

**Description:** The user logs a ride by scanning a QR code that is on their car at the start and end of their journey. The app system then applies the ride to their campaign stats.  

**Preconditions:** 
- User is logged in 
- User is participating in an active campaign
- User is driving the car that has the ad on the car

**Flow:**
1. User is on the home screen and will start a new ride.
2. The system redirects user to QR code scanner page.
3. User scans the QR code from his car.
4. The system confirms that the ride has started and tracks duration  (and other metrics) in the background.
5. After driving, user returns to the app and ends the ride.
6. The user scans the QR code again.
7. The system calculates ride distance and time, then logs the ride.
8. Campaign statistics (e.g., km completed, earnings) are updated in real time.

**Postconditions**
- User has successfully completed a ride and they have come closer to earning money from the ad campaign
