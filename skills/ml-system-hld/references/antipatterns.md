# Architecture Anti-Patterns

Apply this during diagram composition and again in the topology review before
writing `hld.md`. First compose edges from each component's **Typical
interactions** in the [component catalog](component-catalog.md); then check the
diagram against every entry below.

Each entry has an **Action** that says what to do on a match:

- **auto-fix** — redraw to the *Correct* form and add a one-line note
  "Applied pattern: <name>" in the rationale.
- **fix+note** — redraw to *Correct* and add one assumption line stating what
  must hold (for example, who issues the pre-signed URL).
- **flag-as-risk** — leave the design and add a risk or open question.

Never present an auto-fix as a confirmed requirement; it is a default topology,
stated as such.

## A. Trust boundaries & security

### A1. Unmediated client-to-data access
- Smell: a client box (Web UI, external API caller) has an edge writing or reading Object Storage or a database directly.
- Why wrong: bypasses authentication, authorization, validation, and quotas; exposes the datastore's trust boundary to the internet.
- Correct: client -> API Gateway / Edge -> Backend for Frontend / Core Domain Service -> datastore. The service owns the store.
- Exception: large-file upload/download may go directly to Object Storage using a backend-issued, scoped, time-limited pre-signed URL. The diagram must still show the authenticated service that issues the URL and the trust boundary.
- Action: fix+note.

### A2. Client with no auth/edge
- Smell: an external actor reaches internal components with no API Gateway / Edge and no Identity & Access on the path.
- Why wrong: no authentication, rate limiting, or protocol governance at the boundary; every internal service is internet-exposed.
- Correct: place API Gateway / Edge as the outermost boundary and Identity & Access on the entry path before any internal component.
- Exception: a purely internal system with no external actors in scope — state that scope explicitly.
- Action: auto-fix.

### A3. Publicly reachable internal service
- Smell: a service that should be internal (worker, model server, database proxy) sits on the external perimeter with a direct client edge.
- Why wrong: enlarges the attack surface; internal services rarely have edge-grade hardening.
- Correct: keep internal services behind the Edge; expose only the intended API surface.
- Exception: an intentionally public endpoint (for example, a public webhook receiver) — mark it and its hardening.
- Action: flag-as-risk.

### A4. No secrets/key management for external dependencies
- Smell: components call external providers, sign, or encrypt, but there is no Secrets / Key Management in the diagram.
- Why wrong: implies credentials embedded in code or config; no rotation or controlled access.
- Correct: add Secrets / Key Management with restricted links to the components that need credentials or keys (for example, Model API Proxy, Integration Adapter).
- Exception: no sensitive credentials or cryptographic boundary in scope — state it.
- Action: flag-as-risk.

### A5. Implicit service-to-service trust
- Smell: components at different trust levels call each other with no boundary, gateway, or identity check between them.
- Why wrong: lateral-movement risk; a compromised low-trust component reaches high-trust data.
- Correct: put an authorization or identity check (Rights check or Identity & Access) where trust levels differ.
- Exception: all components share one trust zone and compliance does not require internal segmentation — state it.
- Action: flag-as-risk (when compliance or security is a driver).

## B. Model / AI access

### B1. Redundant model/proxy split
- Smell: Model API Proxy and Model / Embeddings drawn as two parallel targets that callers choose between.
- Why wrong: defeats the proxy's purpose — it exists to be the single boundary in front of model capabilities, both self-hosted and external.
- Correct: callers -> one model-access boundary (Model API Proxy); behind it sit self-hosted Model / Embeddings and/or external providers.
- Exception: none for presales HLD — this is always a modelling error.
- Action: auto-fix.

### B2. Direct external-provider call bypassing the proxy
- Smell: an application service calls an external model/LLM provider directly, alongside a Model API Proxy used elsewhere.
- Why wrong: no single point for policy, secrets, cost control, rate limiting, or observability; inconsistent governance.
- Correct: route all external model calls through Model API Proxy.
- Exception: a one-off, clearly bounded call with its own justification — note it.
- Action: auto-fix.

### B3. Synchronous long/expensive model call on the request path
- Smell: a user request synchronously invokes a slow or expensive model at high volume with a tight latency target and no queue.
- Why wrong: latency and cost spikes propagate to the user; no back-pressure.
- Correct: consider async via Queue with a result callback or poll, caching of results, or a smaller/cheaper model on the hot path.
- Exception: low volume and a latency budget that comfortably covers the model call — state the assumption.
- Action: flag-as-risk.

## C. Async & reliability

