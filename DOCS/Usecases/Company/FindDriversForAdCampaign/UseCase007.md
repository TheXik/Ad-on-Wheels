# UC07: Review Driver Applications

**Addresses:** FR.17, FR.18.

A company user lists the pending driver applications for any of the
company's campaigns and accepts or declines each one individually. An
accepted driver appears in the campaign's participant list and becomes
eligible to exchange messages with the company in the context of that
campaign (per UC05 / FR.21).


## Actors
Company.


## Preconditions
- The user is logged in with a Company account.
- The company has at least one campaign.


## Basic Flow
1. The user navigates to the **Find Drivers** screen.
2. The system fetches the company's campaigns that have at least one
   pending application.
3. The user selects a campaign.
4. The system loads the pending applications for that campaign and
   displays, for each application, the driver's name, vehicle
   information, and rating.
5. The user optionally applies filters (vehicle type, rating,
   location) or sorting.
6. The user selects a single application to review; the system shows
   the driver's full profile (compliance history, projected reach).
7. The user taps **Accept** or **Decline** on the application.
8. The system persists the decision, updates the campaign's
   participant list (on accept) or application log (on decline), and
   decrements the remaining-driver-slots counter on accept.
9. Steps 6–8 repeat until the user finishes the review session.


## Alternative Flows

**2a. No campaigns with pending applications.** The system shows
"No recruiting campaigns available" and offers a shortcut to create a
new campaign (FR.15).

**4a. No applications yet for the selected campaign.** The system
shows an empty state with a **Share Campaign** action.

**8a. Accept or decline request fails.** The platform preserves the
previous state (the application remains `pending`) and surfaces an
error to the user. The remaining-driver-slots counter is not changed.


## Postconditions
Each processed application is persisted with its new status
(`accepted` or `declined`). Accepted drivers are added to the
campaign's participant list and become eligible for messaging (UC05)
and for counting toward the campaign's participant cap.
