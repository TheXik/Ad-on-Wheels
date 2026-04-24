# User Stories

This document contains the full set of user stories that drive the platform's
functional requirements. The thesis (Chapter 1, Section 1.4) quotes the five
stories behind the detailed use cases (US01, US02, US07, US09, US13) and
refers to the project repository for the complete set - that is, this
document.

Story IDs mirror the corresponding use case numbers (US01 ↔ UC01, and so on).
Each story follows the classic template:

> As a *\<role\>*, I want *\<goal\>* so that *\<benefit\>*.


## Driver Stories

- **US01 - Drive and earn.** As a driver, I want to record the kilometres
  I drive while my car carries an advertisement so that the distance is
  credited toward my earnings without any manual paperwork.
  → UC01, FR.9, FR.10.

- **US02 - Discover advertisers.** As a driver, I want to quickly browse
  the advertising campaigns that are currently recruiting so that I can
  choose which ones to apply for without spending time on a long list.
  → UC02, FR.7, FR.8.

- **US03 - Understand a campaign before committing.** As a driver, I want
  to see a campaign's payout, duration, and requirements before I apply
  so that I can decide whether it fits my driving habits.
  → UC03, FR.8.

- **US04 - Track progress and earnings.** As a driver, I want a clear
  view of kilometres driven, earnings, and progress toward my monthly
  goal so that I can plan my driving to reach my payout target.
  → UC04, FR.12, FR.13.

- **US05 - Coordinate with the advertiser.** As a driver, I want to
  exchange messages with the company that accepted me so that I can ask
  about decal placement, schedule, or payout details within the
  campaign context.
  → UC05, FR.21, FR.22, FR.23.

- **US09 - Join the platform.** As a new user, I want to sign up as
  either a driver or a company so that I can access the features
  relevant to my role.
  → UC09, FR.1, FR.2, FR.3, FR.4, FR.5, FR.6.

- **US10 - Return to the platform.** As a returning driver, I want to
  log in securely (with e-mail and password or via Google) so that my
  earnings, messages, and application history are preserved across
  sessions.
  → UC10, FR.3, FR.4, NFR.1, NFR.2.

- **US13 - Recover a forgotten drive.** As a driver, I want to
  reconstruct a drive I forgot to formally start in the application so
  that I am not penalised for honestly driving with an advertisement
  on my car.
  → UC13, FR.11.

- **US14 - Prove my decal is in place.** As a driver, I want to send a
  photograph of the vehicle decal so that the platform can confirm the
  advertisement is still correctly mounted on my car.
  → FR.14, C.6.


## Company Stories

- **US06 - Monitor my campaigns.** As a company, I want to see my
  recruiting, active, and completed campaigns in one place and open
  any of them for detailed metrics so that I can understand how each
  campaign is performing.
  → UC06, FR.15, FR.16, FR.19.

- **US07 - Pick the right drivers.** As a company, I want to see the
  drivers who applied to my campaign and decide which ones to accept
  so that I can staff my campaign with suitable participants.
  → UC07, FR.17, FR.18.

- **US08 - Share results offline.** As a company, I want to export
  campaign statistics as a CSV file so that I can share them with
  stakeholders who prefer working in spreadsheets.
  → UC08, FR.20, C.8.

- **US11 - Join the platform as a company.** As a new company user, I
  want to sign up from either the web dashboard or the mobile
  application and create a company profile so that I can start running
  campaigns.
  → UC11, FR.1, FR.2, FR.3, FR.5.

- **US12 - Return to the platform.** As a returning company user, I
  want to log in securely so that my campaigns, applications, and
  messages are preserved across sessions.
  → UC12, FR.3, NFR.1, NFR.2.


## Relationship to the Thesis

The five stories highlighted in the thesis (Section 1.4) are:

1. **US01** - Drive and earn (→ UC01).
2. **US02** - Discover advertisers (→ UC02).
3. **US07** - Pick the right drivers (→ UC07).
4. **US09** - Join the platform (→ UC09).
5. **US13** - Recover a forgotten drive (→ UC13).

The additional stories above (US03, US04, US05, US06, US08, US10, US11,
US12, US14) correspond to use cases that the thesis lists in the use case
diagram but does not describe in full detail; they are included here so
the repository carries the complete set that Section 1.4 refers to.
