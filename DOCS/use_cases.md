# Use Cases

This document collects every use case of the Ad-on-Wheels platform in one
place, written in the format taught by Martin Nečaský (NSWI041 lecture 04).
Every use case has six sections — **Title**, **Actors**, **Preconditions**,
**Basic Flow**, **Alternative Flows**, **Postconditions** — and the basic flow
alternates between actor and system steps without UI jargon.

The use case diagram is in [`diagrams/use-case-diagram.svg`](diagrams/use-case-diagram.svg).

The five use cases described in full in the thesis (UC01, UC02, UC07, UC09,
UC13) are reproduced verbatim from Chapter 1; the remaining eleven are
described here in the same format because the thesis cites the diagram for
them but does not detail them.


## UC01: Log a Ride with QR Verification

Logging a ride is the central use case of the platform. It addresses
requirements **FR.9**, **FR.10**, and the verification aspect of **FR.14**.

**Actors.** Driver.

**Preconditions.**
a. The driver is signed in.
b. The driver has at least one accepted campaign.
c. The driver needs to record the kilometers driven so that they are
   credited toward their earnings.

**Basic Flow.**
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

**Alternative Flows.**

- **3a. Position is temporarily stale.** The system marks the live
  speed as unavailable, retains the last known position, and resumes
  step 3 when a new position is available.
- **6a. The QR code is not immediately decoded.** The system continues
  looking for a decodable code; once a code is read, the basic flow
  continues at step 7.
- **6b. The driver leaves the verification step without scanning.**
  The system records the ride as *unverified*, and its earnings do not
  contribute to the driver's cumulative totals. The driver can return
  later and complete the scan to promote the ride to *verified*. The
  use case ends.

**Postconditions.**
a. A ride is recorded with its position trace, total distance, total
   duration, average speed, earnings, and a verification status:
   *verified* if the QR scan completed, *unverified* otherwise.
b. The ride appears in the driver's ride history regardless of
   verification status.
c. The earnings of the ride contribute to the driver's cumulative
   totals only if the ride is verified.


## UC02: Find an Advertisement

Through this use case a driver discovers and applies to campaigns that are
currently recruiting. It addresses **FR.7** and **FR.8**.

**Actors.** Driver.

**Preconditions.**
a. The driver is signed in.
b. The driver needs to find an advertising campaign to participate in.

**Basic Flow.**
1. The driver chooses to discover advertising campaigns.
2. The system shows the recruiting campaigns the driver has not yet
   applied to and has not skipped during this discovery session, one
   at a time, with the company name, campaign name, date range,
   per-kilometer rate, maximum number of drivers, and a short
   description.
3. For each campaign the driver chooses to apply, to skip, or to view
   its details.
4. After each choice, the system advances to the next campaign.
5. When no further recruiting campaigns are available, the system
   tells the driver and offers to refresh the list.

**Alternative Flows.**

- **3a. The driver reverses the most recent skip.** The system
  restores the just-skipped campaign and offers it to the driver again.
  The basic flow continues at step 3 with the restored campaign.
- **3b. The driver has an accepted campaign.** The system rejects the
  application and tells the driver they cannot run two campaigns at
  once. The basic flow continues at step 4.
- **3c. The application cannot be submitted for any other reason.**
  The system tells the driver the application failed. The basic flow
  continues at step 3 with the same campaign so the driver can retry.

**Postconditions.**
a. Every campaign the driver applied to during the session is
   recorded as an application with status *applied*.
b. Skipped campaigns are not offered again during the same discovery
   session unless the skip is reversed.


## UC03: Inspect Campaign Details

A driver opens a campaign for full details, either one they are already
participating in or one they are evaluating from the discovery flow
(**UC02**). It addresses **FR.8** and **FR.12**.

**Actors.** Driver.

**Preconditions.**
a. The driver is signed in.
b. The campaign exists and is visible to the driver — currently
   recruiting, or one the driver has applied to or been accepted for.
c. The driver needs full information about the campaign before
   committing to it or while participating in it.

**Basic Flow.**
1. The driver chooses to open a campaign for details, either from the
   home screen, from the discovery flow (**UC02**), or from the
   applications list.
