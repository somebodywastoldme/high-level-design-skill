# Architecture Review Checklist

Apply this review before producing `hld.md`. Record gaps as assumptions,
unknowns, risks, or questions; do not silently fill them in.

## Evidence

- [ ] Every material claim is labelled **Confirmed**, **Assumption**, or
  **Unknown**.
- [ ] Confirmed claims have a requirement, stakeholder input, or other stated
  source.
- [ ] Assumptions name the decision they influence and how they will be
  validated.
- [ ] Unknowns become questions when they can affect scope, estimate, or
  architecture.
- [ ] No exact performance, cost, capacity, or delivery value is invented.

## Architecture

- [ ] The baseline architecture fits the classified business, functional, NFR,
  data, integration, security, and operational drivers.
- [ ] Every diagram box has a clear purpose and uses a catalogued logical
  component where one fits.
- [ ] The design considers synchronous versus asynchronous flow where relevant.
- [ ] Data ownership, lifecycle, and system-of-record boundaries are clear.
- [ ] External systems, trust boundaries, and integration responsibilities are
  explicit.
- [ ] Material failures, retries, idempotency, and recovery paths are considered.
- [ ] Security, privacy, access control, and compliance needs are addressed when
  relevant.
- [ ] Observability needs—signals, logs, metrics, tracing, and operational
  ownership—are addressed when relevant.

## Presales and readability

- [ ] The design remains an HLD, not an LLD: it explains responsibilities,
  boundaries, and decisions without implementation-level detail.
- [ ] One baseline is recommended; no more than two alternatives are included,
  each with a condition and trade-off.
- [ ] Risks and open questions state their effect on scope, estimate, or architecture.
- [ ] The diagram normally has 8-16 boxes, grouped as Client, Core, Async-Data,
  and External when applicable.
- [ ] A larger diagram is explicitly justified, or split into focused views.
