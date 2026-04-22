# UC08: Export Campaign Statistics

**Addresses:** FR.20, C.8 (CSV in UTF-8).

A company user exports campaign statistics as a CSV file for offline
analysis and reporting - either for a single campaign or across all
campaigns of the company.


## Actors
Company.


## Preconditions
- The user is logged in with a Company account.
- The company has at least one campaign with recorded activity
  (drivers, rides, or applications).


## Basic Flow
1. The user navigates to the **Stats** or a campaign's detail screen.
2. The user selects the export scope:
    - **Single campaign** - export statistics for the currently
      selected campaign only.
    - **All campaigns** - export aggregate statistics across every
      campaign owned by the company.
3. The user clicks **Export**.
4. The system generates a CSV document containing the campaign
   metrics (name, state, date range, budget, drivers accepted,
   kilometres driven, completed rides, earnings disbursed) encoded
   in **UTF-8** (per C.8).
5. The system delivers the CSV file to the user's browser for
   download.


## Alternative Flows

**2a. No data to export.** The **Export** action is disabled with a
tooltip "No data available to export."

**4a. Export generation fails.** The system shows "Unable to generate
export. Please retry." and offers a retry action. No file is
downloaded.


## Postconditions
A CSV file encoded in UTF-8 is delivered to the user's device. No
persistent state changes on the backend.


## Design Notes
The export format is constrained to CSV/UTF-8 by **C.8**, so that the
file can be opened in standard spreadsheet software without additional
tooling. Alternative formats (JSON, XLSX) are out of scope for the
initial version.
