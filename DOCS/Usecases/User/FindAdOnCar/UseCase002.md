## Use Case: Find an Advertisement for User’s Car

**Actor:** Registered Car Owner  

**Description:** The user is browsing available advertisements to find a campaign that fits their car. Ads are presented one at a time, and the user can swipe right to express interest or left to skip.

**Preconditions:**  
- User is logged in  
- User is **not** currently participating in an active campaign  

**Flow:**
1. User opens the app and navigates to the **"Find Ad"** page.
2. The system displays a preview of an available advertisement
3. The user reviews the ad details and visual.
4. The user can:
   - **Swipe right** to express interest in the campaign.
   - **Swipe left** to skip and view the next ad.
5. If the user swipes right: The system records the interest.
6. The next available ad is displayed.

**Alternative Flow:**
- If the user taps the **back arrow**, the app returns to the previous ad, if user accidentaly swipe left on the ad that he wanted to like.

**Postconditions:**  
- If the user swipes right, their interest is logged and may result in campaign assignment.
- If the user swipes left, the ad is skipped, and the user continues browsing.
