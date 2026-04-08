## Use Case: User Registration

**Actor:** Unregistered User

**Description:** A new user car-owner creates an account in the app by providing required information.

**Preconditions:**
- User has downloaded and opened the app.
- User has a valid email address.

**Flow:**
1. User taps **Sign Up** on the welcome screen.
2. The System displays registration form Car Owner.
3. User fills in required fields, and submits form.
4. The system validates the input format (email syntax, password strength).
5. The system checks for the existing account with the same email.
6. The system creates the account and prompts user to complete profile to upload vehicle info.
7. User fills optional profile fields and confirms.
8. The system saves profile details and navigates the user to the home screen.

**Alternative Flows:**
- 4a. Invalid input
    - System highlights invalid fields and prevents submission until corrected.
- 5a. Email already registered:
    - System shows “Email already in use” message and offers Log In link.

**Postconditions:**
- A new user account is created.
- User is logged in and directed to complete their profile.
