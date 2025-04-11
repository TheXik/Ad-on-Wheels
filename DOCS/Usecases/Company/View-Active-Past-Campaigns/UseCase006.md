## Use Case: View Active or Past Campaigns

**Actor:** Registered Company User

**Description:** The company user navigates to the Stats page and selects one of their active or past campaigns to view its performance metrics such as reach, distance driven, and driver activity.

**Preconditions:**
- User is logged in as a company

**Flow:**
1. User navigates to the Stats page.
2. The system checks for existing campaigns (active or past).
3. If campaigns are found, the system displays them.  (filter by  ("Active" and "Past")).
4. User selects the desired campaign from the filtered list.
5. The system loads and displays campaign statistics.
**Alternative Flow:**
- If no campaigns are found:
  - The system shows a message: “No campaigns available.”

**Postconditions:**
- User has successfully viewed the reach and performance data for the selected campaign (active or historical).
