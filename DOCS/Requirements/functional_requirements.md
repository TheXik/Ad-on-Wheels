# Functional Requirements

These requirements come from the problem domain analysis, the user stories, and
a survey of existing platforms. Numbering is consecutive across the four
groupings, matching the thesis (Chapter 1, Section 1.5).


## Authentication and Account Management

- **FR.1** — New users must be able to register for an account on the platform.
  The mobile application must support registration as either a driver or a
  company. The web dashboard must support registration as a company only.
- **FR.2** — The system must verify e-mail uniqueness during registration and
  prevent duplicate accounts.
- **FR.3** — Registered users must be able to log in using their e-mail and
  password. Passwords must be stored only in hashed form.
- **FR.4** — The mobile application must support sign-in via Google OAuth2,
  creating an account automatically if none exists for the returned e-mail.
- **FR.5** — A registration that fails partway through must trigger
  compensating actions that undo any already-completed steps, leaving no
  partial user record.


## Driver-Specific Requirements

- **FR.6** — Drivers must be able to complete an onboarding wizard and update
  their vehicle information (make, model, year, license plate).
- **FR.7** — The campaign discovery interface in the mobile application must
  allow the driver to iterate through recruiting campaigns one at a time, to
  submit an application to the current campaign with a single affirmative
  gesture, and to skip to the next campaign with a single dismissive gesture.
- **FR.8** — Drivers must be able to view the status of their campaign
  applications (applied, accepted, or declined) and open a campaign for
  detailed information.
- **FR.9** — Drivers must be able to start a ride from the home screen, which
  activates on-device GPS tracking and displays a live map with elapsed time,
  current speed, and cumulative distance.
- **FR.10** — During an active ride, the platform must collect position
  samples from the user's device at a regular interval. At the end of the
  ride, the system must compute and store the total distance, total duration,
  average speed, and earnings for that ride. The sampling interval is
  specified by NFR.4.
- **FR.11** — If a driver drove with an advertisement mounted without first
  starting a ride through the application, the platform must provide a
  mechanism that allows the drive to be recorded retroactively on the basis
  of position data the application was able to observe during that drive
  (deferred ride mechanism, see UC13).
- **FR.12** — Drivers must be able to see their active campaigns, cumulative
  earnings, progress toward a monthly distance goal, and the unread message
  count.
- **FR.13** — Drivers must have access to detailed statistics, including
  total ride count, weekly and monthly distance, earnings breakdowns, and a
  daily earnings chart.
- **FR.14** — Drivers must be able to attach a photo of their vehicle decal
  to their driver profile.
- **FR.15** — Drivers must be able to visualise the route of any completed
  ride on a map.


## Company-Specific Requirements

- **FR.16** — Companies must be able to create advertising campaigns. Each
  campaign must carry a name, a description, a start and end date, a total
  budget, a per-kilometer driver payout rate, and a maximum number of
  participating drivers, and may carry an estimated audience reach and visual
  assets.
- **FR.17** — Companies must be able to view the list of their campaigns and
  open any campaign for details, including its application list and current
  statistics.
- **FR.18** — Companies must be able to review driver applications for their
  campaigns and accept or decline each application individually.
- **FR.19** — Once a driver has been accepted for a campaign, the company
  must be able to send them a direct message within the context of that
  campaign.
- **FR.20** — Companies must be able to see aggregate metrics across all
  their campaigns: total campaigns, number of active campaigns, total
  kilometers driven, and total number of completed rides.
- **FR.21** — Companies must be able to export campaign statistics as a
  downloadable file, either for a single campaign or across all campaigns of
  the company.
- **FR.22** — Companies must be able to view a coverage map for any of
  their campaigns. The map must overlay the routes of every completed ride
  contributed by accepted drivers.


## Communication

- **FR.23** — Drivers and companies must be able to exchange text messages
  within the context of a specific campaign.
- **FR.24** — The system must track which messages have been read. Drivers
  and companies must be able to see the count of unread messages.
- **FR.25** — Drivers and companies must be able to read their per-campaign
  message history.
