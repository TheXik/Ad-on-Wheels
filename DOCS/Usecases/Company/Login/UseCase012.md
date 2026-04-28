# UC12: Company Sign-In

A registered company user signs in to the web dashboard or the mobile
application. It addresses **FR.3**, **FR.4**, **NFR.1**, and **NFR.2**.


## Actors

Company user.


## Preconditions

a. The company user has previously registered as a company (per
   **UC11**).
b. No session is currently active on the client.
c. The company user needs to access the features of the company role.


## Basic Flow

1. The company user chooses to sign in.
2. The system asks the company user to provide credentials, either as
   e-mail and password or by signing in with Google (**FR.4**).
3. The company user provides the credentials.
4. The system verifies the credentials (against the stored hash for
   password sign-in, or by validating the returned identity token for
   Google sign-in) and issues an authentication token whose lifetime is
   bounded by **NFR.2**.
5. The system shows the company user the company home dashboard.


## Alternative Flows

**4a. The credentials are invalid.** The system tells the company user
the e-mail or password is incorrect and lets them retry.

**4b. The Google sign-in returns an e-mail registered under a different
role.** The system tells the company user the e-mail belongs to the
other role and does not sign them in.

**4c. The company user has forgotten their password.** The system sends
a password-reset link to the company user's e-mail address and the use
case ends.


## Postconditions

a. The company user is signed in and on the company home dashboard.
b. An authentication token with a bounded lifetime is on the client.
