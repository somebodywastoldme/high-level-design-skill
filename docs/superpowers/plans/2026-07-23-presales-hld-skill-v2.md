# Presales HLD Skill v2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Evolve `hld-ml-designer` into a vendor-neutral Presales Lite HLD skill that applies reusable architecture patterns across ML and non-ML systems.

**Architecture:** Keep `SKILL.md` procedural and compact. Store domain expertise in directly referenced, category-specific component, pattern, and example files. The `/hld:requirements` command creates an evidence-based discovery brief; `/hld:design` converts an approved brief into a concise HLD with explicit decisions, risks, and alternatives.

**Tech Stack:** Gemini CLI extension; Markdown; TOML custom commands; Mermaid `flowchart LR`; vendor-neutral logical architecture vocabulary.

## Global Constraints

- Produce Presales Lite, never LLD, cloud deployment topology, or cloud-vendor mapping.
- Use logical component names only; do not introduce cloud product names, pods, VPCs, instance sizes, or infrastructure configuration.
- Treat unprovided timing, cost, scale, retention, security, and model details as assumptions or discovery questions, never as facts.
- Use 8–16 logical components normally; use up to about 20 only when every component represents a material business capability, NFR mechanism, data boundary, or external integration. Group complex diagrams visually.
- Recommend one baseline architecture and at most two alternatives. Each alternative needs a condition that makes it preferable.
- Use canonical catalog component names verbatim in tables and Mermaid labels where the component is catalogued.
- Every HLD must map material NFRs to design mechanisms and flag unsatisfied NFRs caused by unresolved client decisions.
- Preserve valid TOML, JSON, YAML frontmatter, Markdown, and Mermaid syntax.

---

## Target file structure

```
hld-ml-designer/
├── README.md                                      # install + Presales Lite workflow
├── commands/hld/
│   ├── requirements.toml                           # discovery brief command
│   └── design.toml                                 # Presales Lite HLD command
└── skills/ml-system-hld/
    ├── SKILL.md                                    # workflow + reference routing
    ├── assets/
    │   ├── requirements-template.md                # evidence-led discovery brief
    │   └── hld-template.md                         # eight-section Presales Lite output
    └── references/
        ├── component-catalog.md                    # ML + enterprise logical components
        ├── architecture-review.md                  # decision / quality gates
        ├── patterns-product-integration.md         # API, SaaS, eventing, integration
        ├── patterns-data-reliability.md            # ingestion, data, resilience
        ├── patterns-ml-ai.md                       # improved existing ML/AI patterns
        ├── examples-ml-ai.md                       # revised five existing examples
        └── examples-enterprise.md                  # seven new presales examples
```

### Task 1: Replace the two output contracts and command prompts

**Files:**
- Modify: `hld-ml-designer/skills/ml-system-hld/assets/requirements-template.md`
- Modify: `hld-ml-designer/skills/ml-system-hld/assets/hld-template.md`
- Modify: `hld-ml-designer/commands/hld/requirements.toml`
- Modify: `hld-ml-designer/commands/hld/design.toml`

**Consumes:** Existing extension directory and the v2 design spec.

**Produces:** Stable markdown contracts that later `SKILL.md`, examples, and commands use.

- [ ] **Step 1: Replace `requirements-template.md` with a discovery brief template.**

  Use this exact section order:

  ```markdown
  # Discovery Brief: <system name>

  ## 1. Business outcome and scope
  ## 2. Confirmed inputs
  ## 3. Functional requirements
  ## 4. Quality attributes / NFRs
  ## 5. Assumptions to validate
  ## 6. Critical discovery questions
  ## 7. Out of scope
  ```

  Include a `Quality attributes / NFRs` table with columns `Attribute`,
  `Confirmed target`, `Why it matters`, `Status`. Use `Confirmed`,
  `Assumption`, and `Unknown` as status values. Include rows for latency,
  throughput/volume, freshness, availability, consistency, access control,
  privacy/compliance, integration constraints, and cost/budget.

