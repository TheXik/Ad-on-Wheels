# UC09: User Registration

Registration is the entry point for every new user. It addresses
**FR.1**, **FR.2**, **FR.3**, **FR.4**, and the compensating behaviour
mandated by **FR.5**.


## Actors

Unregistered User.


## Preconditions

a. The user does not have an existing account on the platform.
b. The user needs an account to access the features of their chosen role.


## Basic Flow

1. The user chooses to register as a driver or as a company.
2. The system asks for the role-specific information: for a driver, name,
   e-mail, and password; for a company, company name, contact name,
   e-mail, and password.
3. The user submits the information.
4. The system verifies that the e-mail is not already in use under any
   role, records the credentials in non-reversible form, creates the
   corresponding profile, and signs the user in.
5. A driver registering from a mobile device additionally provides
   vehicle information (make, model, year, licence plate), a photo of
   the vehicle decal, and a monthly distance goal.
6. The system records the onboarding information and shows the user the
   interface for their role.


## Alternative Flows

**2a. The user signs in with an external identity provider, and the
returned e-mail is not yet registered.** The system creates a new account
under the chosen role, signs the user in, and the flow continues at
step 5.

**2b. The user signs in with an external identity provider, and the
returned e-mail is already registered under the same role.** The system
signs the user in. The use case ends.

**2c. The user signs in with an external identity provider, and the
returned e-mail is already registered under a different role.** The
system tells the user the e-mail belongs to the other role and offers to
sign them in as that role instead. The use case ends.

**4a. The e-mail is already in use under the same role.** The system
rejects the submission and offers to sign the user in instead. The use
case ends.

**4b. The e-mail is already in use under a different role.** The system
rejects the submission and tells the user which role the e-mail belongs
to. The use case ends.

**4c. The credentials cannot be recorded after the profile has been
created.** The system removes the just-created profile, tells the user
the registration failed, and invites them to retry. The use case ends.

**5a. The driver leaves onboarding before completing it.** The system
discards the partially-entered onboarding state when the application is
backgrounded or terminated, and presents the wizard from its first step
on the next sign-in. The driver account already exists at this point (it
was created in step 4 of the basic flow), so re-entering the wizard does
not require re-registering credentials, only the vehicle and goal
information that the driver did not finish entering. The use case ends.


## Postconditions

a. An account exists for the user with credentials and a matching
   profile.
b. The user is signed in to the interface for their role.
c. A driver registered from a mobile device has either completed the
   onboarding wizard or will be presented with it again on the next
   sign-in.
