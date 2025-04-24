## Use Case: User Registration

**Actor:** Unregistered User

**Description:** A new user car-owner creates an account in the app by providing required information.

**Preconditions:**
- User has downloaded and opened the app.
- User has a valid email address (or phone number) and access to it.

**Flow:**
1. User taps **Sign Up** on the welcome screen.
2. The System displays registration form Car Owner.
3. User fills in required fields, and submits form.
4. The system validates the input format (email syntax, password strength).
5. The system checks for the existing account with the same email.
6. The system verifies the code that was sent to user email and the system is waiting on the user for typing the code and if it's correct, then activates the account. 
7. The system prompts user to complete profile to upload vehicle info. 
8. User fills optional profile fields and confirms. 
9. The system saves profile details and navigates the user to the home screen.

**Alternative Flows:**
- 4a. Invalid input
    - System highlights invalid fields and prevents submission until corrected.
- 5a. Email already registered:
    - System shows “Email already in use” message and offers Log In link.
- 8a. Verification timeout or wrong code
    - System shows “Verification failed” and allows user to resend code.

**Postconditions:**
- A new user account is created and activated.
- User is logged in and directed to complete their profile.
