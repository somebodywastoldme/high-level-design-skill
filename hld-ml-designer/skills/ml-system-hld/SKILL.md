---
name: ml-system-hld
description: Use when creating vendor-neutral presales HLD or solution architecture for general software and data systems, including API/SaaS, integration, enterprise workflows, data platforms, and ML/AI.
---

# ML System High-Level Design

Create a decision-ready presales HLD: a clear baseline architecture, bounded
alternatives, explicit uncertainty, and questions that materially affect scope,
estimate, or architecture. Keep it at HLD level; do not turn it into an LLD.

## Inputs and outputs

- Read `requirements.md` before designing.
- Produce `hld.md` using the expected project template when one is available.
- Treat missing requirements as questions or assumptions, never as facts.

## Workflow

1. Classify the drivers: business outcome, users and journeys, functional scope,
   scale and latency, data and freshness, integrations, security and compliance,
   operations, and delivery constraints.
2. Create a claim ledger. Label every material claim **Confirmed**,
   **Assumption**, or **Unknown**. Do not invent exact performance, cost, capacity,
   or delivery values.
3. Select the domain reference that best fits the request. Load examples only for
   the matching domain; do not load examples by default.
4. Choose one baseline architecture that best fits the drivers, and at most two
   conditional alternatives, each tied to a specific trigger or trade-off.
5. Diagram planning: silently select one primary flow, classify blocks into
   layers, order the happy path, limit exceptions, remove implementation-only
   edges, and inspect backward or crossing edges before writing Mermaid. Mermaid
   is the only final diagram format. Use one primary Mermaid HLD view; add a
   second focused Mermaid view only when the primary HLD has >16 logical blocks
   or >2 exception branches. Use 3-5 subgraphs, keep the happy
   path left-to-right, place exceptions below and supporting services above or
   below, and keep storage next to its owner. Avoid Event Bus or Queue stars;
   boxes normally have one or two outgoing edges, and edge labels identify only
   material decisions or mode changes.
6. Compose the diagram from catalogued logical components. Give every box a
   purpose and show only the responsibilities and interfaces needed for the HLD.
7. Apply the [architecture review](references/architecture-review.md) before
   writing `hld.md`; resolve gaps, record assumptions, or add open questions.
8. Write the HLD with the baseline, conditional alternatives, claim ledger,
   rationale, risks, and questions that affect scope, estimate, or architecture.

## Reference selection

Use these references directly:

- [Component catalog](references/component-catalog.md) for logical components.
- [Architecture review](references/architecture-review.md) before finalizing.
- [Product integration patterns](references/patterns-product-integration.md) for
  product-facing integrations.
- [Data reliability patterns](references/patterns-data-reliability.md) for data
  movement, quality, and reliability.
- [ML and AI patterns](references/patterns-ml-ai.md) for ML, AI, RAG, and model
  serving systems.
- [ML and AI examples](references/examples-ml-ai.md) only for matching ML or AI
  domains.
- [Enterprise examples](references/examples-enterprise.md) only for matching
  enterprise domains.

## HLD quality bar

- Make the baseline traceable to the classified drivers and the claim ledger.
- Prefer a readable diagram of 8-16 boxes. Group boxes as Client, Core,
  Async-Data, and External where applicable; justify any larger diagram.
- State ownership, external boundaries, and material failure or retry paths when
  relevant.
- Address security and observability when relevant to the drivers or risk.
- Keep alternatives conditional and concise; do not present an unbounded option
  list or implementation-level detail.