2. The system shows the campaign's full details: company name,
   campaign name, date range, total budget, per-kilometer rate,
   maximum number of drivers, estimated audience reach, description,
   and any uploaded images, together with the driver's own application
   status if one exists.
3. The driver reviews the information.
4. The driver chooses to close the detail view, to apply (if not yet
   applied), to start a ride (**UC01**, if accepted and eligible), or
   to open the messaging thread with the company (**UC05**, if
   accepted).

**Alternative Flows.**

- **2a. The campaign has been withdrawn since the driver opened it.**
  The system tells the driver the campaign is no longer recruiting and
  disables the apply action.

**Postconditions.**
a. The driver has full information about the campaign's parameters.
b. No persistent state changes unless the driver triggers a follow-up
   action, in which case the corresponding use case (**UC02**,
   **UC01**, or **UC05**) applies.


## UC04: View Driver Statistics and Earnings

A driver reviews their cumulative driving performance and earnings across
all campaigns they have participated in. It addresses **FR.12** and **FR.13**.

**Actors.** Driver.

**Preconditions.**
a. The driver is signed in.
b. The driver has completed at least one ride (verified, unverified,
   or deferred).
c. The driver needs to see how many kilometers they have driven and
   how much they have earned.

**Basic Flow.**
1. The driver chooses to open the statistics view.
2. The system computes the driver's aggregate statistics: total number
   of completed rides, distance totals for the current week and
   current month, earnings totals for the current week and current
   month, and a daily earnings chart.
3. The system shows the statistics together with a progress indicator
   toward the driver's monthly distance goal that the home screen also
   surfaces.
4. The driver chooses to switch the displayed period between week and
   month, or to close the view.

**Alternative Flows.**

- **2a. The driver has no completed rides.** The system tells the
  driver the statistics view is empty and offers to open the discovery
  flow (**UC02**).
- **2b. The statistics cannot be computed.** The system tells the
  driver the request failed and lets them retry; previously cached
  values, if any, remain visible.

**Postconditions.**
a. The driver has a clear view of their cumulative progress and
   payout status.
b. No persistent state changes.


## UC05: Exchange Messages with a Company

A driver and a company exchange text messages within the context of a
specific campaign. From the driver's perspective, this use case covers
reading messages received from companies and sending replies. It addresses
**FR.23**, **FR.24**, and **FR.25**, and complements **FR.19** on the
company side (**UC07**).

**Actors.** Driver (primary). Company (secondary, initiates messages per
**FR.19**).

**Preconditions.**
a. The driver is signed in.
b. The driver has at least one campaign with *accepted* application
   status; messaging is only available in the context of an accepted
   campaign.
c. The driver needs to read or send messages to the company that
   accepted them.

**Basic Flow.**
1. The driver chooses to open the inbox; the system shows the
   unread-count badge per **FR.24**.
2. The system shows the driver's per-campaign message threads, each
   marked as read or unread.
3. The driver chooses a thread to open.
4. The system marks all messages in that thread as read and shows the
   full chronological conversation.
5. The driver chooses to reply or to close the thread.
6. On reply, the system records the new message under the same
   campaign context and shows it in the conversation.

**Alternative Flows.**

- **2a. The driver has no message threads yet.** The system tells the
  driver the inbox is empty.
- **6a. The reply cannot be sent.** The system tells the driver the
  message failed and keeps the draft visible so the driver can retry.

**Postconditions.**
a. Messages opened by the driver are marked as read.
b. Any reply submitted during the session is recorded and the
   per-campaign message history reflects the new entry.


## UC06: View Active or Past Campaigns

A company user browses the company's own campaigns (recruiting, active, or
completed) and opens any of them for details. It addresses **FR.17** and
**FR.20**.

**Actors.** Company user.

**Preconditions.**
a. The company user is signed in.
b. The company user needs to see how their campaigns are performing.

**Basic Flow.**
1. The company user chooses to open the list of the company's
   campaigns.
2. The system shows the campaigns grouped or filterable by state
   (recruiting, active, completed).