### C1. Async path without DLQ -> Review
- Smell: Queue or Event Bus consumers with no failure branch.
- Why wrong: a poison message blocks the consumer or is silently dropped; no recovery.
- Correct: add a DLQ -> Review branch off the async consumer for exhausted or invalid messages.
- Exception: none material at HLD level for a real async path.
- Action: auto-fix (add branch).

### C2. No idempotency on an at-least-once consumer
- Smell: at-least-once delivery (Queue / Event Bus) with a consumer that has visible side effects and no dedup or idempotency note.
- Why wrong: duplicate deliveries cause double-processing.
- Correct: note idempotent handling (dedup key or idempotency store) on the consumer.
- Exception: the consumer is naturally idempotent (a pure upsert by key) — state it.
- Action: flag-as-risk.

### C3. Missing retry/timeout on an external dependency
- Smell: a synchronous call to an external system or provider with no timeout or retry indicated where reliability matters.
- Why wrong: a slow dependency stalls the caller; transient failures become hard failures.
- Correct: note a timeout plus bounded retry (and circuit-breaking if the driver warrants).
- Exception: a non-critical best-effort call — state it.
- Action: flag-as-risk.

> The Queue / Event Bus **star-hub** smell (a bus or queue with many fan-out
> edges) is covered by the visual-composition checklist in
> [architecture-review.md](architecture-review.md); apply it there rather than
> duplicating it here.

## D. Data & ownership

### D1. Datastore with no owning service
- Smell: a store (Operational Database, Object Storage) is read and written by many services with no single owner.
- Why wrong: shared mutable state, hidden coupling, and a single point of failure — a distributed monolith.
- Correct: give each store one owning service; other services reach it through that owner's API or events.
- Exception: a read-only derived store (Analytical Store, Search Index) fed from a source of record and read by many — that is fine.
- Action: flag-as-risk.

### D2. Shared operational database across services
- Smell: two or more Core Domain Services write the same Operational Database.
- Why wrong: couples the services' schemas and releases; breaks independent evolution.
- Correct: one operational store per owning service; integrate via events or APIs.
- Exception: a deliberate modular-monolith scope — state it.
- Action: flag-as-risk.

### D3. Wrong store for the job
- Smell: Object Storage used for small, highly relational, transactional records; or Operational Database used for large binary or media content.
- Why wrong: a poor fit for the access pattern — either no transactions and queries, or bloated and expensive rows.
- Correct: relational/transactional -> Operational Database; large immutable/file content -> Object Storage; historical/analytical -> Analytical Store.
- Exception: a stated constraint forcing the choice — note it.
- Action: flag-as-risk.

### D4. Cache with no owner or invalidation source
- Smell: a Cache sits in the diagram with no service that owns its validity or populates and invalidates it.
- Why wrong: stale reads with no story for correctness.
- Correct: show the owning service that reads through and invalidates the cache, and the source it fronts.
- Exception: none material — a cache always needs an owner.
- Action: fix+note.

## E. Coupling & composition

### E1. Chatty synchronous chains
- Smell: a deep chain of synchronous service-to-service calls to satisfy one request.
- Why wrong: latency adds up, failures cascade, and services are tightly, temporally coupled.
- Correct: collapse responsibilities, use an aggregating service, or move steps async via Queue / Event Bus where eventual consistency is acceptable.
- Exception: a genuinely short, latency-tolerant chain — state it.
- Action: flag-as-risk.

### E2. God-box
- Smell: one component labelled to do many unrelated things (ingest + score + notify + persist + report).
- Why wrong: no clear boundary; untestable; a change-magnet.
- Correct: split into components with single responsibilities from the catalog.
- Exception: an intentionally coarse HLD box that maps to one bounded capability — state it.
- Action: fix (split) or flag-as-risk when the split is uncertain.

### E3. No BFF for divergent clients
- Smell: web, mobile, and partner clients all hit one generic API that does heavy client-specific aggregation.
- Why wrong: one contract serving conflicting needs churns constantly and couples the clients.
- Correct: add a Backend for Frontend per client experience where aggregation diverges.
- Exception: a single client, or clients whose needs are genuinely uniform — state it.
- Action: flag-as-risk.

### E4. Missing observability
- Smell: a system whose NFRs demand reliability or latency SLAs has no Observability component.
- Why wrong: no way to detect, diagnose, or measure against the SLAs.
- Correct: add a cross-cutting Observability component lightly connected to the major runtime elements.
- Exception: observability explicitly out of scope for the HLD — state it.
- Action: flag-as-risk.