- [ ] **Step 2: Replace `hld-template.md` with the eight-section Presales Lite contract.**

  Use this exact heading order:

  ```markdown
  # High-Level Design: <system name>
  ## 1. Executive summary
  ## 2. Confirmed inputs and assumptions
  ## 3. Recommended architecture
  ## 4. Architecture diagram
  ## 5. Key decisions and trade-offs
  ## 6. Requirements → design rationale
  ## 7. Discovery questions and risks
  ## 8. Optional alternatives
  ```

  Require a Mermaid `flowchart LR` block in section 4, a `Requirement | Design
  mechanism | Status / caveat` table in section 6, and an alternatives table
  with `Alternative | Prefer it when | Trade-off` in section 8.

- [ ] **Step 3: Rewrite `requirements.toml` to create a discovery brief, not an invented specification.**

  Keep `{{args}}`. Direct Gemini to activate `ml-system-hld`, use the skill's
  `assets/requirements-template.md`, label every missing fact as `Assumption`
  or `Unknown`, ask only the highest-impact questions, write `requirements.md`
  to the current workspace, and stop before architecture design.

- [ ] **Step 4: Rewrite `design.toml` to enforce the Presales Lite output.**

  Keep only `@{requirements.md}` file injection. Direct Gemini to activate the
  skill, select a baseline and no more than two conditional alternatives, use
  the eight-section template, preserve uncertainty, write `hld.md`, and explain
  which pattern and architectural drivers determined the recommendation.

- [ ] **Step 5: Run structural checks.**

  Run:

  ```powershell
  python -c "import tomllib; [tomllib.load(open(p,'rb')) for p in ['hld-ml-designer/commands/hld/requirements.toml','hld-ml-designer/commands/hld/design.toml']]; print('TOML OK')"
  Select-String hld-ml-designer/skills/ml-system-hld/assets/hld-template.md -Pattern '^## ' | Measure-Object
  ```

  Expected: `TOML OK`; exactly eight `##` headings in `hld-template.md`.

- [ ] **Step 6: Commit the contract update.**

  ```powershell
  git add hld-ml-designer/skills/ml-system-hld/assets hld-ml-designer/commands/hld
  git commit -m "feat: add presales lite HLD contracts"
  ```

### Task 2: Rebuild the skill workflow and add an architecture-review gate

**Files:**
- Modify: `hld-ml-designer/skills/ml-system-hld/SKILL.md`
- Create: `hld-ml-designer/skills/ml-system-hld/references/architecture-review.md`

**Consumes:** Task 1 templates and all reference-file names in the target structure.

**Produces:** A compact routing skill that makes evidence, pattern selection, diagram quality, and client-facing uncertainty mandatory.

- [ ] **Step 1: Write `architecture-review.md`.**

  Add three concise checklists:

  1. **Evidence check:** each statement is `Confirmed`, `Assumption`, or an
     `Unknown`; no fabricated exact performance/cost figures.
  2. **Architecture check:** baseline pattern fits drivers; each logical box has
     a purpose; sync/async, data ownership, external boundaries, retry/failure,
     security, and observability are considered where relevant.
  3. **Presales check:** diagram stays HLD; alternatives are conditional; risks
     and questions can influence scope, estimate, or architecture.

  Add a short `Diagram readability` subsection: 8–16 boxes normally, group by
  Client/Core/Async-Data/External when useful, and explain why any larger
  diagram is necessary.

- [ ] **Step 2: Replace `SKILL.md` with the v2 workflow.**

  Keep frontmatter name `ml-system-hld`; expand its description to trigger for
  presales architecture, solution design, system design, and HLD in addition to
  ML/AI prompts. The body must direct the agent to:

  1. read `requirements.md` and classify drivers;
  2. build the confirmed/assumption/unknown evidence ledger;
  3. select reference files by domain;
  4. choose one baseline and limited alternatives;
  5. compose an HLD from catalogued logical components;
  6. apply `architecture-review.md` before writing `hld.md`.

  Link directly to every reference file in the target structure. State that
  `examples-ml-ai.md` or `examples-enterprise.md` is read only when the domain
  matches; do not load both by default.

