# UC06: View Active or Past Campaigns

A company user browses the company's own campaigns (recruiting, active,
or completed) and opens any of them for details. It addresses **FR.16**
and **FR.19**.


## Actors

Company user.


## Preconditions

a. The company user is signed in.
b. The company user needs to see how their campaigns are performing.


## Basic Flow

1. The company user chooses to open the list of the company's
   campaigns.
2. The system shows the campaigns grouped or filterable by state
   (recruiting, active, completed).
3. The company user chooses a campaign.
4. The system shows the campaign's detail view: description, date
   range, budget, per-kilometer rate, participants list, and current
   per-campaign metrics (drivers accepted, kilometers driven, completed
   rides, unread messages).


## Alternative Flows

**2a. The company has no campaigns yet.** The system tells the company
user the list is empty and offers to create the first campaign
(**FR.15**).


## Postconditions

a. The company user has seen the campaign's current performance data.
b. No persistent state changes unless the company user triggers a
   follow-up action (review applications per **UC07**, export
   statistics per **UC08**, or send a message per **FR.18**).