3. The company user chooses a campaign.
4. The system shows the campaign's detail view: description, date
   range, budget, per-kilometer rate, participants list, and current
   per-campaign metrics (drivers accepted, kilometers driven,
   completed rides, unread messages).

**Alternative Flows.**

- **2a. The company has no campaigns yet.** The system tells the
  company user the list is empty and offers to create the first
  campaign (**FR.16**).

**Postconditions.**
a. The company user has seen the campaign's current performance data.
b. No persistent state changes unless the company user triggers a
   follow-up action (review applications per **UC07**, export
   statistics per **UC08**, or send a message per **FR.19**).


## UC07: Review Driver Applications

Application review lets a company user staff one of its campaigns by going
through the applications drivers have submitted to it. It addresses
**FR.18** and **FR.19**, and it is the entry point into the per-campaign
messaging flow defined by **FR.23**.

**Actors.** Company user.

**Preconditions.**
a. The company user is signed in.
b. The company owns at least one campaign.
c. The company user needs to choose which drivers to accept for one
   of their campaigns.

**Basic Flow.**
1. The company user chooses to review applications for one of their
   campaigns.
2. The system shows the campaign's applications, each with the
   driver's name and vehicle information (make, model, year).
3. For each pending application, the company user accepts or declines
   it.
4. On accept, the system marks the application as *accepted*, adds
   the driver to the campaign's participants, and declines any other
   still-pending applications by the same driver so that an accepted
   driver runs only one campaign at a time.
5. On decline, the system marks only the chosen application as
   *declined*.

**Alternative Flows.**

- **2a. The campaign has no pending applications.** The system tells
  the company user the application list is empty and offers to share
  the campaign or edit its parameters. The use case ends.
- **3a. The accept or decline cannot be recorded.** The system keeps
  the application in its previous state. The basic flow continues at
  step 3 so the company user can retry.
- **4a. The campaign passes its end date while accepted drivers still
  hold accepted applications.** A scheduled task transitions every
  *accepted* application on the now-ended campaign to *expired*,
  releasing each driver from the cooperation so that they become
  eligible to apply to another campaign. The transition is automatic
  and requires no company-user action; expired applications remain
  visible in the company's per-campaign view, distinguished from
  currently-accepted ones, so the historical roster of who drove for
  the campaign is preserved.

**Postconditions.**
a. Every application the company user acted on is in the *accepted*
   or *declined* state, or, if its parent campaign has since passed
   its end date, the *expired* state.
b. Accepted drivers appear in the campaign's participants list and
   can exchange messages with the company within the context of that
   campaign.
c. No driver is accepted on more than one campaign at the same time,
   and a driver whose previously accepted campaign has expired is
   once again eligible to apply elsewhere.


## UC08: Export Campaign Statistics

A company user exports campaign statistics as a downloadable file for
offline analysis and reporting, either for a single campaign or across all
campaigns of the company. It addresses **FR.21** and **C.3**.

**Actors.** Company user.

**Preconditions.**
a. The company user is signed in.
b. The company has at least one campaign with recorded activity
   (drivers, rides, or applications).
c. The company user needs to share the campaign performance data
   outside the platform.

**Basic Flow.**
1. The company user chooses to export campaign statistics.
2. The system asks the company user to choose the export scope: a
   single campaign or all campaigns of the company.
3. The company user chooses the scope.
4. The system generates the export file containing the campaign
   metrics (name, state, date range, budget, drivers accepted,
   kilometers driven, completed rides, earnings disbursed) in a format
   openable in standard spreadsheet software (per **C.3**).
5. The system delivers the file to the company user's device.

**Alternative Flows.**

- **2a. There is no data to export for the chosen scope.** The system
  tells the company user no data is available and does not generate a
  file.
- **4a. The export cannot be generated.** The system tells the
  company user the export failed and lets them retry. No file is
  delivered.

**Postconditions.**
a. A spreadsheet-openable export of the chosen scope is on the
   company user's device, or no file has been delivered if the export
   was declined or failed.
b. No persistent state changes on the platform.


## UC09: User Registration

Registration is the entry point for every new user. It addresses **FR.1**,
**FR.2**, **FR.3**, **FR.4**, and the compensating behaviour mandated by
**FR.5**.