- [ ] **Step 3: Check references resolve and the skill stays focused.**

  Run:

  ```powershell
  $skill='hld-ml-designer/skills/ml-system-hld/SKILL.md'
  @('component-catalog.md','architecture-review.md','patterns-product-integration.md','patterns-data-reliability.md','patterns-ml-ai.md','examples-ml-ai.md','examples-enterprise.md') | ForEach-Object { if (Select-String -Path $skill -SimpleMatch $_ -Quiet) { "OK $_" } else { "MISSING $_" } }
  (Get-Content $skill).Count
  ```

  Expected: seven `OK` lines and fewer than 220 lines.

- [ ] **Step 4: Commit the workflow.**

  ```powershell
  git add hld-ml-designer/skills/ml-system-hld/SKILL.md hld-ml-designer/skills/ml-system-hld/references/architecture-review.md
  git commit -m "feat: add presales architecture review workflow"
  ```

### Task 3: Expand the logical component catalog

**Files:**
- Modify: `hld-ml-designer/skills/ml-system-hld/references/component-catalog.md`

**Consumes:** v2 component list and the workflow in Task 2.

**Produces:** One vendor-neutral catalog used verbatim in diagrams and design tables.

- [ ] **Step 1: Standardize every catalog card to this schema.**

  ```markdown
  ## <Canonical component name>
  **Purpose:** ...
  **Use when:** ...
  **Avoid / do not add when:** ...
  **Typical interactions:** ...
  **NFRs commonly addressed:** ...
  **Draw as:** ...
  ```

- [ ] **Step 2: Preserve and upgrade the twelve existing ML cards.**

  Keep these canonical names unchanged: `Load Balancer`, `Workflow Manager`,
  `Queue`, `Cache`, `Vector DB`, `Feature Store`, `Model / Embeddings`,
  `Re-ranking service`, `Scheduler`, `Rights check`, `DLQ → Review`, and
  `Model API Proxy`. Add the six schema fields to each.

- [ ] **Step 3: Add these enterprise canonical component cards.**

  Add exactly these headings: `API Gateway / Edge`, `Identity & Access`,
  `Core Domain Service`, `Backend for Frontend`, `Policy / Rules Service`,
  `Event Bus`, `Notification Service`, `Webhook Delivery`, `Object Storage`,
  `Operational Database`, `Analytical Store`, `Search Index`, `Integration
  Adapter`, `Audit Log`, `Observability`, `Secrets / Key Management`, and
  `Human Review`.

  Explain distinctions that prevent common HLD mistakes: Queue vs Event Bus;
  Workflow Manager vs Core Domain Service; DLQ → Review vs Human Review;
  Operational Database vs Analytical Store; Cache vs Search Index; API Gateway
  / Edge vs Load Balancer.

- [ ] **Step 4: Verify component-card completeness.**

  Run:

  ```powershell
  $p='hld-ml-designer/skills/ml-system-hld/references/component-catalog.md'
  'Purpose:','Use when:','Avoid / do not add when:','Typical interactions:','NFRs commonly addressed:','Draw as:' | ForEach-Object { "$_ $((Select-String -Path $p -SimpleMatch $_).Count)" }
  Select-String -Path $p -Pattern '^## ' | Measure-Object
  ```

  Expected: six field counts equal to the number of component headings; 29
  headings total.

- [ ] **Step 5: Commit the catalog.**

  ```powershell
  git add hld-ml-designer/skills/ml-system-hld/references/component-catalog.md
  git commit -m "feat: expand vendor-neutral component catalog"
  ```

### Task 4: Add product and integration pattern cards

**Files:**
- Create: `hld-ml-designer/skills/ml-system-hld/references/patterns-product-integration.md`

**Consumes:** Component catalog from Task 3.

**Produces:** Product/API and integration decision support.

- [ ] **Step 1: Establish the shared pattern-card schema.**

  Start the file with a short explanation and use this exact section shape for
  every pattern:

  ```markdown
  ## <Pattern name>
  **Use when:** ...
  **Avoid when:** ...
  **Minimal logical blocks:** ...
  **Variants:** ...
  **Trade-offs:** ...
  **Failure / operational notes:** ...
  **Discovery questions:** ...
  ```mermaid
  flowchart LR
  ```
  ```

