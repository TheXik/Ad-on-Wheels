# UC08: Export Campaign Statistics

A company user exports campaign statistics as a downloadable file for
offline analysis and reporting, either for a single campaign or across
all campaigns of the company. It addresses **FR.21** and **C.3**.


## Actors

Company user.


## Preconditions

a. The company user is signed in.
b. The company has at least one campaign with recorded activity
   (drivers, rides, or applications).
c. The company user needs to share the campaign performance data
   outside the platform.


## Basic Flow

1. The company user chooses to export campaign statistics.
2. The system asks the company user to choose the export scope: a
   single campaign or all campaigns of the company.
3. The company user chooses the scope.
4. The system generates the export file containing the campaign metrics
   (name, state, date range, budget, drivers accepted, kilometers
   driven, completed rides, earnings disbursed) in a format openable in
   standard spreadsheet software (per **C.3**).
5. The system delivers the file to the company user's device.


## Alternative Flows

**2a. There is no data to export for the chosen scope.** The system
tells the company user no data is available and does not generate a
file.

**4a. The export cannot be generated.** The system tells the company
user the export failed and lets them retry. No file is delivered.


## Postconditions

a. A spreadsheet-openable export of the chosen scope is on the company
   user's device, or no file has been delivered if the export was
   declined or failed.
b. No persistent state changes on the platform.
