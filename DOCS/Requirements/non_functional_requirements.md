# Non-Functional Requirements

These requirements follow Necasky's verifiability rule (NSWI041 lecture 05):
each one carries a measurable threshold so it can be objectively tested.
External constraints — implementation choices, environment limits, legal
obligations — are listed separately in
[`constraints.md`](constraints.md).


- **NFR.1 — Password storage.** User passwords must never be stored or
  logged in clear text. They must be stored in a non-reversible hashed form,
  so that the original password cannot be recovered from the database.

- **NFR.2 — Authentication lifetime.** Authentication tokens issued by the
  system must expire within at most one hour of being issued, so that a
  compromised token has a bounded usefulness window.

- **NFR.3 — Public attack surface.** Only one entry point of the system
  must be reachable from the public internet; all other components must be
  reachable only from inside the system.

- **NFR.4 — Ride tracking freshness.** During an active ride, the user's
  device must upload the most recent GPS coordinate to the platform at
  least every five seconds, so that the in-flight ride representation is
  never more than five seconds stale.

- **NFR.5 — Deployability.** Starting from a clean checkout of the
  repository on a developer machine that has a container runtime installed
  and an environment file populated, the entire system must come up to a
  healthy state through a single orchestration command, without manual
  configuration steps.