- [ ] **Step 2: Add the product/API patterns.**

  Add `API-first backend`, `Backend for Frontend`, `Modular monolith`,
  `Multi-tenant SaaS`, and `Asynchronous job processing`. Ensure each Mermaid
  sketch has valid quoted labels and only logical catalog components plus a
  clearly named actor or external system.

- [ ] **Step 3: Add the integration patterns.**

  Add `Event-driven fan-out`, `Workflow orchestration`, `Saga`, `Webhook
  integration`, and `Legacy strangler`. Require a concrete trade-off between
  orchestration and choreography in the appropriate cards and state idempotency
  / delivery concerns where applicable.

- [ ] **Step 4: Validate structure and Mermaid basics.**

  Run:

  ```powershell
  $p='hld-ml-designer/skills/ml-system-hld/references/patterns-product-integration.md'
  "patterns=$((Select-String $p -Pattern '^## ').Count)"
  "diagrams=$((Select-String $p -SimpleMatch '```mermaid').Count)"
  "flowcharts=$((Select-String $p -SimpleMatch 'flowchart LR').Count)"
  ```

  Expected: `patterns=10`, `diagrams=10`, `flowcharts=10`.

- [ ] **Step 5: Commit the product/integration patterns.**

  ```powershell
  git add hld-ml-designer/skills/ml-system-hld/references/patterns-product-integration.md
  git commit -m "feat: add product and integration HLD patterns"
  ```

### Task 5: Add data and reliability pattern cards

**Files:**
- Create: `hld-ml-designer/skills/ml-system-hld/references/patterns-data-reliability.md`

**Consumes:** Component catalog from Task 3.

**Produces:** Data-flow and operational decision support without descending into LLD.

- [ ] **Step 1: Use the Task 4 pattern-card schema without changing its field names.**

- [ ] **Step 2: Add data patterns.**

  Add `File ingestion`, `Document processing`, `Batch ETL`, `Change data
  capture`, `Search / indexing`, `Real-time streaming`, and `Operational
  analytics`. State the boundary between operational and analytical data in the
  relevant cards.

- [ ] **Step 3: Add reliability patterns.**

  Add `Approval workflow`, `Audit trail`, `Cache-aside`, `Retry + dead-letter
  handling`, `Transactional outbox`, `Idempotent consumer`, and `Active-passive
  recovery`. Keep them logical: describe outcomes and responsibilities, not
  retry parameters or provider-specific recovery implementation.

- [ ] **Step 4: Validate the pattern count and references.**

  Run:

  ```powershell
  $p='hld-ml-designer/skills/ml-system-hld/references/patterns-data-reliability.md'
  "patterns=$((Select-String $p -Pattern '^## ').Count)"
  "diagrams=$((Select-String $p -SimpleMatch '```mermaid').Count)"
  Select-String $p -Pattern 'Queue vs Event Bus|Operational Database|Analytical Store|idempot' | Select-Object -First 6
  ```

  Expected: `patterns=14`, `diagrams=14`; output includes evidence that data
  boundaries and idempotency are covered.

- [ ] **Step 5: Commit the data/reliability patterns.**

  ```powershell
  git add hld-ml-designer/skills/ml-system-hld/references/patterns-data-reliability.md
  git commit -m "feat: add data and reliability HLD patterns"
  ```

### Task 6: Rework ML/AI patterns into the common presales format

**Files:**
- Delete: `hld-ml-designer/skills/ml-system-hld/references/patterns.md`
- Create: `hld-ml-designer/skills/ml-system-hld/references/patterns-ml-ai.md`

**Consumes:** Existing five ML patterns and Tasks 3–5 conventions.

**Produces:** ML/AI patterns that have the same decision depth as non-ML patterns.

- [ ] **Step 1: Migrate and deepen existing patterns.**

  Add `Search`, `Recommender`, `Content moderation`, `RAG / GenAI chatbot`, and
  `Real-time CV`. Preserve the Indexing ↔ Serving concept within the relevant
  cards rather than retaining it as a generic diagram. Add use/avoid signals,
  minimal blocks, variants, trade-offs, operational notes, discovery questions,
  and one Mermaid skeleton per card.

- [ ] **Step 2: Add `Agentic workflow`.**

  Make the card explicit that it suits bounded, tool-using, multi-step work;
  it is not the default for deterministic transaction flows. Include `Workflow
  Manager`, `Policy / Rules Service`, `Audit Log`, external tools, and human
  escalation only where relevant.

- [ ] **Step 3: Verify no old broken reference remains.**

  Run:

  ```powershell
  Test-Path hld-ml-designer/skills/ml-system-hld/references/patterns.md
  Select-String -Path hld-ml-designer/skills/ml-system-hld/SKILL.md -SimpleMatch 'patterns.md'
  $p='hld-ml-designer/skills/ml-system-hld/references/patterns-ml-ai.md'; "patterns=$((Select-String $p -Pattern '^## ').Count)"; "diagrams=$((Select-String $p -SimpleMatch '```mermaid').Count)"
  ```

  Expected: first command `False`; second command has no result; `patterns=6`;
  `diagrams=6`.

- [ ] **Step 4: Commit ML/AI pattern migration.**

  ```powershell
  git add -A hld-ml-designer/skills/ml-system-hld/references
  git commit -m "feat: deepen ML and AI HLD patterns"
  ```

### Task 7: Convert the five ML examples to presales exemplars

**Files:**
- Delete: `hld-ml-designer/skills/ml-system-hld/references/examples.md`
- Create: `hld-ml-designer/skills/ml-system-hld/references/examples-ml-ai.md`

**Consumes:** Existing examples, source diagrams in `assets/`, new templates, catalog, and ML/AI patterns.

**Produces:** Five vendor-neutral examples showing the desired final response style.

- [ ] **Step 1: Use one repeatable example structure.**

  For every example use:

  ```markdown
  ## Example: <Name>
  ### Scenario and confirmed inputs
  ### Material assumptions
  ### Recommended pattern and why
  ### Architecture diagram
  ### Key decisions and trade-offs
  ### Discovery questions and risks
  ### Optional alternatives
  ```

  Include one Mermaid HLD. Avoid unprovided exact targets or label them as
  assumptions. Use at most two alternatives.

- [ ] **Step 2: Migrate these five examples.**

  Create: `Video search`, `Personalized recommender`, `Product image content
  moderation`, `Smart-cart real-time CV`, and `Knowledge assistant with RAG +
  image generation`. Preserve the business intent from the existing source
  diagrams while upgrading each explanation to the new structure.

- [ ] **Step 3: Validate the examples.**

  Run:

  ```powershell
  $p='hld-ml-designer/skills/ml-system-hld/references/examples-ml-ai.md'
  "examples=$((Select-String $p -Pattern '^## Example:').Count)"
  "diagrams=$((Select-String $p -SimpleMatch '```mermaid').Count)"
  "assumption-sections=$((Select-String $p -SimpleMatch '### Material assumptions').Count)"
  ```

  Expected: five for all three values.

- [ ] **Step 4: Commit ML/AI examples.**

  ```powershell
  git add -A hld-ml-designer/skills/ml-system-hld/references
  git commit -m "feat: convert ML examples to presales format"
  ```

### Task 8: Add enterprise presales examples

**Files:**
- Create: `hld-ml-designer/skills/ml-system-hld/references/examples-enterprise.md`

**Consumes:** Tasks 3–5 patterns/catalog and the Task 7 example structure.

**Produces:** Seven decision-rich, non-ML examples that stop the skill from overfitting to AI systems.

- [ ] **Step 1: Create seven examples using the exact Task 7 section structure.**

  Add these examples:

  1. `B2B multi-tenant SaaS`;
  2. `Document intake, validation, and human review`;
  3. `E-commerce order and inventory workflow`;
  4. `Event-driven integration hub`;
  5. `API platform with synchronous and asynchronous operations`;
  6. `Data ingestion and operational analytics`;
  7. `Real-time telemetry platform`.

  Use only logical components. Across the seven examples, demonstrate API-first,
  multi-tenant, document processing, saga/outbox, fan-out, async jobs, batch or
  streaming data, audit, idempotency, and security boundaries where naturally
  relevant.

- [ ] **Step 2: Enforce presales reasoning in every example.**

  Every example must include one recommended pattern, at least two material
  assumptions or unknowns, three discovery questions/risks, one conditional
  alternative, and a readable Mermaid HLD. Do not assert exact metrics unless
  supplied by its scenario; use `Unknown` or an explicitly labelled assumption.

- [ ] **Step 3: Validate example completeness.**

  Run:

  ```powershell
  $p='hld-ml-designer/skills/ml-system-hld/references/examples-enterprise.md'
  "examples=$((Select-String $p -Pattern '^## Example:').Count)"
  "diagrams=$((Select-String $p -SimpleMatch '```mermaid').Count)"
  "recommended=$((Select-String $p -SimpleMatch '### Recommended pattern and why').Count)"
  "risks=$((Select-String $p -SimpleMatch '### Discovery questions and risks').Count)"
  ```

  Expected: seven for all four values.

- [ ] **Step 4: Commit enterprise examples.**

  ```powershell
  git add hld-ml-designer/skills/ml-system-hld/references/examples-enterprise.md
  git commit -m "feat: add enterprise presales HLD examples"
  ```

### Task 9: Update workshop documentation and forward-test the skill

**Files:**
- Modify: `hld-ml-designer/README.md`
- Modify: `hld-ml-designer/gemini-extension.json`

**Consumes:** All prior tasks.

**Produces:** Clear workshop instructions and evidence that Gemini CLI can use the v2 flow.

- [ ] **Step 1: Update README.**

  Explain: the skill is vendor-neutral; it delivers Presales Lite; it uses
  confirmed inputs vs assumptions; diagrams remain logical HLDs; and the
  two-command workflow. Add a short list of supported domains: API/SaaS,
  integration, data, enterprise workflow, reliability, ML/AI. Include this
  sample sequence:

  ```text
  /hld:requirements "A B2B platform receives contracts, validates them, routes exceptions to specialists, and integrates with a CRM."
  /hld:design
  ```

- [ ] **Step 2: Update the manifest description.**

  Change the description so it explicitly says vendor-neutral Presales Lite HLD
  for ML/AI and general software/data systems, with Mermaid output.

- [ ] **Step 3: Run local structural validation.**

  Run:

  ```powershell
  python -c "import json; json.load(open('hld-ml-designer/gemini-extension.json')); print('JSON OK')"
  Get-ChildItem hld-ml-designer/skills/ml-system-hld/references -File | Select-Object -ExpandProperty Name
  Select-String -Path hld-ml-designer -Recurse -Pattern 'patterns.md|examples.md' -SimpleMatch
  ```

  Expected: `JSON OK`; seven new reference files exist; final command produces
  no stale references.

- [ ] **Step 4: Run the Gemini CLI acceptance smoke test manually.**

  Reinstall or refresh the extension, then run:

  ```text
  /hld:requirements "A B2B platform receives contracts, validates them, routes exceptions to specialists, and integrates with a CRM."
  /hld:design
  ```

  Acceptance criteria:

  - `requirements.md` distinguishes confirmed inputs, assumptions, and critical
    questions without inventing a numeric SLA;
  - `hld.md` contains all eight Presales Lite sections;
  - its Mermaid diagram uses vendor-neutral logical components;
  - the result names a baseline, at least one meaningful trade-off, discovery
    questions, and at most two alternatives;
  - no cloud vendor or deployment-level details appear.

- [ ] **Step 5: Commit documentation and report smoke-test outcome.**

  ```powershell
  git add hld-ml-designer/README.md hld-ml-designer/gemini-extension.json
  git commit -m "docs: explain presales HLD skill workflow"
  ```

## Plan self-review

- **Spec coverage:** Tasks 1–2 implement the Presales Lite contract, evidence
  ledger, and quality gates. Tasks 3–6 implement the expanded component and
  pattern libraries. Tasks 7–8 implement all twelve worked examples. Task 9
  covers user documentation, manifest copy, structural validation, and the
  real Gemini acceptance test.
- **No placeholder check:** Every task has exact paths, named patterns/examples,
  validation commands, expected outcomes, and commit commands.
- **Consistency check:** `SKILL.md` routes only to the seven references defined
  in the target tree; all pattern cards use one schema; all examples use one
  Presales Lite structure; all commands target the templates defined in Task 1.
