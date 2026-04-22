# UC09: User Registration (Driver)

**Addresses:** FR.1, FR.2, FR.3, FR.4, FR.5.

An unregistered user creates a driver account on the mobile client.


## Actors
Unregistered User.


## Preconditions
- The user has installed and opened the mobile application.
- No session is active on the device (the landing screen is shown).


## Basic Flow
1. The user taps **Sign Up** on the welcome screen.
2. The mobile application displays the role picker (per FR.1) with
   two options: **Driver** and **Company**.
3. The user selects **Driver**.
4. The system displays the driver registration form asking for name,
   e-mail, and password - or, alternatively, offers **Sign in with
   Google** (per FR.4).
5. The user fills in the required fields (or authenticates through
   Google) and submits.
6. The system validates input format (e-mail syntax, password
   strength).
7. The system checks that no other account exists with the same
   e-mail (FR.2).
8. The system creates the authentication record (with the password
   stored only in hashed form, per FR.3 / NFR.1) and a driver profile
   record matching the chosen role. If Google OAuth was used, the
   account is created automatically without a password (FR.4).
9. The system issues an authentication token (lifetime bounded by
   **NFR.2**, at most one hour) and navigates the client to the
   driver onboarding wizard (vehicle info, per FR.6).
10. The user completes the onboarding wizard and confirms.
11. The system saves the vehicle details and navigates the user to
    the driver home screen.


## Alternative Flows

**6a. Invalid input.** The system highlights invalid fields and
prevents submission until corrected.

**7a. E-mail already registered.** The system shows "E-mail already
in use" and offers a link to the Login flow (UC10).

**8a. Registration fails partway through.** The system executes
compensating actions (per **FR.5**) that undo any already-completed
registration steps (authentication record, profile record, onboarding
data), so no orphaned partial record remains. The user is returned to
the registration form with a retry-safe state.


## Postconditions
A new driver account (authentication record + driver profile +
optional vehicle info) is created. The user is authenticated and
landed on the driver home screen. An authentication token with a
bounded lifetime is persisted on the device.
