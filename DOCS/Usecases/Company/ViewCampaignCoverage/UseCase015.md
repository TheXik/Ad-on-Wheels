# UC15: View Campaign Coverage

A company user opens any of their campaigns and sees a coverage map
that overlays the routes of every completed ride contributed by
accepted drivers. It addresses **FR.22**.


## Actors

Company user.


## Preconditions

a. The company user is signed in.
b. The campaign exists, belongs to the company, and has at least one
   accepted driver who has completed at least one ride with a recorded
   position trace.
c. The company user needs to see the geographic distribution of the
   campaign's exposure.


## Basic Flow

1. The company user chooses to open the coverage map for one of the
   company's campaigns.
2. The system retrieves the position traces of every completed ride
   recorded against that campaign.
3. The system renders all traces on a single map, distinguishing
   verified rides (solid polyline) from unverified rides (dashed
   polyline), and fits the viewport to the union of the trace bounds.
4. The company user reviews the map and may toggle between showing
   verified rides only and showing all rides.


## Alternative Flows

**2a. The campaign has no completed rides yet.** The system tells the
company user the coverage map is empty and offers to open the
application list (**UC07**) or the campaign details (**UC06**).

**3a. The traces cannot be fetched.** The system tells the company
user the request failed and offers to retry; previously cached
traces, if any, remain visible.


## Postconditions

a. The company user has seen the geographic distribution of every
   completed ride contributed to the campaign.
b. No persistent state changes.
