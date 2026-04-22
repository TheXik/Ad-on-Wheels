# UC02: Find an Advertisement

**Addresses:** FR.7, FR.8.

A driver browses the set of currently recruiting campaigns and acts on
each one individually.


## Actors
Driver.


## Preconditions
- The driver is logged in.
- The driver has completed onboarding (vehicle info supplied per FR.6).


## Basic Flow
1. The driver navigates to the **Find Ad** screen.
2. The system fetches the list of currently recruiting campaigns and
   presents one campaign at a time, with enough information for the
   driver to make a decision (name, company, reward model, duration,
   required vehicle type).
3. The driver performs one of the following actions on the current
   campaign:
    - **Affirmative gesture** - submit an application to the current
      campaign (a single gesture, per FR.7).
    - **Dismissive gesture** - skip to the next campaign (a single
      gesture, per FR.7).
    - **Open for details** - open the current campaign's detail page
      (UC03).
    - **Reverse last action** - restore a skipped campaign or
      withdraw a just-submitted application.
4. Steps 2–3 repeat until no further recruiting campaigns are
   available.
5. When the list is exhausted, the system indicates this to the driver
   and offers a way to refresh the list.


## Alternative Flows

**2a. No recruiting campaigns available.** The system displays a
message informing the driver and offers a refresh action.

**3a. Application submission fails.** The previous state is preserved
and the system surfaces an error; the campaign remains available to
retry.


## Postconditions
For each affirmative gesture, a new application is persisted with
status `pending` and becomes visible to the target company under UC07.
Skipped campaigns are not re-presented in the current session.


## Design Notes
The specific interaction style (swipeable cards, paginated list, or
another pattern) is a design decision. The thesis favours a swipe-card
pattern for consumer fit, but the requirement is only that the
affirmative and dismissive actions each be a *single* gesture.
