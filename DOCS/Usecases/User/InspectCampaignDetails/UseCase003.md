# UC03: Inspect Campaign Details

**Addresses:** FR.8, FR.12.

A driver views the full details of a campaign - either a campaign they
are already participating in, or one they are evaluating from the
discovery flow (UC02).


## Actors
Driver.


## Preconditions
- The driver is logged in.
- The campaign exists and is visible to the driver (currently
  recruiting, or one the driver has applied to / been accepted for).


## Basic Flow
1. The driver reaches the campaign detail screen via one of:
    - Tapping the active-campaign summary card on the home screen.
    - Tapping **Details** on a campaign shown in the discovery flow
      (UC02).
    - Opening a campaign from the applications list.
2. The system loads the campaign record and displays its full
   details: company, description, date range, reward model, budget,
   maximum number of drivers, estimated audience reach, optional
   images, and the driver's own application status with respect to
   the campaign (`pending`, `accepted`, `declined`, or *not applied*).
3. The driver reviews the information and optionally initiates a
   follow-up action:
    - Apply to the campaign (if not yet applied and the campaign is
      recruiting).
    - Start a ride (UC01), if accepted and eligible.
    - Open the messaging thread with the company (UC05), if accepted.
4. The driver closes the detail view.


## Alternative Flows

**2a. Campaign no longer available.** If the campaign has been
withdrawn by the company, the system shows a disabled state with a
message indicating the campaign is no longer recruiting.


## Postconditions
The driver has complete information about the campaign's requirements
and conditions. No persistent state changes unless the driver takes a
follow-up action, in which case the corresponding use case (UC02, UC01,
or UC05) applies.
