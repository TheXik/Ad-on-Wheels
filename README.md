# Application Overview

This project represents an application that facilitates the rental of advertising space on cars. 
It features two primary user roles – **Car Owner** and **Company**. The goal is to create a platform 
where car owners can offer advertising space (their cars) and companies can purchase these ads.

---

## User Roles

1. **Unregistered User**
   - No access to the main application features; sees only a welcome screen with an option to register.
   - Can view a demo in read-only mode.
   - Has the option to register as either a Company or a Car Owner.

2. **Registered User (Car Owner)**
   - Access to functionalities for registering a car, viewing statistics, income, and settings.

3. **Registered Company**
   - Access to functionalities for purchasing advertising space on cars, viewing statistics, payment overviews, and settings.

4. **Admin Account**
   - Manages the entire system

---

## Functional Requirements

### 1. For Registered Car Owners

- **Before Registering a Car:**
  - The user must sign Terms & Conditions and GDPR. (If they refuse, they can continue in a limited mode.)
  - There must be an option to delete the account.

- **Car Registration:**
  - The car can be registered for a minimum of one month or more.
  - The user provides the car brand, model, location (where it will be driven most frequently), and planned monthly mileage.
  - Based on these details, the advertising price is calculated (the Car Owner must meet the set mileage limit to receive payment).

- **Main Menu (Car Owner):**
  - Shows how many kilometers have been driven in the current month.
  - Indicates how many kilometers remain to fulfill the mileage requirement for earning the rental fee.
  - Provides a quick overview of key information.

- **GPS Tracking (Optional):**
  - The app can track how much and when the Car Owner drives.
  - This data could be used to estimate the reach of the advertisement (e.g., “hot areas”).

- **Settings (Car Owner):**
  - Allows the user to set up a bank account, change password, email, and other personal details.

- **Statistics (Car Owner):**
  - Shows the total distance driven.
  - Displays the total earnings.

- **Detailed Payment Records:**
  - Includes options for checks, complaints, refunds, and so on.

- **Car Owner Screen Overview:**
  - **HOME** | **FIND AD** | **STATS** | **PROFILE** 

---

### 2. For Registered Companies

- **Company Registration:**
  - Must sign Terms & Conditions (details not covered in depth here).

- **Main Menu (Company):**
  - Displays basic statistics:
    - Number of rented cars.
    - How many cars have met their mileage requirements.
    - Total advertising expenditure.
  - May include an estimate of the ad reach (optional).

- **STATS Page (Company):**
  - Shows all relevant statistics (number of rented cars, advertising costs, a map of regions where ads have been placed, etc.).

- **BUY AD (Company):**
  - Allows the company to view the current list of vehicles available for advertising.
  - Provides a filter and/or recommendation algorithm (e.g., by location, car brand, mileage).

- **SETTINGS (Company):**
  - Similar to the Car Owner settings (password change, email update, etc.).

- **PAYMENT (Company):**
  - Detailed records of payments.
  - Options for checks, complaints, refunds, etc.

---

### 3. Mutual Interaction (Company – Car Owner)

- Companies select the cars on which they wish to place advertisements.
- A recommendation algorithm can be implemented for companies based on location and other parameters.

---

## Non-Functional Requirements

1. **Intuitive UI**
   - Emphasis on simplicity and clarity.

2. **iOS Compatibility**
   - The goal is for the application to run on iOS devices.

---
