# ML System High-Level Design — Gemini CLI Skill (Design Spec)

**Date:** 2026-07-23
**Author:** s.sukhomlyn
**Context:** Tool/skill for a Google Developer Group "Build with AI" engineering-track workshop.
**Status:** Approved design — ready for implementation planning.

## 1. Goal

Build a Gemini CLI extension that lets an engineer produce a **High-Level Design (HLD)
for an ML/AI system** at the pre-sale stage — fast, low-effort, in pair with the LLM.

Core thesis (validated against 5 reference diagrams): **most HLD building blocks are
patterns that repeat across ML systems.** If they repeat, they can be templated and fed
to an LLM so it recognizes the patterns and assembles the architecture itself.

Constraint: **must target Gemini CLI only** (no Claude / OpenAI tooling).

## 2. Non-Goals (YAGNI)

- Not a slide deck / presentation generator.
- Not a low-level design, code generation, or IaC.
- No pretty draw.io/XML rendering in v1 (markdown + Mermaid is enough; revisit later).
- No fully-autonomous "AI invents the whole problem" flow — requirements stay a
  human-in-the-loop step.

## 3. Output Format

- Primary artifact: **markdown document with an embedded Mermaid diagram.**
  - Rationale: LLM generates Mermaid reliably and deterministically; renders directly in
    GitHub/IDE; git-versionable; instant visual result at the workshop with no special
    software.
- draw.io XML explicitly deferred (LLM generates XML unstably; risky on stage).

## 4. Workflow (two explicit steps)

Chosen over a single free-form dialogue because it is predictable for a live demo and
teaches the correct order: requirements first, design second.

```
/hld:requirements "<short task description>"
        │  Gemini loads the FR/NFR template, drafts requirements,
        │  shows them to the user for edit/approval
        ▼
   requirements.md          (artifact in the working folder)
        │
/hld:design
        │  Gemini reads requirements.md, matches requirements against
        │  the component catalog + patterns, assembles the architecture
        ▼
   hld.md                   (markdown: narrative + Mermaid diagram + rationale)
```

Each step leaves a file artifact so the flow is inspectable and recoverable mid-demo.

## 5. Packaging — Gemini CLI Extension

One extension bundling one skill + two commands. Skill is the core (model-triggered,
progressive disclosure); commands are explicit entry points; the extension is the
distribution wrapper for GitHub.

```
hld-ml-designer/
├── gemini-extension.json               # manifest (name, version, contextFileName?)
├── skills/
│   └── ml-system-hld/
│       ├── SKILL.md                    # CORE: HLD design methodology ("how to think")
│       ├── references/
│       │   ├── component-catalog.md    # ~12 reusable blocks (the central thesis)
│       │   ├── patterns.md             # master pattern + 5 archetype skeletons
│       │   └── examples.md             # the 5 reference systems as few-shot
│       └── assets/
│           ├── requirements-template.md
│           └── hld-template.md
└── commands/
    └── hld/
        ├── requirements.toml           # /hld:requirements
        └── design.toml                 # /hld:design
```

Distribution at the workshop: `git clone` into `~/.gemini/extensions/`, or
`gemini extensions install <repo-url>`. (The `hld-ml-designer` folder becomes its own git
repo — do **not** commit into the machine-wide `D:/` repo.)

### Gemini CLI facts this relies on (verified 2026-07-23)

- **Agent Skills** use `skills/<name>/SKILL.md` with YAML frontmatter (`name`,
  `description`) + markdown body; optional `references/`, `assets/`, `scripts/`
  subdirs. `description` is what Gemini uses to decide when to trigger the skill — must
  be specific with trigger keywords. Same SKILL.md format as Anthropic → portable.
- **Custom commands** are `.toml` files under `commands/`; subdirectories create
  `namespace:command` names (`commands/hld/design.toml` → `/hld:design`). Required field
  `prompt`; optional `description`. Argument injection via `{{args}}`; shell injection via
  `!{...}` (auto-escaped); file injection via `@{...}` (multimodal, respects gitignore).
- **Extension manifest** `gemini-extension.json`: `name`, `version`, optional
  `contextFileName`, `mcpServers`, `settings`. `${extensionPath}` substitutes the
  extension's absolute path.

## 6. Skill methodology (encoded in SKILL.md)

Short body; heavy detail lives in `references/` (progressive disclosure). Design loop:

1. **Read requirements** → extract: task type (search / recsys / moderation / GenAI /
   real-time CV), volumes (throughput, QPS), latency budget, data freshness,
   human-in-the-loop need, access control.
2. **Pick the master pattern**: does it need an offline `Indexing/Ingestion pipeline`
   plus an online `Serving pipeline`? (Almost always yes.)
3. **Decompose into catalog blocks** — map each requirement to a component
   (low latency → `Cache` + `Load Balancer`; hourly freshness → `Scheduler` / streaming
   ingestion; model uncertainty → `DLQ → Review service`; etc.).
4. **Assemble the Mermaid diagram** following flow-direction rules (ingestion
   left-to-right into the index; request right-side through LB → Workflow Manager → …).
5. **Justify**: for each NFR explicitly name the block that satisfies it
   (requirement → component traceability).

## 7. Component catalog (references/component-catalog.md)

12 reusable blocks, each a card with: *purpose · when to include (which NFR it
satisfies) · typical technologies · how it is drawn on the diagram.*

`Load Balancer` · `Workflow Manager (orchestrator)` · `Queue` · `Cache
(semantic/results)` · `Vector DB / Index` · `Feature Store` · `Model / Embeddings
service` · `Re-ranking service` · `Scheduler (batch)` · `Rights / Access check` ·
`DLQ → Review (human-in-the-loop)` · `Model API Proxy (LLM provider)`.

## 8. Patterns (references/patterns.md)

- **Master pattern:** Indexing/Ingestion pipeline (offline) ↔ Serving pipeline (online).
- **5 archetype skeletons:** Search · Recommender · Content-moderation · RAG/GenAI
  chatbot · Real-time CV.

## 9. Examples (references/examples.md)

The 5 reference systems from `assets/` as few-shot pairs (text requirements → finished
HLD): video search, recommender, image/video moderation + smart-cart CV, GenAI chatbot
(RAG) + image generation.

## 10. Requirements template (assets/requirements-template.md)

- **Functional (FR):** what the system does — API, inputs/outputs, languages, scenarios.
- **Non-Functional (NFR):** latency (p95), throughput (QPS / per-minute), data freshness,
  availability, access control, cost, privacy.

NFRs are what determine block selection — the whole "matching magic" hangs on them.

## 11. Success criteria

- From a one-line task description, `/hld:requirements` produces a sensible, editable
  FR/NFR draft.
- From approved requirements, `/hld:design` produces `hld.md` with a valid,
  renderable Mermaid diagram and an NFR→component rationale table.
- A workshop attendee can clone the repo, register the extension, and get from task to
  HLD in a single short session.
- The two demo steps are recoverable if the model drifts (artifacts on disk).
