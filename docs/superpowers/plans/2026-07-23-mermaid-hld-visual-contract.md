# Mermaid HLD Visual Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `ml-system-hld` produce readable, presentation-ready Mermaid HLDs through a mandatory composition contract.

**Architecture:** Add the visual grammar to the skill workflow and review gate, add a template subsection that exposes diagram intent, then give Gemini compact few-shot visual examples in both ML/AI and enterprise references.

**Tech Stack:** Gemini CLI extension; Markdown; Mermaid `flowchart LR` and `subgraph`.

## Global Constraints

- Mermaid is the final diagram format; do not add draw.io, cloud-vendor, deployment, or manual-layout output.
- Use one `flowchart LR` diagram for one architectural story; use a second focused view only above 16 logical blocks or more than two exception branches.
- Use 3–5 subgraphs selected from Clients & partners, Intake, Core processing, Supporting services, External systems, and a domain-specific data/async layer.
- Keep happy path left-to-right; put exceptions below and supporting services above/below.
- Keep labels concise and vendor-neutral; label only material decisions/mode changes.

---

### Task 1: Encode composition grammar in workflow, template, and review gate

**Files:**
- Modify: `hld-ml-designer/skills/ml-system-hld/SKILL.md`
- Modify: `hld-ml-designer/skills/ml-system-hld/assets/hld-template.md`
- Modify: `hld-ml-designer/skills/ml-system-hld/references/architecture-review.md`

- [ ] Add a `Diagram planning` step to `SKILL.md`: silently select one primary flow, classify blocks into layers, order happy path, limit exceptions, remove implementation-only edges, split above 16 blocks, and inspect backward/crossing edges before writing Mermaid.
- [ ] Add the composition rules: 3–5 subgraphs, left-to-right happy path, exception below, supporting above/below, storage next to owner, no Event Bus/Queue star, one/two outgoing edges normally, and labels only for decisions/mode changes.
- [ ] Add `### Diagram composition` before the Mermaid block in `hld-template.md`, with `Primary flow:` and `Focused second view (only if needed):` placeholders.
- [ ] Add a `Visual composition` checklist to `architecture-review.md` covering grouping, happy path, exception placement, support placement, compact labels, Event Bus/Queue stars, long loops, and justified split.
- [ ] Run:

  ```powershell
  Select-String hld-ml-designer/skills/ml-system-hld/SKILL.md -Pattern 'Diagram planning|subgraph|16 logical blocks'
  Select-String hld-ml-designer/skills/ml-system-hld/assets/hld-template.md -Pattern '^### Diagram composition'
  Select-String hld-ml-designer/skills/ml-system-hld/references/architecture-review.md -Pattern '^## Visual composition'
  ```

  Expected: all markers found once.
- [ ] Commit:

  ```powershell
  git add hld-ml-designer/skills/ml-system-hld/SKILL.md hld-ml-designer/skills/ml-system-hld/assets/hld-template.md hld-ml-designer/skills/ml-system-hld/references/architecture-review.md
  git commit -m "feat: add Mermaid HLD composition contract"
  ```

### Task 2: Add compact few-shot examples of visual composition

**Files:**
- Modify: `hld-ml-designer/skills/ml-system-hld/references/examples-ml-ai.md`
- Modify: `hld-ml-designer/skills/ml-system-hld/references/examples-enterprise.md`

- [ ] Add a top-level `## Visual composition example` after each document introduction, before the first `## Example:` heading.
- [ ] In `examples-ml-ai.md`, show a 9–12-block RAG/knowledge assistant diagram using `Clients & partners`, `Intake`, `Core processing`, `Supporting services`, and `External systems`; happy path runs left-to-right, `Human Review` is an exception branch, and `Audit Log` is supporting.
- [ ] In `examples-enterprise.md`, show a 9–12-block document-intake diagram using the same visual grammar; include `Client & partner`, `Intake`, `Claim processing`, `Supporting services`, and `Core insurance` subgraphs.
- [ ] Precede each diagram with 3–5 bullets explaining the visual decisions: primary flow, exception placement, supporting placement, concise edge labels, and why omitted edges stay in data-flow prose.
- [ ] Run:

  ```powershell
  Select-String hld-ml-designer/skills/ml-system-hld/references/examples-ml-ai.md -Pattern '^## Visual composition example'
  Select-String hld-ml-designer/skills/ml-system-hld/references/examples-enterprise.md -Pattern '^## Visual composition example'
  Select-String hld-ml-designer/skills/ml-system-hld/references/examples-ml-ai.md -SimpleMatch 'flowchart LR' | Measure-Object
  Select-String hld-ml-designer/skills/ml-system-hld/references/examples-enterprise.md -SimpleMatch 'flowchart LR' | Measure-Object
  ```

  Expected: both headings exist once; each file has one more Mermaid flowchart than before.
- [ ] Commit:

  ```powershell
  git add hld-ml-designer/skills/ml-system-hld/references/examples-ml-ai.md hld-ml-designer/skills/ml-system-hld/references/examples-enterprise.md
  git commit -m "feat: add visual Mermaid HLD examples"
  ```

### Task 3: Validate the contract with a representative smoke artifact

**Files:**
- Create: `hld-ml-designer/skills/ml-system-hld/references/visual-smoke-example.md`
- Modify: `hld-ml-designer/skills/ml-system-hld/SKILL.md`

- [ ] Create `visual-smoke-example.md` with the insurance document-intake scenario from the workshop and its expected visual HLD: 3–5 containers, left-to-right primary flow, one exception branch, supporting services separate, and fewer than 16 logical boxes.
- [ ] Add a direct SKILL.md reference to this file, saying to use it as a visual-quality baseline when composing a diagram, not as a domain template.
- [ ] Run:

  ```powershell
  $p='hld-ml-designer/skills/ml-system-hld/references/visual-smoke-example.md'
  "subgraphs=$((Select-String $p -Pattern '^    subgraph ').Count)"
  "flowcharts=$((Select-String $p -SimpleMatch 'flowchart LR').Count)"
  "boxes=$((Select-String $p -Pattern '^    [a-zA-Z].*\[|^    [a-zA-Z].*\(').Count)"
  ```

  Expected: 3–5 subgraphs, one flowchart, and fewer than 16 boxes.
- [ ] Commit:

  ```powershell
  git add hld-ml-designer/skills/ml-system-hld/SKILL.md hld-ml-designer/skills/ml-system-hld/references/visual-smoke-example.md
  git commit -m "test: add visual HLD smoke artifact"
  ```

## Plan self-review

- Task 1 implements the workflow, template, and quality gate requirements.
- Task 2 gives Gemini domain-matched visual few-shot examples.
- Task 3 provides a stable visual acceptance artifact without adding draw.io or changing the primary extension output.
- All tasks preserve Mermaid-first, vendor-neutral Presales Lite scope.
