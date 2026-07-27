# Architecture Anti-Patterns & Topology Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the HLD skill an anti-pattern catalog and a mandatory topology review gate so `/hld:design` composes correct edges and corrects/flags known bad arrangements before writing `hld.md`.

**Architecture:** Add a new shared reference `skills/ml-system-hld/references/antipatterns.md` (≈20 full entries). Wire it into `architecture-review.md` as a "Topology & anti-pattern review" section (workflow step 7 already applies that review) and add a pointer plus an edge-derivation instruction in `SKILL.md`. Both Gemini and Claude read the shared skill, so no command changes are needed.

**Tech Stack:** Markdown reference files in the shared `ml-system-hld` skill. No code, no test runner — verification is structural (all entries present, each has an Action, cross-references resolve) plus a manual `/hld:design` acceptance check.

## Global Constraints

- Additive to the shared skill only. Do NOT change the interview step, `requirements-template.md`, `hld-template.md`, or any command file (`.toml`/`.md`).
- Reference existing catalog components only; do NOT invent new components.
- Enforcement is hybrid: each entry carries an `Action` of `auto-fix`, `fix+note`, or `flag-as-risk`. Never present an auto-fix as a confirmed requirement — it is a default topology, stated as such.
- Entry format is fixed: `Name`, `Smell`, `Why wrong`, `Correct`, `Exception`, `Action`.
- The Queue/Event Bus star-hub smell stays in the visual-composition review; the catalog cross-references it, does not duplicate it.
- Preserve valid Markdown.

---

## Target file structure

```
skills/ml-system-hld/
├── SKILL.md                              # MODIFY: pointer + edge-derivation note
└── references/
    ├── antipatterns.md                    # CREATE: the catalog (~20 entries)
    └── architecture-review.md             # MODIFY: add topology & anti-pattern review section
```

**Verification note (every task):** No automated test runner. "Failing check" = a structural check that fails before the change and passes after. Use `rg` for content checks.

---

### Task 1: Create the anti-pattern catalog

**Files:**
- Create: `skills/ml-system-hld/references/antipatterns.md`

**Interfaces:**
- Produces: the reference path `references/antipatterns.md` and the entry IDs `A1-A5, B1-B3, C1-C3, D1-D4, E1-E4` that `architecture-review.md` (Task 2) cites in its checklist.

- [ ] **Step 1: Verify the file does not exist (failing check)**

Run: `test -f skills/ml-system-hld/references/antipatterns.md && echo EXISTS || echo MISSING`
Expected: `MISSING`.

- [ ] **Step 2: Create `antipatterns.md`**

Write exactly:

```markdown
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
```

- [ ] **Step 3: Verify all entry IDs and the format are present (passing check)**

Run: `rg -n "^### (A[1-5]|B[1-3]|C[1-3]|D[1-4]|E[1-4])\." skills/ml-system-hld/references/antipatterns.md | wc -l`
Expected: `19`.

- [ ] **Step 4: Verify every entry has an Action line (passing check)**

Run: `rg -c "^- Action:" skills/ml-system-hld/references/antipatterns.md`
Expected: `19`.

- [ ] **Step 5: Verify the star-hub cross-reference and no new components invented (passing check)**

Run: `rg -n "star-hub|architecture-review.md|component-catalog.md" skills/ml-system-hld/references/antipatterns.md`
Expected: matches on the star-hub note and both cross-references.

- [ ] **Step 6: Commit**

```bash
git add skills/ml-system-hld/references/antipatterns.md
git commit -m "feat: add architecture anti-pattern catalog"
```

---

### Task 2: Wire the topology gate into the architecture review

**Files:**
- Modify: `skills/ml-system-hld/references/architecture-review.md`

**Interfaces:**
- Consumes: entry IDs `A1-A5, B1-B3, C1-C3, D1-D4, E1-E4` from Task 1.
- Produces: the "Topology & anti-pattern review" section that workflow step 7 applies before `hld.md`.

- [ ] **Step 1: Verify the section is absent (failing check)**

Run: `rg -n "Topology & anti-pattern review|antipatterns.md" skills/ml-system-hld/references/architecture-review.md; echo "exit=$?"`
Expected: no matches, `exit=1`.

- [ ] **Step 2: Insert the topology section**

In `skills/ml-system-hld/references/architecture-review.md`, immediately after the `## Architecture` checklist block (before `## Visual composition`), insert:

```markdown
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
```

- [ ] **Step 3: Verify the section and IDs are present (passing check)**

