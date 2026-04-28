# UC04: View Driver Statistics and Earnings

A driver reviews their cumulative driving performance and earnings
across all campaigns they have participated in. It addresses **FR.12**
and **FR.13**.


## Actors

Driver.


## Preconditions

a. The driver is signed in.
b. The driver has completed at least one ride (verified, unverified, or
   deferred).
c. The driver needs to see how many kilometers they have driven and how
   much they have earned.


## Basic Flow

1. The driver chooses to open the statistics view.
2. The system computes the driver's aggregate statistics: total number
   of completed rides, distance totals for the current week and current
   month, earnings totals for the current week and current month, and a
   daily earnings chart.
3. The system shows the statistics together with a progress indicator
   toward the driver's monthly distance goal that the home screen also
   surfaces.
4. The driver chooses to switch the displayed period between week and
   month, or to close the view.


## Alternative Flows

**2a. The driver has no completed rides.** The system tells the driver
the statistics view is empty and offers to open the discovery flow
(**UC02**).

**2b. The statistics cannot be computed.** The system tells the driver
the request failed and lets them retry; previously cached values, if
any, remain visible.


## Postconditions

a. The driver has a clear view of their cumulative progress and payout
   status.
b. No persistent state changes.
