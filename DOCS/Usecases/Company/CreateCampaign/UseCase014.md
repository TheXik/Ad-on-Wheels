# UC14: Create Campaign

A company user creates a new advertising campaign with all the
parameters that drivers see when discovering it and that the platform
uses to compute payouts and capacity. It addresses **FR.16**.


## Actors

Company user.


## Preconditions

a. The company user is signed in.
b. The company has been created (per **UC12**).
c. The company user needs to recruit drivers and run a new advertising
   campaign.


## Basic Flow

1. The company user chooses to create a campaign.
2. The system asks for the campaign parameters: name, description,
   start date, end date, total budget, per-kilometer driver payout rate,
   and maximum number of participating drivers.
3. The company user submits the parameters and may optionally attach
   an estimated audience reach value and one or more visual assets
   (campaign images).
4. The system validates the parameters (start date before end date,
   non-negative budget and rate, positive maximum drivers) and creates
   the campaign in the *recruiting* state.
5. The system shows the company user the new campaign's detail view.


## Alternative Flows

**3a. The company user provides invalid parameters.** The system
highlights the invalid fields and prevents submission until they are
corrected.

**3b. The company user attaches more images than the platform
accepts** (limit per **FR.16** policy). The system rejects the excess
images and asks the company user to remove some.

**4a. The campaign cannot be created.** The system tells the company
user the operation failed and offers to retry; submitted parameters
remain in the form.


## Postconditions

a. A new campaign exists, owned by the company, in the *recruiting*
   state, with the submitted parameters and any uploaded images.
b. Drivers can discover the campaign through **UC02**.
