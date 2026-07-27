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

## Topology & anti-pattern review

Compose diagram edges from each component's **Typical interactions** in the
component catalog, then run the [anti-pattern catalog](antipatterns.md) against
the diagram before writing `hld.md`. On a match, apply the entry's Action:
auto-fix (redraw and add "Applied pattern: <name>"), fix+note (redraw and add one
assumption line), or flag-as-risk (leave and add a risk or open question). Do not
present an auto-fix as a confirmed requirement.

Actively check, do not assume:

- [ ] No client writes or reads Object Storage or a database without an authenticated boundary (A1).
- [ ] Every external actor passes API Gateway / Edge and Identity & Access (A2).
- [ ] Model access is one boundary (Model API Proxy) with self-hosted models and external providers behind it — no proxy/model sibling split (B1) and no provider call bypassing the proxy (B2).
- [ ] Every async consumer has a DLQ -> Review branch (C1).
- [ ] Every datastore has an owning service (D1); every Cache has an owner and a source (D4).
- [ ] The remaining entries (A3-A5, B3, C2-C3, D2-D3, E1-E4) have been considered and any match flagged.

## Visual composition

- [ ] Mermaid is the only final diagram format.
- [ ] The diagram uses 3-5 subgraphs to group the architectural layers.
- [ ] The primary happy path reads left-to-right.
- [ ] Exception paths are placed below the primary flow and remain limited.
- [ ] Supporting services sit above or below the primary flow, with storage next
  to its owner.
- [ ] Labels are compact and identify only material decisions or mode changes.
- [ ] Event Bus or Queue components do not form star-shaped hubs; boxes normally
  have one or two outgoing edges.
- [ ] Long backward loops and crossing edges have been removed or simplified.
- [ ] A second focused Mermaid view is present only when the primary HLD has >16
  logical blocks or >2 exception branches; otherwise it is omitted.

## Presales and readability

- [ ] The design remains an HLD, not an LLD: it explains responsibilities,
  boundaries, and decisions without implementation-level detail.
- [ ] One baseline is recommended; no more than two alternatives are included,
  each with a condition and trade-off.
- [ ] Risks and open questions state their effect on scope, estimate, or architecture.
- [ ] The diagram normally has 8-16 boxes, grouped as Client, Core, Async-Data,
  and External when applicable.
- [ ] A larger diagram is explicitly justified, or split into focused views.
