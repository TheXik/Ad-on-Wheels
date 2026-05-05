# Constraints

The platform must respect the following external constraints. They come from
the thesis assignment, the law, and stakeholder expectations. Constraints are
separate from functional and non-functional requirements: they describe limits
the design must respect, not behavior the platform must produce.


- **C.1 — Smartphone-only ride verification.** Per the thesis assignment,
  the platform must offer a smartphone-based verification step at the end
  of a ride, performed by the driver, to indicate that the campaign's
  advertisement is displayed on the vehicle. The QR scan does not need to
  be cryptographically tied to a specific vehicle or campaign.

- **C.2 — GDPR.** The platform processes personal data (e-mail addresses,
  vehicle identification, position traces) and therefore falls under the
  scope of the European General Data Protection Regulation.

- **C.3 — Spreadsheet-openable export.** Campaign statistics exports must
  be openable in standard spreadsheet software without additional tools.