**Actors.** Unregistered User.

**Preconditions.**
a. The user does not have an existing account on the platform.
b. The user needs an account to access the features of their chosen
   role.

**Basic Flow.**
1. The user chooses to register as a driver or as a company.
2. The system asks for the role-specific information: for a driver,
   name, e-mail, and password; for a company, company name, contact
   name, e-mail, and password.
3. The user submits the information.
4. The system verifies that the e-mail is not already in use under
   any role, records the credentials in non-reversible form, creates
   the corresponding profile, and signs the user in.
5. A driver registering from a mobile device additionally provides
   vehicle information (make, model, year, licence plate), a photo of
   the vehicle decal, and a monthly distance goal.
6. The system records the onboarding information and shows the user
   the interface for their role.

**Alternative Flows.**

- **2a. The user signs in with an external identity provider, and
  the returned e-mail is not yet registered.** The system creates a
  new account under the chosen role, signs the user in, and the flow
  continues at step 5.
- **2b. The user signs in with an external identity provider, and
  the returned e-mail is already registered under the same role.**
  The system signs the user in. The use case ends.
- **2c. The user signs in with an external identity provider, and
  the returned e-mail is already registered under a different role.**
  The system tells the user the e-mail belongs to the other role and
  offers to sign them in as that role instead. The use case ends.
- **4a. The e-mail is already in use under the same role.** The
  system rejects the submission and offers to sign the user in
  instead. The use case ends.
- **4b. The e-mail is already in use under a different role.** The
  system rejects the submission and tells the user which role the
  e-mail belongs to. The use case ends.
- **4c. The credentials cannot be recorded after the profile has
  been created.** The system removes the just-created profile, tells
  the user the registration failed, and invites them to retry. The
  use case ends.
- **5a. The driver leaves onboarding before completing it.** The
  system discards the partially-entered onboarding state when the
  application is backgrounded or terminated, and presents the wizard
  from its first step on the next sign-in. The driver account already
  exists at this point (it was created in step 4 of the basic flow),
  so re-entering the wizard does not require re-registering
  credentials, only the vehicle and goal information that the driver
  did not finish entering. The use case ends.

**Postconditions.**
a. An account exists for the user with credentials and a matching
   profile.
b. The user is signed in to the interface for their role.
c. A driver registered from a mobile device has either completed the
   onboarding wizard or will be presented with it again on the next
   sign-in.


## UC10: Driver Sign-In

A registered driver signs in to the mobile application. It addresses
**FR.3**, **FR.4**, **NFR.1**, and **NFR.2**.

**Actors.** Driver.

**Preconditions.**
a. The driver has previously registered as a driver (per **UC09**).
b. No session is currently active on the device.
c. The driver needs to access the features of the driver role.

**Basic Flow.**
1. The driver chooses to sign in.
2. The system asks the driver to provide credentials, either as
   e-mail and password or by signing in with Google (**FR.4**).
3. The driver provides the credentials.
4. The system verifies the credentials (against the stored hash for
   password sign-in, or by validating the returned identity token for
   Google sign-in) and issues an authentication token whose lifetime
   is bounded by **NFR.2**.
5. The system shows the driver the driver home screen.

**Alternative Flows.**

- **4a. The credentials are invalid.** The system tells the driver
  the e-mail or password is incorrect and lets them retry.
- **4b. The Google sign-in returns an e-mail that has no account
  yet.** The system creates a driver account for the e-mail (per
  **FR.4**) and the flow continues at step 5.

**Postconditions.**
a. The driver is signed in and on the driver home screen.
b. An authentication token with a bounded lifetime is on the device.


## UC11: View Ride Route

A driver opens any of their completed rides and sees the route as a polyline
on a map. It addresses **FR.15**.

**Actors.** Driver.

**Preconditions.**
a. The driver is signed in.
b. The driver has at least one completed ride (verified, unverified, or
   deferred) with a recorded position trace.
c. The driver needs to inspect the geographic path of a past ride.

