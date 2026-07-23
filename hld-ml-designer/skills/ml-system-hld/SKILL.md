---
name: ml-system-hld
description: Use when designing a high-level architecture (HLD) for an ML or AI system — search, recommendation, content moderation, computer vision, RAG or GenAI. Turns functional and non-functional requirements into a markdown design with a Mermaid diagram by reusing a catalog of standard building blocks. Triggers on "high-level design", "HLD", "system design", "architecture", "ML system", "pre-sale design".
---

# ML System High-Level Design

Produce an HLD as **markdown + a Mermaid diagram** by matching requirements to
reusable blocks. Never invent bespoke boxes when a catalog block fits.

## Inputs and outputs
- Input: an approved `requirements.md` (shape: `assets/requirements-template.md`).
- Output: `hld.md` (shape: `assets/hld-template.md`).

## Design loop
1. **Read the requirements.** Extract: task type (search / recsys / moderation /
   GenAI-RAG / real-time CV), throughput (QPS or items/min), latency budget (p95),
   data freshness, human-in-the-loop need, access control.
2. **Pick the master pattern** from `references/patterns.md` — decide if you need an
   offline Indexing/Ingestion pipeline plus an online Serving pipeline (usually yes),
   and pick the closest archetype skeleton.
3. **Decompose into catalog blocks** from `references/component-catalog.md`. Map each
   NFR to a block: tight p95 → `Cache` + `Load Balancer`; interval freshness →
   `Scheduler`; async/bursty ingest → `Queue`; similarity → `Vector DB`; shared
   features → `Feature Store`; quality → `Re-ranking service`; low confidence →
   `DLQ → Review`; per-user access → `Rights check`; external LLM → `Model API Proxy`.
4. **Assemble the Mermaid diagram**: ingestion left→right into the store; request
   enters from the right through `Load Balancer` → `Workflow Manager` → downstream.
   Use canonical block names as node labels.
5. **Justify**: fill the NFR→design table so every NFR names the block that satisfies it.
6. **Fill `hld.md`** from the output template. Flag anything ambiguous under Open questions.

## Guidance
- Study `references/examples.md` before designing — reuse its shape and vocabulary.
- Prefer fewer, standard blocks. Only add a non-catalog component with a one-line reason.
- Keep the diagram readable: group ingestion and serving; avoid crossing edges where possible.
