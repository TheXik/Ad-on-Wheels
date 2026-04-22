# UC10: User Login (Driver)

**Addresses:** FR.3, FR.4, NFR.1, NFR.2.

A registered driver authenticates into the mobile application.


## Actors
Driver.


## Preconditions
- The user has previously registered as a driver (per UC09).
- No session is currently active on the device.


## Basic Flow
1. The user taps **Log In** on the welcome screen.
2. The system displays the login form, offering:
    - E-mail and password fields (per FR.3).
    - **Sign in with Google** (per FR.4).
3. The user supplies credentials (or completes the Google OAuth
   flow) and submits.
4. The system verifies the credentials: for password authentication,
   by comparing the BCrypt-hashed password (NFR.1); for Google OAuth,
   by verifying the returned ID token.
5. On success the system issues a fresh authentication token with a
   lifetime bounded by **NFR.2** (at most one hour) and navigates the
   client to the driver home screen.


## Alternative Flows

**4a. Credentials invalid.** The system displays a generic "e-mail or
password is incorrect" error and leaves the form ready for retry.

**4b. Google OAuth returns an e-mail that has no account yet.** The
system auto-provisions a driver account per FR.4 and continues with
step 5.

**5a. Forgot password.** The user taps **Forgot Password**; the
system sends a reset link and follows the password-reset flow.


## Postconditions
The user is authenticated and landed on the driver home screen. A
fresh authentication token with a bounded lifetime is persisted on
the device.