**Basic Flow.**
1. The driver chooses a completed ride from the ride history.
2. The system retrieves the position trace recorded for that ride.
3. The system renders the trace as a polyline on a map, fits the map's
   viewport to the trace bounds, and shows the ride's headline metrics
   (distance, duration, average speed, earnings, verification status)
   alongside the map.
4. The driver chooses to close the route view or to return to the ride
   list.

**Alternative Flows.**

- **2a. The ride has no recorded position trace** (a deferred ride
  reconstructed from too few samples, or a ride for which the device
  produced no usable points). The system tells the driver the route
  cannot be drawn and shows the headline metrics only.
- **3a. The trace cannot be fetched.** The system tells the driver the
  request failed and offers to retry; previously cached values, if any,
  remain visible.

**Postconditions.**
a. The driver has seen the geographic path the system recorded for the
   chosen ride.
b. No persistent state changes.


## UC12: Company Registration

A new company user creates a company account on the platform. Registration
can start either from the web dashboard, which goes directly to the company
form per **FR.1**, or from the mobile application after the user chooses the
company role on the landing screen. It addresses **FR.1**, **FR.2**,
**FR.3**, **FR.4**, and **FR.5**.

This use case is a specialisation of **UC09** for the company role; it is
described separately because the entry point and the post-sign-in
destination differ from the driver flow.

**Actors.** Unregistered User.

**Preconditions.**
a. The user does not have an existing account on the platform.
b. The user needs a company account to create and manage campaigns.

**Basic Flow.**
1. The user chooses to register as a company, either from the web
   dashboard's landing screen or from the mobile application's role
   picker.
2. The system asks for the company information: company name, contact
   name, e-mail, and password.
3. The user submits the information.
4. The system verifies that the e-mail is not already in use under
   any role, records the credentials in non-reversible form, creates
   the company profile, and signs the user in.
5. The system shows the user the company home dashboard.

**Alternative Flows.**

- **3a. The user signs in with Google.** The system creates the
  company account from the returned identity token (per **FR.4**) and
  the flow continues at step 5.
- **4a. The e-mail is already in use under the same role.** The
  system rejects the submission and offers to sign the user in
  instead.
- **4b. The e-mail is already in use under a different role.** The
  system rejects the submission and tells the user which role the
  e-mail belongs to.
- **4c. The credentials cannot be recorded after the company profile
  has been created.** The system removes the just-created profile,
  tells the user the registration failed, and invites them to retry.

**Postconditions.**
a. A company account exists with credentials and a matching company
   profile.
b. The user is signed in to the company home dashboard.


## UC14: Create Campaign

A company user creates a new advertising campaign with all the parameters
that drivers see when discovering it and that the platform uses to compute
payouts and capacity. It addresses **FR.16**.

**Actors.** Company user.

**Preconditions.**
a. The company user is signed in.
b. The company has been created (per **UC12**).
c. The company user needs to recruit drivers and run a new advertising
   campaign.

**Basic Flow.**
1. The company user chooses to create a campaign.
2. The system asks for the campaign parameters: name, description, start
   date, end date, total budget, per-kilometer driver payout rate, and
   maximum number of participating drivers.
3. The company user submits the parameters and may optionally attach an
   estimated audience reach value and one or more visual assets
   (campaign images).
4. The system validates the parameters (start date before end date,
   non-negative budget and rate, positive maximum drivers) and creates
   the campaign in the *recruiting* state.
5. The system shows the company user the new campaign's detail view.

**Alternative Flows.**

- **3a. The company user provides invalid parameters.** The system
  highlights the invalid fields and prevents submission until they are
  corrected.
- **3b. The company user attaches more images than the platform
  accepts** (limit per **FR.16** policy). The system rejects the excess
  images and asks the company user to remove some.
- **4a. The campaign cannot be created.** The system tells the company
  user the operation failed and offers to retry; submitted parameters
  remain in the form.

**Postconditions.**
a. A new campaign exists, owned by the company, in the *recruiting*
   state, with the submitted parameters and any uploaded images.
b. Drivers can discover the campaign through **UC02**.


## UC15: View Campaign Coverage

A company user opens any of their campaigns and sees a coverage map that
overlays the routes of every completed ride contributed by accepted drivers.
It addresses **FR.22**.

