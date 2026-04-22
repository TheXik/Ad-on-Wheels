# UC06: View Active or Past Campaigns

**Addresses:** FR.16, FR.19.

A company user browses their own campaigns (active, recruiting, or
past) and opens any of them for details.


## Actors
Company.


## Preconditions
- The user is logged in with a Company account.


## Basic Flow
1. The user navigates to the **Campaigns** or **Stats** screen.
2. The system loads the list of the company's campaigns, grouped or
   filterable by state (`recruiting`, `active`, `completed`).
3. The user optionally applies a state filter or searches by name.
4. The user selects a campaign.
5. The system loads and displays the campaign's detail view:
   description, date range, budget, participant list, current
   per-campaign metrics (drivers accepted, kilometres driven,
   completed rides, unread messages).


## Alternative Flows

**2a. No campaigns yet.** The system shows an empty state with a
primary action to create the first campaign (UC: create campaign,
FR.15).


## Postconditions
The user has viewed the campaign's performance data. No persistent
state changes unless the user initiates a follow-up action from the
detail view (review applications per UC07, export statistics per
UC08, send a message per FR.18).