Run: `rg -n "Topology & anti-pattern review|antipatterns.md|\(A1\)|\(B1\)|\(C1\)|\(D1\)" skills/ml-system-hld/references/architecture-review.md`
Expected: matches on the heading, the catalog link, and the cited IDs.

- [ ] **Step 4: Commit**

```bash
git add skills/ml-system-hld/references/architecture-review.md
git commit -m "feat: add topology and anti-pattern review gate"
```

---

### Task 3: Point SKILL.md at the catalog and require edge derivation

**Files:**
- Modify: `skills/ml-system-hld/SKILL.md`

**Interfaces:**
- Consumes: `references/antipatterns.md` (Task 1) and the topology section (Task 2).
- Produces: workflow wiring so the design step composes edges from the catalog and runs the gate.

- [ ] **Step 1: Verify SKILL.md does not mention the catalog (failing check)**

Run: `rg -n "antipatterns.md|Typical interactions" skills/ml-system-hld/SKILL.md; echo "exit=$?"`
Expected: no matches, `exit=1`.

- [ ] **Step 2: Add edge-derivation to the compose step**

In `skills/ml-system-hld/SKILL.md`, find workflow step 6, which reads:

```
6. Compose the diagram from catalogued logical components. Give every box a
   purpose and show only the responsibilities and interfaces needed for the HLD.
```

Replace it with:

```
6. Compose the diagram from catalogued logical components. Give every box a
   purpose and show only the responsibilities and interfaces needed for the HLD.
   Derive edges from each component's Typical interactions in the catalog rather
   than freehand, then screen the diagram with the
   [anti-pattern catalog](references/antipatterns.md).
```

- [ ] **Step 3: Add the reference bullet**

In the `## Reference selection` list, add this bullet immediately after the `[Architecture review]` bullet:

```markdown
- [Anti-pattern catalog](references/antipatterns.md) to screen diagram topology
  for known bad arrangements before finalizing `hld.md`.
```

- [ ] **Step 4: Verify the wiring (passing check)**

Run: `rg -n "antipatterns.md|Typical interactions in the catalog" skills/ml-system-hld/SKILL.md`
Expected: matches in both the workflow step and the reference list.

- [ ] **Step 5: Commit**

```bash
git add skills/ml-system-hld/SKILL.md
git commit -m "feat: wire anti-pattern catalog into HLD workflow"
```

---

### Task 4: Manual acceptance test (either platform)

**Files:** none (acceptance only).

**Interfaces:**
- Consumes: Tasks 1-3.

- [ ] **Step 1: Produce a brief**

In a scratch directory, create a minimal `requirements.md` (or run `/hld:requirements`) for: "moderate uploaded product images for unsafe content; internal staff use a web UI, external sellers use an API; uses a hosted model with a fallback provider."

- [ ] **Step 2: Run design**

```text
/hld:design
```

- [ ] **Step 3: Inspect `hld.md` against the reported defects**

Expected in the diagram and rationale:
- No edge from a client (Web UI, seller API) directly into Object Storage without an authenticated boundary; if direct upload is shown, a pre-signed-URL issuer and boundary are shown, with a fix+note assumption line (A1).
- External actors pass API Gateway / Edge and Identity & Access (A2).
- One model-access boundary (Model API Proxy) with the hosted model and fallback provider behind it — not a proxy/model sibling split (B1) and no direct provider call (B2), with an "Applied pattern" note where auto-fix ran.
- Any async consumer shows a DLQ -> Review branch (C1).

- [ ] **Step 4 (optional): Spot-check a flag-as-risk entry**

Confirm at least one context-dependent issue (for example, a synchronous model call under load, B3) appears as a risk or open question rather than being silently "fixed."

---

## Self-Review

- **Spec coverage:** catalog reference (Task 1) ✓; hybrid Action on every entry (Task 1 Step 4 guard) ✓; entry format fixed (Task 1) ✓; topology gate in architecture-review, applied by step 7 (Task 2) ✓; SKILL.md pointer + edge derivation (Task 3) ✓; user's 3 defects = A1/A2/B1 present and acceptance-checked (Task 4) ✓; star-hub cross-referenced not duplicated (Task 1 Step 5 + Global Constraints) ✓; no new components, no command/template changes (Global Constraints) ✓; sources captured in the spec ✓.
- **Placeholder scan:** the full `antipatterns.md` content is literal; no TBD/TODO; no "similar to" references.
- **ID consistency:** entry IDs `A1-A5, B1-B3, C1-C3, D1-D4, E1-E4` (19 entries) are used identically in Task 1 (definitions), Task 2 (checklist citations), and Task 4 (acceptance). Counts asserted as 19 in Task 1 Steps 3-4.
