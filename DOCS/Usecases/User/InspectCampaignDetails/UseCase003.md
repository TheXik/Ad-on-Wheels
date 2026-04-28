# UC03: Inspect Campaign Details

A driver opens a campaign for full details, either one they are already
participating in or one they are evaluating from the discovery flow
(**UC02**). It addresses **FR.8** and **FR.12**.


## Actors

Driver.


## Preconditions

a. The driver is signed in.
b. The campaign exists and is visible to the driver — currently
   recruiting, or one the driver has applied to or been accepted for.
c. The driver needs full information about the campaign before
   committing to it or while participating in it.


## Basic Flow

1. The driver chooses to open a campaign for details, either from the
   home screen, from the discovery flow (**UC02**), or from the
   applications list.
2. The system shows the campaign's full details: company name, campaign
   name, date range, total budget, per-kilometer rate, maximum number
   of drivers, estimated audience reach, description, and any uploaded
   images, together with the driver's own application status if one
   exists.
3. The driver reviews the information.
4. The driver chooses to close the detail view, to apply (if not yet
   applied), to start a ride (**UC01**, if accepted and eligible), or
   to open the messaging thread with the company (**UC05**, if
   accepted).


## Alternative Flows

**2a. The campaign has been withdrawn since the driver opened it.** The
system tells the driver the campaign is no longer recruiting and
disables the apply action.


## Postconditions

a. The driver has full information about the campaign's parameters.
b. No persistent state changes unless the driver triggers a follow-up
   action, in which case the corresponding use case (**UC02**, **UC01**,
   or **UC05**) applies.
