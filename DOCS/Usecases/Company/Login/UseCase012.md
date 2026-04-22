# UC12: Company Login

**Addresses:** FR.3, NFR.1, NFR.2.

A registered company user authenticates into the web dashboard or
the mobile application.


## Actors
Company.


## Preconditions
- The user has previously registered as a company (per UC11).
- No session is currently active on the client.


## Basic Flow
1. The user taps **Log In** on the welcome screen of the web
   dashboard or the mobile application.
2. The system displays the login form (e-mail + password).
3. The user supplies credentials and submits.
4. The system verifies the credentials by comparing the BCrypt-hashed
   password (NFR.1).
5. On success the system issues a fresh authentication token with a
   lifetime bounded by **NFR.2** (at most one hour) and navigates the
   client to the company home dashboard.


## Alternative Flows

**4a. Credentials invalid.** The system displays a generic "e-mail or
password is incorrect" error and leaves the form ready for retry.

**5a. Forgot password.** The user taps **Forgot Password**; the
system sends a reset link and follows the password-reset flow.


## Postconditions
The user is authenticated and landed on the company home dashboard.
A fresh authentication token with a bounded lifetime is persisted on
the client.


## Design Notes
Google OAuth (FR.4) is not offered on the company login path because
the thesis limits OAuth to the mobile application's driver flow.