**Actors.** Company user.

**Preconditions.**
a. The company user is signed in.
b. The campaign exists, belongs to the company, and has at least one
   accepted driver who has completed at least one ride with a recorded
   position trace.
c. The company user needs to see the geographic distribution of the
   campaign's exposure.

**Basic Flow.**
1. The company user chooses to open the coverage map for one of the
   company's campaigns.
2. The system retrieves the position traces of every completed ride
   recorded against that campaign.
3. The system renders all traces on a single map, distinguishing
   verified rides (solid polyline) from unverified rides (dashed
   polyline), and fits the viewport to the union of the trace bounds.
4. The company user reviews the map and may toggle between showing
   verified rides only and showing all rides.

**Alternative Flows.**

- **2a. The campaign has no completed rides yet.** The system tells the
  company user the coverage map is empty and offers to open the
  application list (**UC07**) or the campaign details (**UC06**).
- **3a. The traces cannot be fetched.** The system tells the company
  user the request failed and offers to retry; previously cached
  traces, if any, remain visible.

**Postconditions.**
a. The company user has seen the geographic distribution of every
   completed ride contributed to the campaign.
b. No persistent state changes.


## UC16: Company Sign-In

A registered company user signs in to the web dashboard or the mobile
application. It addresses **FR.3**, **FR.4**, **NFR.1**, and **NFR.2**.

**Actors.** Company user.

**Preconditions.**
a. The company user has previously registered as a company (per
   **UC12**).
b. No session is currently active on the client.
c. The company user needs to access the features of the company role.

**Basic Flow.**
1. The company user chooses to sign in.
2. The system asks the company user to provide credentials, either as
   e-mail and password or by signing in with Google (**FR.4**).
3. The company user provides the credentials.
4. The system verifies the credentials (against the stored hash for
   password sign-in, or by validating the returned identity token for
   Google sign-in) and issues an authentication token whose lifetime
   is bounded by **NFR.2**.
5. The system shows the company user the company home dashboard.

**Alternative Flows.**

- **4a. The credentials are invalid.** The system tells the company
  user the e-mail or password is incorrect and lets them retry.
- **4b. The Google sign-in returns an e-mail registered under a
  different role.** The system tells the company user the e-mail
  belongs to the other role and does not sign them in.

**Postconditions.**
a. The company user is signed in and on the company home dashboard.
b. An authentication token with a bounded lifetime is on the client.


## UC13: Deferred Ride Reconstruction

Deferred reconstruction is the fallback path to **UC01**. It lets a driver
who drove with an advertisement mounted but forgot to start a ride through
the application recover the drive retroactively. It addresses **FR.11** and
extends **UC01** as an alternative ride-creation path.

**Actors.** Driver.

**Preconditions.**
a. The driver is signed in.
b. The driver has at least one accepted campaign.
c. No active ride exists for this driver.
d. The driver needs to record a drive they did not start through
   **UC01** so that the kilometers are credited toward their earnings.

**Basic Flow.**
1. While the driver has an accepted campaign but no active ride, the
   system collects position samples in the background.
2. The driver chooses the QR verification step without having started
   a ride.
3. The system detects no active ride and offers to reconstruct the
   recent drive as a deferred ride.
4. The driver confirms.
5. The system computes the distance, duration, average speed, and
   earnings of the reconstructed drive, and records it as a deferred,
   unverified ride.
6. The system shows the reconstructed totals to the driver and enters
   the ride into the driver's ride history.

**Alternative Flows.**

- **3a. The system has not collected enough position samples to
  reconstruct a drive.** The system does not offer the reconstruction
  and the use case ends without creating a ride.
- **4a. The driver declines the offer.** The system discards the
  collected samples and the use case ends without creating a ride.
- **5a. The reconstruction cannot be recorded.** The system retains
  the collected samples. The basic flow continues at step 4 so the
  driver can retry.

**Postconditions.**
a. Either a deferred, unverified ride exists with its reconstructed
   distance, duration, average speed, and earnings, or no ride is
   created.
b. A reconstructed ride is visible in the driver's ride history.
