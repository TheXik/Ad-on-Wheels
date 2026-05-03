# UC02: Find an Advertisement

Through this use case a driver discovers and applies to campaigns that
are currently recruiting. It addresses **FR.7** and **FR.8**.


## Actors

Driver.


## Preconditions

a. The driver is signed in.
b. The driver needs to find an advertising campaign to participate in.


## Basic Flow

1. The driver chooses to discover advertising campaigns.
2. The system shows the recruiting campaigns the driver has not yet
   applied to and has not skipped during this discovery session, one at
   a time, with the company name, campaign name, date range,
   per-kilometer rate, maximum number of drivers, and a short
   description.
3. For each campaign the driver chooses to apply, to skip, or to view
   its details.
4. After each choice, the system advances to the next campaign.
5. When no further recruiting campaigns are available, the system tells
   the driver and offers to refresh the list.


## Alternative Flows

**3a. The driver reverses the most recent skip.** The system restores
the just-skipped campaign and offers it to the driver again.

**3b. The driver has an accepted campaign.** The system rejects the
application, tells the driver they cannot run two campaigns at once, and
advances to the next campaign.

**3c. The application cannot be submitted for any other reason.** The
system tells the driver the application failed and lets them retry.


## Postconditions

a. Every campaign the driver applied to during the session is recorded
   as an application with status *applied*.
b. Skipped campaigns are not offered again during the same discovery
   session unless the skip is reversed.
