# UC11: Company Registration

A new company user creates a company account on the platform.
Registration can start either from the web dashboard, which goes
directly to the company form per **FR.1**, or from the mobile
application after the user chooses the company role on the landing
screen. It addresses **FR.1**, **FR.2**, **FR.3**, **FR.4**, and **FR.5**.

This use case is a specialisation of **UC09** for the company role; it
is described separately because the entry point and the post-sign-in
destination differ from the driver flow.


## Actors

Unregistered User.


## Preconditions

a. The user does not have an existing account on the platform.
b. The user needs a company account to create and manage campaigns.


## Basic Flow

1. The user chooses to register as a company, either from the web
   dashboard's landing screen or from the mobile application's role
   picker.
2. The system asks for the company information: company name, contact
   name, e-mail, and password.
3. The user submits the information.
4. The system verifies that the e-mail is not already in use under any
   role, records the credentials in non-reversible form, creates the
   company profile, and signs the user in.
5. The system shows the user the company home dashboard.


## Alternative Flows

**3a. The user signs in with Google.** The system creates the company
account from the returned identity token (per **FR.4**) and the flow
continues at step 5.

**4a. The e-mail is already in use under the same role.** The system
rejects the submission and offers to sign the user in instead.

**4b. The e-mail is already in use under a different role.** The system
rejects the submission and tells the user which role the e-mail
belongs to.

**4c. The credentials cannot be recorded after the company profile has
been created.** The system removes the just-created profile, tells the
user the registration failed, and invites them to retry.


## Postconditions

a. A company account exists with credentials and a matching company
   profile.
b. The user is signed in to the company home dashboard.
