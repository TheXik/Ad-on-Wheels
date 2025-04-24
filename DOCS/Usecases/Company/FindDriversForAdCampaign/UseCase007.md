## Use Case: Find Drivers for Ad Campaign

**Actor:** Registered Company User

**Description:** The company user navigates to the Find Drivers page, reviews driver applications for a 
specific ad campaign, and accepts suitable drivers to drive for them.


**Preconditions:**
- User is logged in as a company
- Company has at least one ad campaign exists 
- One or more drivers have applied to the selected campaign

**Flow:**
1. The User navigates to the Find Drivers page.
2. The system retrieves and displays campaigns in Recruiting state.
3. User selects the desired campaign.
4. The system fetches all driver applications for that campaign.
5. The system displays applications in a list with filters (location, rating, mileage) and sorting options.
6. User applies filters or search to narrow down the list.
7. User selects a driver to view the profile card.
8. The system displays driver details (vehicle type, compliance history, ratings, projected reach).
9. User clicks Accept or Reject on the driver profile.
10. The system records the decision, updates the campaign’s “drivers needed” counter. (It could send a notification to the driver)
11. Steps 6–10 repeat until the user finishes selecting drivers.

**Alternative Flow:**
2.a. If no campaigns are in Recruiting state.
     The system shows “No recruiting campaigns available.” 
4.a If no applications exist for the selected campaign. 
    The system shows “No drivers have applied yet” and offers a **Share Campaign** action.

**Postconditions:**
- Acceptations (or rejections) are sent to selected drivers
- Campaign’s “drivers needed” count is updated
