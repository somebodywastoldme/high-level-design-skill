# Presales HLD Skill v2 — Design

## Goal

Evolve `hld-ml-designer` from an ML-diagram demo into a vendor-neutral
presales HLD skill. It must produce a concise, credible architecture narrative:
simple enough for a client conversation, but backed by explicit architectural
reasoning, alternatives, assumptions, risks, and discovery questions.

The default deliverable remains **Presales Lite**. It does not produce a low
level design, cloud deployment design, or provider/product mapping.

## Design principles

- Use logical components only. Names such as `API Gateway`, `Core Service`,
  `Workflow Manager`, `Policy Service`, `Cache`, `Queue`, `Object Storage`,
  `Operational Database`, `Search Index`, and `Notification Service` are
  appropriate. Cloud products, pods, networks, instance sizes, and deployment
  topology are out of scope.
- Keep diagrams minimally sufficient, not artificially small. A normal HLD has
  8–16 logical components; use up to about 20 when each component represents a
  meaningful business capability, NFR mechanism, data boundary, or external
  integration. Group components visually to preserve readability.
- Do not manufacture precision. Treat all unprovided values, costs, throughput
  peaks, model choices, timings, retention periods, and security controls as
  explicit assumptions or discovery questions.
- Prefer a recommended baseline and state at most two realistic alternatives.
  State the trade-off that would make an alternative preferable.
- Trace every material NFR to a design mechanism. Flag NFRs that cannot yet be
  satisfied because a client decision is missing.

## Skill workflow

1. Classify the system domain and identify its architectural drivers: user/API
   interaction, data flow, latency, throughput, consistency, integrations,
   security, availability, cost, and change rate.
2. Build an evidence ledger with three categories: confirmed inputs, explicit
   assumptions, and critical unknowns. Do not promote an assumption to a fact.
3. Select the primary pattern from the pattern library. Consider one or two
   alternatives only when they materially change cost, delivery risk, latency,
   consistency, or operating complexity.
4. Compose a logical HLD from reusable components. Separate synchronous,
   asynchronous, data, and external-system flows when relevant.
5. Validate the design against NFRs, failure modes, ownership/data boundaries,
   and operational concerns. Keep this analysis concise in the client artifact.
6. Write the Presales Lite output and Mermaid diagram. Surface risks and
   discovery questions rather than silently hiding uncertainty.

## Presales Lite output contract

`hld.md` must contain:

1. **Executive summary** — business outcome, proposed pattern, and scope.
2. **Confirmed inputs and assumptions** — distinct lists; include only material
   assumptions.
3. **Recommended architecture** — a short explanation of the chosen pattern.
4. **Architecture diagram** — vendor-neutral Mermaid HLD.
5. **Key decisions and trade-offs** — why the baseline fits and what it costs.
6. **Requirements → design rationale** — FR/NFR traceability.
7. **Discovery questions and risks** — prioritized questions that can change
   architecture or estimate.
8. **Optional alternatives** — no more than two, each with a trigger for use.

## Reference-library expansion

### Component catalog

Retain ML-specific components and add logical enterprise components:

- API Gateway / Edge, Identity & Access, Core Domain Service, Backend for
  Frontend, Workflow / Orchestration, Policy / Rules Service, Cache, Queue,
  Event Bus, Scheduler, Notification Service, Webhook Delivery, Object Storage,
  Operational Database, Analytical Store, Search Index, Integration Adapter,
  Audit Log, Observability, Secrets / Key Management, Human Review.

Every component card specifies purpose, use signals, avoid signals, interactions,
HLD drawing guidance, and NFRs it commonly addresses.

### Pattern library

Use a uniform pattern-card format: use when, avoid when, minimal logical blocks,
variants, trade-offs, failure/operational notes, discovery questions, and a
small Mermaid skeleton.

Add patterns in these groups:

- Product/API: API-first backend, backend-for-frontend, modular monolith,
  multi-tenant SaaS, asynchronous job processing.
- Integration: event-driven fan-out, workflow orchestration, saga, webhook
  integration, legacy strangler.
- Data: file ingestion, document processing, batch ETL, CDC, search/indexing,
  real-time streaming, operational analytics.
- Enterprise/reliability: approval workflow, audit trail, cache-aside,
  retry + dead-letter handling, transactional outbox, idempotent consumer,
  active-passive recovery.
- ML/AI: search, recommendation, content moderation, real-time CV, RAG/GenAI,
  agentic workflow.

### Worked examples

Keep the existing ML examples and expand to presales-oriented examples:

- B2B multi-tenant SaaS;
- document intake, OCR, validation, and human review;
- e-commerce order and inventory workflow;
- event-driven integration across multiple business systems;
- API platform with synchronous and asynchronous operations;
- data ingestion and analytics;
- real-time telemetry / IoT.

Each example includes requirements, confirmed inputs versus assumptions,
recommended pattern, one or two alternatives, a vendor-neutral HLD, risks, and
discovery questions. Examples must avoid unsupported numeric claims.

## Acceptance criteria

- Gemini creates a concise vendor-neutral HLD for ML and non-ML prompts.
- The output has the Presales Lite sections and clearly distinguishes facts from
  assumptions.
- Every recommendation explains a material trade-off and lists discovery
  questions.
- Mermaid diagrams represent logical components and preserve readability at
  8–16 components; higher counts are justified and grouped.
- Pattern and example libraries support the new domains without cloud-product
  names or LLD/deployment detail.
