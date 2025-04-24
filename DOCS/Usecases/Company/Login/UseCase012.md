## Use Case: Company Login

**Actor:** Registered Company User

**Description:** A Company user authenticates into the app to access campaign management, analytics, and driver recruitment features.

**Preconditions:**
- The user has previously registered as a Company and verified their account.

**Flow:**
1. User taps Log In on the welcome screen.
2. The System displays the login form.
3. User enters credentials and taps Submit.
4. The System validates the input format.
5. On success, the System loads the Company home dashboard.

**Alternative Flows:**
- 3a. Forgot password
    - User taps **Forgot Password**; System sends reset link and follows password-reset flow.

**Postconditions:**
- User is redirected to the Company dashboard.  
