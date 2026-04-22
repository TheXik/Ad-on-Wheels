# UC04: View Driver Statistics and Earnings

**Addresses:** FR.13, FR.12.

A driver reviews their cumulative driving performance and earnings
across all campaigns they have participated in.


## Actors
Driver.


## Preconditions
- The driver is logged in.
- The driver has completed at least one ride (verified, unverified,
  or deferred).


## Basic Flow
1. The driver opens the **Stats** tab.
2. The system fetches the driver's ride history and computes the
   aggregate view:
    - Total number of completed rides.
    - Distance totals for the current week and current month.
    - Earnings breakdown (per campaign and overall).
    - Daily earnings chart covering a rolling window.
3. The system renders graphs and progress bars that illustrate
   progress toward the monthly distance goal shown on the home screen
   (per FR.12).
4. The driver optionally switches the time window (for example, to
   a previous month) or filters by a specific campaign to see
   historical breakdowns.


## Alternative Flows

**2a. No completed rides.** The system shows an empty state with an
explanation and a link to the Find Ad flow (UC02).

**3a. Data load fails.** The system surfaces the error and offers a
retry action; the previous cached values (if any) remain visible.


## Postconditions
The driver has a clear view of their progress and payout status. No
persistent state changes.
