# UC07: Review Driver Applications

Application review lets a company user staff one of its campaigns by
going through the applications drivers have submitted to it. It
addresses **FR.17** and **FR.18**, and it is the entry point into the
per-campaign messaging flow defined by **FR.21**.


## Actors

Company user.


## Preconditions

a. The company user is signed in.
b. The company owns at least one campaign.
c. The company user needs to choose which drivers to accept for one of
   their campaigns.


## Basic Flow

1. The company user chooses to review applications for one of their
   campaigns.
2. The system shows the campaign's applications, each with the driver's
   name and vehicle information (make, model, year).
3. For each pending application, the company user accepts or declines
   it.
4. On accept, the system marks the application as *accepted*, adds the
   driver to the campaign's participants, and declines any other
   still-pending applications by the same driver so that an accepted
   driver runs only one campaign at a time.
5. On decline, the system marks only the chosen application as
   *declined*.


## Alternative Flows

**2a. The campaign has no pending applications.** The system tells the
company user the application list is empty and offers to share the
campaign or edit its parameters.

**3a. The accept or decline cannot be recorded.** The system keeps the
application in its previous state and lets the company user retry.


## Postconditions

a. Every application the company user acted on is in the *accepted* or
   *declined* state.
b. Accepted drivers appear in the campaign's participants list and can
   exchange messages with the company within the context of that
   campaign.
c. No driver is accepted on more than one campaign at the same time.
