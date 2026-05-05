# UC10: Driver Sign-In

A registered driver signs in to the mobile application. It addresses
**FR.3**, **FR.4**, **NFR.1**, and **NFR.2**.


## Actors

Driver.


## Preconditions

a. The driver has previously registered as a driver (per **UC09**).
b. No session is currently active on the device.
c. The driver needs to access the features of the driver role.


## Basic Flow

1. The driver chooses to sign in.
2. The system asks the driver to provide credentials, either as e-mail
   and password or by signing in with Google (**FR.4**).
3. The driver provides the credentials.
4. The system verifies the credentials (against the stored hash for
   password sign-in, or by validating the returned identity token for
   Google sign-in) and issues an authentication token whose lifetime is
   bounded by **NFR.2**.
5. The system shows the driver the driver home screen.


## Alternative Flows

**4a. The credentials are invalid.** The system tells the driver the
e-mail or password is incorrect and lets them retry.

**4b. The Google sign-in returns an e-mail that has no account yet.**
The system creates a driver account for the e-mail (per **FR.4**) and
the flow continues at step 5.


## Postconditions

a. The driver is signed in and on the driver home screen.
b. An authentication token with a bounded lifetime is on the device.
