## Use Case: Company Registration

**Actor:** Unregistered Company User

**Description:** A business user registers a new Company account to create and manage ad campaigns.

**Preconditions:**
- User has downloaded and opened the app.
- User has a valid business email address and access to it.

**Flow:**
1. User taps **Sign Up** on the welcome screen.
2. The System displays the registration form for Company.
3. User fills in required fields and taps Submit.
4. The System validates input format (email syntax, password strength, required business ID).
5. The System checks for an existing account with the same email.
6. The System sends a verification code/link to the business email.
7. User clicks the link or enters the code.
8. The System verifies the code and activates the Company account.
9. The System prompts the user to complete company profile.
10. User fills optional profile fields and confirms.
11. The System saves profile details and navigates the user to the Company home dashboard.

**Alternative Flows:**
- 4a. Invalid input
    - System highlights invalid fields and prevents submission until corrected.
- 5a. Email already registered
    - System shows “Email already in use” and offers Log In link.
- 7a. Verification timeout or wrong code
    - System shows “Verification failed” and allows user to resend code/link.

**Postconditions:**
- A new Company account is created and activated.
- User is redirected to the Company dashboard.  