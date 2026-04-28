# UC05: Exchange Messages with a Company

A driver and a company exchange text messages within the context of a
specific campaign. From the driver's perspective, this use case covers
reading messages received from companies and sending replies. It
addresses **FR.21**, **FR.22**, and **FR.23**, and complements **FR.18**
on the company side (**UC07**).


## Actors

Driver (primary). Company (secondary, initiates messages per **FR.18**).


## Preconditions

a. The driver is signed in.
b. The driver has at least one campaign with *accepted* application
   status; messaging is only available in the context of an accepted
   campaign.
c. The driver needs to read or send messages to the company that
   accepted them.


## Basic Flow

1. The driver chooses to open the inbox; the system shows the
   unread-count badge per **FR.22**.
2. The system shows the driver's per-campaign message threads, each
   marked as read or unread.
3. The driver chooses a thread to open.
4. The system marks all messages in that thread as read on the backend
   and shows the full chronological conversation.
5. The driver chooses to reply or to close the thread.
6. On reply, the system records the new message under the same campaign
   context and shows it in the conversation.


## Alternative Flows

**2a. The driver has no message threads yet.** The system tells the
driver the inbox is empty.

**6a. The reply cannot be sent.** The system tells the driver the
message failed and keeps the draft visible so the driver can retry.


## Postconditions

a. Messages opened by the driver are marked as read.
b. Any reply submitted during the session is recorded and the
   per-campaign message history reflects the new entry.
