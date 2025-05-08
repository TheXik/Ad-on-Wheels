## Use Case: Export Campaign Stats

**Actor:** Registered Company User

**Description:** The company user exports the performance metrics of a selected ad campaign 
into a dataset file for offline analysis, reporting and sharing with the company.

**Preconditions:**
- User is logged in with a Company account.
- At least one campaign (active or past) exists and has collected performance data (reach, distance driven, driver activity).

**Flow:**
1. User navigates to the Stats page.
2. The system displays overall stats for all the campaigns and selection box to choose the ad.
3. User selects the desired campaign.
4. The system loads and displays that campaign’s performance metrics.
5. User clicks the Export button.
6. The system generates a file(dataset) containing all key metrics.
7. The system prompts the user to download the generated file.
8. User saves the file to their device.

**Alternative Flows:**
3a. User exports overall stats for all the campaigns past / active.
4a. No data to export. The Export dataset button is disabled, and a tooltip reads “No data available to export.”
6a. Export error. The system shows “Unable to generate Dataset. Please retry.” and offers a Retry action.

**Postconditions:**
- A Dataset file with the campaign’s performance data is downloaded to the user’s device.

