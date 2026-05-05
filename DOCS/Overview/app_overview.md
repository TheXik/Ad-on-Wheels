# Application Overview

Ad-on-Wheels is a two-sided marketplace that connects **car owners** (drivers)
who are willing to rent their vehicle's exterior as advertising space with
**companies** seeking a mobile, per-kilometer alternative to billboard
advertising. The platform measures how far a driver actually drives with a
mounted advertisement, computes earnings from that measurement, and lets
companies create and manage their own campaigns without going through a managed
sales team.

The platform addresses gaps identified in the review of existing car-advertising
services (Wrapify, Carvertise, Nickelytics, Brand Riders): no single existing
platform combines self-service campaign creation, per-kilometer GPS-verified
payouts, and a smartphone-only verification gesture without extra hardware.


## Key Terms

- **Campaign** - an advertising campaign created by a company, with a duration,
  total budget, and maximum number of participating drivers.
- **Ride** - a single driving session recorded for a driver. Each ride carries
  a start and end time, a position trace, total distance, computed earnings,
  and an explicit verification status (`unverified` or `verified`).
- **Application** - a request submitted by a driver to join a specific
  campaign; it is always in one of four states: `applied`, `accepted`,
  `declined`, or `expired` when the campaign ends before any ride against
  it is started.
- **QR Code Verification** - a lightweight, client-side verification gesture
  performed at the end of a ride to confirm that the driver was actually
  driving the campaign's vehicle.


## User Roles

### Driver (Car Owner)
Uses a personal vehicle daily and wants to earn extra income. Interacts with
the platform from a phone, in short sessions, on the go. Primary tasks are
discovering campaigns, starting and ending rides, and checking earnings.

### Company (Advertiser)
A marketing manager or small-business owner. Tasks are analytical: creating
campaigns, reviewing driver applications, monitoring campaign performance,
and exporting statistics. Uses a dedicated web dashboard, but the same
workflow is also available through the mobile application.

### Unregistered User
Someone who opens the mobile application or the web dashboard without an
existing account. The only actions available are selecting a role and
completing the corresponding registration form.

### Administrator (reserved for future scope)
A moderator role for account review, flagged rides, and dispute resolution.
Not part of the initial version, but the `ADMIN` value is reserved in the
user-role enumeration so the role can be added later without schema changes.


## Platform Components

- **Mobile application** (iOS, Swift/SwiftUI) - used by both drivers and
  company users. Exposes role picker on first launch.
- **Web dashboard** - used by company users only; takes users straight to
  a company registration / login flow.
- **Backend** - a set of independently deployable services behind a single
  API gateway. Each service owns its own database schema. The gateway is the
  only public entry point; other services are only reachable from the
  backend's internal network.


## Architectural Rules (see `Requirements/constraints.md`)

- Single public entry point (gateway).
- Each backend component owns its persistent data; cross-component access
  only through network-visible interfaces.
- Personal data is owned by a single component and must be deletable or
  exportable without affecting unrelated data.
- CSV exports are delivered in UTF-8.


## Related Requirements Docs

- [`Requirements/functional_requirements.md`](../Requirements/functional_requirements.md) - 25 functional requirements grouped by area.
- [`Requirements/non_functional_requirements.md`](../Requirements/non_functional_requirements.md) - 5 non-functional requirements.
- [`Requirements/constraints.md`](../Requirements/constraints.md) - external constraints the design must respect.
- [`Usecases/`](../Usecases) - detailed use case descriptions.
