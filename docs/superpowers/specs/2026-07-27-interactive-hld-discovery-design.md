# Interactive HLD Discovery — Design

## Problem

The `/hld:requirements` command is a single-shot prompt injection: it receives a
one-line fuzzy task and is told to capture supplied facts, label the rest, and
"write requirements.md and stop." Because nothing forces a dialogue, the model
fills `Confirmed inputs` and `Functional requirements` from thin air. The design
step (`/hld:design`) then spends tokens building an HLD on top of hallucinated
requirements.

Goal: turn step 1 into an **interactive discovery interview** that extracts
concrete requirements before any design work, so the design is built on stated
facts and explicit assumptions — not invented ones.

Context: this skill is demoed live at a Google Developer Group talk. The flow
must be legible to an audience and controllable for timing.

## Approach

Keep the existing two-command structure. Change only the behavior of step 1 from
"fire and forget" to a guided interview, preserving the explicit gate between
requirements and design.

- **Act 1 — `/hld:requirements "fuzzy task"`**: runs an interview in chat. The
  model does not write a file immediately. It asks one question at a time, walks
  a fixed category frame, labels every answer, shows progress, and at the end
  renders the full `requirements.md` draft and waits for explicit approval before
  writing the file.
- **Act 2 — `/hld:design`**: unchanged. Reads the approved `requirements.md`,
  writes `hld.md`.

The gate between acts is the core defense against "design from hallucinations."

## Interview design

### Frame (hybrid)

A fixed frame of **6 categories**; within each category the model adapts and may
skip questions that are irrelevant to the task.

| # | Category | Covers |
|---|----------|--------|
| 1 | Business outcome & scope | why the system exists, success criteria, what is out of scope |
| 2 | Users & journeys | who uses it, key journeys |
| 3 | Functional scope | core capabilities the system must provide |
| 4 | Scale & performance | volume, latency, throughput, freshness |
| 5 | Data & integrations | data sources, external systems (CRM/APIs) |
| 6 | Security & constraints | access control, compliance, budget, delivery constraints |

Progress "covered N/6" is shown after each category.

### One question at a time (demo-friendly pacing)

Questions are asked one at a time so the audience can follow the task taking
shape. Each question offers 3-4 concrete options plus an explicit
"Don't know / not important yet" option:

```
[Category 4/6 · Scale & performance]
Expected request volume?
  A) < 10 req/s (internal tool)
  B) ~100-1000 req/s (production service)
  C) > 10 000 req/s (high-load)
  D) Don't know / not important yet
```

### Labeling (anti-hallucination core)

After each answer the model assigns and states a label:

- User picked a concrete option (A/B/C) → **Confirmed**
- User picked "Don't know" but the design needs a value → **Assumption**, stated
  explicitly and out loud ("assuming ~100 req/s, correct later")
- User picked "Don't know" and it is genuinely unresolved → **Unknown**, moved to
  open questions

**Hard rule in the prompt: nothing becomes Confirmed without the user's words.**
This is the mechanism that prevents invented facts.

### Stopping condition & gate

- After each category: "Covered N/6. Enough for design, or continue?" — lets the
  presenter cut the interview short live to fit timing.
- At the end (or on early exit): the model renders the full `requirements.md`
  draft in chat with three clearly separated blocks — Confirmed / Assumption /
  Unknown — and waits for the user's explicit "ok" before writing the file.

## Repository changes

- **`commands/hld/requirements.toml`** — rewrite the prompt: instead of "capture
  facts and stop," instruct the model to run the discovery interview per the
  protocol and write the file only after approval. Keep the `.toml` thin.
- **`skills/ml-system-hld/references/discovery-interview.md`** *(new)* — the
  interview protocol: the 6 categories, the labeling rules, the question-with-
  options format, the progress indicator, and the approval gate.
- **`skills/ml-system-hld/SKILL.md`** — add a short pointer to the new reference
  in the workflow.
- **`assets/requirements-template.md`** — minor edits so the claim ledger
  (Confirmed / Assumption / Unknown) maps cleanly from the interview.
- **`README.md`** — update the usage section to describe the interactive flow.
- **`/hld:design`** — unchanged.

## Out of scope

- Merging the two commands or adding a third `/hld:review` command.
- Changing the design step, the HLD template, or the Mermaid visual contract.
- Batching questions or presenting all questions at once (one-at-a-time chosen
  for demo legibility).
