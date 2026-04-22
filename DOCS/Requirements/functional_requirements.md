# Functional Requirements

These requirements are derived from the problem domain analysis, the user
stories, and by researching the existing platforms.


## Authentication and Account Management

- **FR.1** - New users must be able to register for an account on the
  platform. The mobile application must support both roles and therefore
  expose a role picker on its landing screen, letting the user choose
  between the driver and company role. The web dashboard must expose only
  company features and therefore take the user straight to a company
  registration form without a role picker.
- **FR.2** - The system must verify e-mail uniqueness during registration
  and prevent duplicate accounts.
- **FR.3** - Registered users must be able to log in using their e-mail and
  password. Passwords must be stored only in hashed form.
- **FR.4** - The mobile application must support sign-in via Google OAuth2,
  creating an account automatically if none exists for the returned e-mail.
- **FR.5** - A registration that fails partway through must trigger
  compensating actions that undo any already-completed steps, leaving no
  partial user record.


## Driver-Specific Requirements

- **FR.6** - Drivers must be able to complete an onboarding wizard and
  update their vehicle information (make, model, year, license plate).
- **FR.7** - The campaign discovery interface in the mobile application
  must allow the driver to iterate through recruiting campaigns one at a
  time, submit an application to the current campaign with a single
  affirmative gesture, and skip to the next campaign with a single
  dismissive gesture. The specific interaction pattern is a design
  decision.
- **FR.8** - Drivers must be able to view the status of their campaign
  applications (`applied`, `accepted`, or `declined`) and open a campaign
  for detailed information.
- **FR.9** - Drivers must be able to start a ride from the home screen,
  which activates on-device GPS tracking and displays a live map with
  elapsed time, current speed, and cumulative distance.
- **FR.10** - During an active ride, the client must report its current
  position to the backend at a regular sampling interval, and at the end
  of the ride the backend must compute and persist the total distance,
  total duration, average speed, and earnings for that ride. The sampling
  interval is specified by NFR.4.
- **FR.11** - If a driver drove with an advertisement mounted without
  first starting a ride through the application, the platform must
  provide a mechanism that allows the drive to be recorded retroactively
  on the basis of position data the application was able to observe
  during that drive (deferred ride mechanism; see UC013).
- **FR.12** - The driver home screen must display active campaigns,
  cumulative earnings, progress toward a monthly distance goal, and the
  unread message count.
- **FR.13** - Drivers must have access to detailed statistics, including
  total ride count, weekly and monthly distance, earnings breakdowns,
  and a daily earnings chart.
- **FR.14** - Drivers must be able to upload a photo of their vehicle
  decal from the application to verify it is in good condition.


## Company-Specific Requirements

- **FR.15** - Companies must be able to create advertising campaigns by
  specifying a name, description, date range, budget, maximum number of
  drivers, estimated audience reach, and optional campaign images.
- **FR.16** - Companies must be able to view the list of their campaigns
  and open any campaign for details, including its application list and
  current statistics.
- **FR.17** - Companies must be able to review driver applications for
  their campaigns and accept or decline each application individually.
- **FR.18** - Once a driver has been accepted for a campaign, the company
  must be able to send them a direct message within the context of that
  campaign.
- **FR.19** - The company home dashboard must show high-level metrics:
  total campaigns, number of active campaigns, total kilometres driven,
  and total number of completed rides across all the company's campaigns.
- **FR.20** - Companies must be able to export campaign statistics as CSV
  files, either for a single campaign or across all campaigns of the
  company.


## Communication

- **FR.21** - Drivers and companies must be able to exchange text messages
  within the context of a specific campaign.
- **FR.22** - The system must track the read status of messages and
  display unread message counts on both the driver and company home
  screens.
- **FR.23** - Users must be able to view chronological conversation
  threads per campaign from their inbox.
