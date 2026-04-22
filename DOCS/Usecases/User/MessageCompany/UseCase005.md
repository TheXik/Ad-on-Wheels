# UC05: Exchange Messages with a Company

**Addresses:** FR.21, FR.22, FR.23. Complements FR.18 on the company
side (UC07).

A driver and a company exchange text messages within the context of a
specific campaign. From the driver's perspective, this use case covers
reading messages received from companies and sending replies or new
messages.


## Actors
Driver (primary). Company (secondary - initiates messages per FR.18).


## Preconditions
- The driver is logged in.
- The driver has at least one campaign with `accepted` application
  status; messaging is only available in the context of an accepted
  campaign.


## Basic Flow
1. The driver opens the **Messages** entry point from the home screen
   (with an unread-count badge, per FR.22).
2. The system loads the list of conversation threads, one per campaign
   in which the driver and the company have exchanged at least one
   message, ordered chronologically by last activity.
3. The driver selects a thread.
4. The system marks incoming messages in that thread as read, updates
   the unread counter, and renders the full chronological conversation
   (per FR.23).
5. The driver optionally composes a reply or a new message and sends
   it.
6. The system persists the message, delivers it to the company, and
   appends it to the conversation view with its delivery status.


## Alternative Flows

**2a. No message threads yet.** The system shows an empty state.

**6a. Send fails.** The message is marked as *failed* in the
conversation view with a retry action. The unread counter is not
updated.


## Postconditions
The conversation history is updated with any newly sent messages.
Unread counters on both the driver and company home screens reflect
the new read state.
