# Architecture Anti-Patterns & Topology Gate — Design

## Problem

The design step (`/hld:design`) produces architecturally nonsensical topologies:
a Web UI writing directly to Object Storage with no auth boundary, client-facing
components with no API Gateway / Identity in front, and `Model API Proxy` drawn
as a sibling of `Model / Embeddings` instead of the single boundary in front of
model capabilities. The component catalog already encodes correct topology in its
"Typical interactions" fields, but the design step freestyles edges and nothing
reviews the result. `architecture-review.md` has only generic quality gates, no
concrete anti-pattern rules.

Goal: give the skill an explicit **anti-pattern catalog** and a mandatory
**topology review gate** so the design step composes edges from the catalog and
then rejects or corrects known bad arrangements before writing `hld.md`.

## Approach

- New reference **`references/antipatterns.md`** — the catalog (≈20 entries,
  full prose per entry).
- **`architecture-review.md`** — new "Topology & anti-pattern review" section
  that runs the catalog as a checklist before `hld.md` is produced (workflow
  step 7 already applies this review).
- **`SKILL.md`** — a pointer to the new reference, plus a diagram-composition
  instruction: derive edges from the catalog's "Typical interactions," then run
  the anti-pattern gate.

### Enforcement model (hybrid)

Each anti-pattern carries an `Action`:

- **auto-fix** — hard violation; redraw to the canonical form and add a one-line
  note "applied pattern X." (e.g., insert Edge + Identity for an unauthenticated
  client; consolidate model access behind one proxy.)
- **fix+note** — correct it and add one assumption line, because a legitimate
  variant exists (e.g., direct-to-storage upload is fine via a backend-issued
  pre-signed URL — fix, and note the token-issuing boundary must be shown).
- **flag-as-risk** — context-dependent; leave the design but add a risk/question
  entry (the skill's existing uncertainty mechanism).

This matches the skill's ethos: never present a guess as a fact, and never
silently invent — but hard structural errors that no requirement justifies are
corrected to the canonical pattern.

### Entry format

Every catalog entry uses:

```
### <Name>
- Smell: what the bad diagram shows
- Why wrong: harm to scope / estimate / security / reliability
- Correct: the canonical form
- Exception: when the smell is legitimate and what must still be shown
- Action: auto-fix | fix+note | flag-as-risk
```

## Catalog (seed, ~20, grouped)

The user's three reported defects map to entries 1, 2, and 6. Entry numbers and
classifications are fixed here; full prose (Correct/Exception with a concrete
edge example) is authored in `antipatterns.md` during implementation.

### A. Trust boundaries & security
1. **Unmediated client→data access** — client writes Object Storage/DB directly. Exception: backend-issued pre-signed URL (show the issuing service + boundary). → fix+note
2. **Client with no auth/edge** — external actor reaches internal components with no API Gateway/Edge + Identity & Access. → auto-fix
3. **Publicly reachable internal service** — a service meant to be internal sits on the perimeter. → flag-as-risk
4. **No Secrets/KMS for external providers/credentials**. → flag-as-risk
5. **Implicit service-to-service trust** — no boundary where trust levels differ. → flag-as-risk (when compliance relevant)

### B. Model / AI access
6. **Redundant model/proxy split** — `Model API Proxy` and `Model / Embeddings` drawn as parallel call targets. Correct: one model boundary, self-hosted models and external providers behind it. → auto-fix
7. **Direct external-provider call bypassing the proxy** — no single policy/secrets/observability point. → auto-fix
8. **Synchronous long/expensive model call on the request path** under high volume with no queue. → flag-as-risk

### C. Async & reliability
9. **Async path without DLQ → Review** — Queue/Event Bus present, no failure branch. → auto-fix (add branch)
10. **No idempotency on an at-least-once consumer**. → flag-as-risk (HLD-level note)
11. **Queue/Event Bus star hub** — already covered in the visual-composition review; cross-reference, do not duplicate.
12. **External call with no retry/timeout**. → flag-as-risk

### D. Data & ownership
13. **Datastore with no owning service** — shared store behind many services (SPOF / distributed monolith). → flag-as-risk
14. **Shared operational DB across 2+ services**. → flag-as-risk
15. **Wrong store for the job** — Object Storage for small relational transactional data, or vice versa. → flag-as-risk
16. **Cache with no owner / invalidation source**. → flag-as-risk

### E. Coupling & composition
17. **Chatty synchronous chains** where async fits. → flag-as-risk
18. **God-box** — one component with too many responsibilities. → fix (split) / flag-as-risk
19. **No BFF for divergent clients** — web+mobile+partner on one generic API with heavy client-specific aggregation. → flag-as-risk
20. **Missing Observability** when NFRs demand it. → flag-as-risk

## Sources

- Perera — A Deeper Look at Software Architecture Anti-Patterns
- Sculley et al. — Hidden Technical Debt in ML Systems (NeurIPS 2015)
- NCSC — Security Architecture Anti-patterns white paper
- OWASP — Secure Cloud Architecture Cheat Sheet
- IBM — Event-driven DLQ pattern
- DesignGurus — 10 Common Microservices Anti-Patterns

## Verification

- Structural: `antipatterns.md` has all ~20 entries in the fixed format; each has
  an `Action`; `architecture-review.md` references the catalog; `SKILL.md` points
  to it.
- Acceptance (manual, either platform): re-run `/hld:design` on an image-
  moderation brief and confirm the produced `hld.md` no longer shows client→
  Object Storage without a boundary, always fronts external clients with
  Edge+Identity, and shows one model-access boundary rather than a proxy/model
  sibling split — with correction notes where auto-fix applied.

## Out of scope

- Changing the interview step, the requirements template, or the HLD output
  contract (`hld-template.md`).
- Adding new catalog components; anti-patterns reference existing components only.
- Enforcing anti-patterns as code/linting — this is prompt-level review guidance.
