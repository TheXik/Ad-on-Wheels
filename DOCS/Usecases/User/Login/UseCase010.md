## Use Case: User Login (Car Owner)

**Actor:** Registered Car Owner

**Description:** A car-owner who has already registered authenticates into the app to access driving campaigns, track progress, and view earnings.

**Preconditions:**
- User has previously registered as a Car Owner and verified their account.

**Flow:**
1. User taps Log In on the welcome screen.
2. The System displays the login form.
3. User enters credentials and taps Submit.
4. The System validates the input format.
5. On success, loads the Car owner home screen.

**Alternative Flows:**
- 3a. Forgot password
    - User taps Forgot Password System sends reset link and follows password-reset flow.


**Postconditions:**
- User is redirected to home page
