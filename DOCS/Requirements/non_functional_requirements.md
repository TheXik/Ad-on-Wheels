# Non-Functional Requirements


- **NFR.1 - Password storage.** User passwords must never be stored or
  logged in clear text. They must be hashed with the BCrypt algorithm
  using a work factor of at least 12.

- **NFR.2 - Authentication lifetime.** Authentication tokens issued by
  the authentication service must expire within at most one hour of
  being issued, so that a compromised token has a bounded usefulness
  window.

- **NFR.3 - Public attack surface.** Only the API gateway must be
  exposed to public clients; all other backend services must be
  reachable exclusively from within the backend's internal network.

- **NFR.4 - Ride tracking freshness.** During an active ride, the
  client must upload the most recent GPS coordinate to the backend at
  least every five seconds, so that the in-flight ride representation
  is never more than five seconds stale.

- **NFR.5 - Deployability.** Starting from a clean checkout of the
  repository on a developer machine that has a container runtime
  installed and an environment file populated, the entire backend
  (all services and all data stores) must start to a healthy state
  through a single orchestration command, without manual schema
  setup or service-by-service boot ordering performed by the operator.

- **NFR.6 - Independent restartability and schema isolation.** Any
  single backend service must be stoppable and restartable without
  requiring another service to be stopped, reconfigured, or
  redeployed; service discovery (Eureka) re-establishes routing
  automatically. Each service owns its own database schema, so a
  migration inside one service must not require coordinated schema
  changes in any other service.
