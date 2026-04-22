# UC11: Company Registration

**Addresses:** FR.1, FR.2, FR.3, FR.5.

An unregistered business user creates a company account. Registration
can start either from the web dashboard (which shows a company form
directly, per FR.1) or from the mobile application (after selecting
the **Company** role on the landing role picker).


## Actors
Unregistered User.


## Preconditions
- The user has opened the web dashboard or the mobile application.
- No session is active on the client.


## Basic Flow
1. The user reaches the company registration form:
    - **Web dashboard:** the landing screen goes directly to the
      company registration form (no role picker, per FR.1).
    - **Mobile application:** the user taps **Sign Up**, selects
      **Company** from the role picker, and the form opens.
2. The system displays the company registration form, asking for
   name, business e-mail, password, and company identifier.
3. The user fills in the required fields and submits.
4. The system validates input format (e-mail syntax, password
   strength, business-identifier format where applicable).
5. The system checks that no other account exists with the same
   e-mail (FR.2).
6. The system creates the authentication record (with the password
   stored only in hashed form, per FR.3 / NFR.1) and a company
   profile record.
7. The system issues an authentication token (lifetime bounded by
   **NFR.2**) and prompts the user to complete their company profile
   (optional branding fields, contact info).
8. The user fills optional profile fields and confirms.
9. The system saves the additional profile details and navigates
   the user to the company home dashboard.


## Alternative Flows

**4a. Invalid input.** The system highlights invalid fields and
prevents submission until corrected.

**5a. E-mail already registered.** The system shows "E-mail already
in use" and offers a link to the Login flow (UC12).

**6a. Registration fails partway through.** The system executes
compensating actions (per **FR.5**) that undo any already-completed
registration steps (authentication record, profile record), so no
orphaned partial record remains.


## Postconditions
A new company account (authentication record + company profile) is
created. The user is authenticated and landed on the company home
dashboard. An authentication token with a bounded lifetime is
persisted on the client.


## Design Notes
Google OAuth (FR.4) is not required on the company registration path
because the thesis limits OAuth to the mobile application's driver
flow.
