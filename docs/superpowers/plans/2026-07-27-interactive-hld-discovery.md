# Interactive HLD Discovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn `/hld:requirements` from a one-shot prompt into an interactive discovery interview that gathers concrete requirements before any design work.

**Architecture:** Keep the two-command structure. Add a discovery-interview protocol as a skill reference file; rewrite the `requirements.toml` command to run that interview and write `requirements.md` only after the user approves the drafted claim ledger. `SKILL.md`, the requirements template, and the README point at the new flow. `/hld:design` is untouched.

**Tech Stack:** Gemini CLI extension; Markdown; TOML custom commands. No code, no test runner — verification is structural (valid TOML, resolvable references, required content present) plus the existing manual Gemini smoke test.

## Global Constraints

- Produce Presales Lite, never LLD, cloud deployment topology, or cloud-vendor mapping.
- Use logical component names only.
- Never record a requirement as **Confirmed** unless the user stated it in their own words. Inferred values are **Assumption** (spoken aloud for correction); unresolved items are **Unknown** (open questions).
- Do not write `requirements.md` until the user approves the drafted ledger.
- Preserve valid TOML, YAML frontmatter, and Markdown syntax.
- Keep `SKILL.md` procedural and compact; detailed protocol lives in a reference file.
- One question at a time, with concrete options plus a "Don't know / not important yet" option.
- Six-category frame, in order: (1) Business outcome & scope, (2) Users & journeys, (3) Functional scope, (4) Scale & performance, (5) Data & integrations, (6) Security & constraints.

---

## Target file structure

```
high-level-design-skill/
├── README.md                                          # MODIFY: interactive usage
├── commands/hld/
│   └── requirements.toml                              # MODIFY: run the interview
└── skills/ml-system-hld/
    ├── SKILL.md                                        # MODIFY: pointer to protocol
    ├── assets/
    │   └── requirements-template.md                    # MODIFY: explicit ledger labels
    └── references/
        └── discovery-interview.md                      # CREATE: the interview protocol
```

**Verification note (applies to every task):** There is no automated test runner. "Failing test" = a structural check that fails before the change and passes after. Use `rg` (ripgrep) / `grep` for content checks. For TOML validity use Python 3.11+: `python -c "import tomllib,sys; tomllib.load(open(sys.argv[1],'rb'))" <file>` (prints nothing and exits 0 when valid). The real acceptance gate is the manual Gemini CLI smoke test in Task 5.

---

### Task 1: Make the requirements template's claim ledger explicit

**Files:**
- Modify: `skills/ml-system-hld/assets/requirements-template.md`

**Interfaces:**
- Produces: section headers the interview and the drafted brief reference verbatim — `## 2. Confirmed inputs`, `## 5. Assumptions to validate`, `## 6. Critical discovery questions`, and an NFR table with a `Status` column whose cells read `Confirmed`, `Assumption`, or `Unknown`.

- [ ] **Step 1: Verify the ledger legend is absent (failing check)**

Run: `rg -n "Claim ledger legend" skills/ml-system-hld/assets/requirements-template.md`
Expected: no matches (exit 1).

- [ ] **Step 2: Add a ledger legend under the title**

Insert immediately after the `# Discovery Brief: <system name>` line:

```markdown

> **Claim ledger legend.** Every item below traces to a discovery-interview
> answer. **Confirmed** = stated by the stakeholder. **Assumption** = inferred,
> pending confirmation. **Unknown** = unresolved, tracked as an open question.
> Nothing is Confirmed without the stakeholder's own words.
```

- [ ] **Step 3: Label the three ledger sections**

Change the section bodies so the labels are explicit. Set section 2's body to:

```markdown
<facts explicitly provided by the stakeholder — all **Confirmed**>
```

Set section 5's body to:

```markdown
<inferred details labeled **Assumption**, each stated for the stakeholder to confirm>
```

Set section 6's body to:

```markdown
<unresolved items labeled **Unknown**, phrased as the highest-impact open questions>
```

- [ ] **Step 4: Verify the legend and labels are present (passing check)**

Run: `rg -n "Claim ledger legend|Confirmed|Assumption|Unknown" skills/ml-system-hld/assets/requirements-template.md`
Expected: matches on the legend line and all three labels.

- [ ] **Step 5: Commit**

```bash
git add skills/ml-system-hld/assets/requirements-template.md
git commit -m "feat: make requirements template claim ledger explicit"
```

---

### Task 2: Create the discovery-interview protocol and wire it into SKILL.md

**Files:**
- Create: `skills/ml-system-hld/references/discovery-interview.md`
- Modify: `skills/ml-system-hld/SKILL.md`

**Interfaces:**
- Consumes: template section names from Task 1 (`## 2`, `## 5`, `## 6`) and the six-category frame from Global Constraints.
- Produces: the reference path `references/discovery-interview.md` that `requirements.toml` (Task 3) invokes by name.

- [ ] **Step 1: Verify the reference does not yet exist (failing check)**

Run: `test -f skills/ml-system-hld/references/discovery-interview.md && echo EXISTS || echo MISSING`
Expected: `MISSING`.

- [ ] **Step 2: Create `discovery-interview.md`**

Write exactly:

```markdown
# Discovery interview protocol

Run this before writing `requirements.md`. The interview replaces guessing with
asking. Its output is a claim ledger that fills `assets/requirements-template.md`.

## Prime directive

Never record a fact as **Confirmed** unless the user stated it in their own
words. Anything you infer is an **Assumption** and must be spoken aloud for
correction. Anything neither stated nor safely assumable is **Unknown** and
becomes an open question. Do not write `requirements.md` until the user approves
the drafted ledger.

## Category frame

Ask across six categories, in order. Adapt or skip individual questions inside a
category when they are irrelevant to the task; never skip a whole category
silently — say when a category has no open questions.

1. Business outcome & scope — why the system exists, success criteria, out of scope
2. Users & journeys — who uses it, key journeys
3. Functional scope — core capabilities the system must provide
4. Scale & performance — volume, latency, throughput, freshness
5. Data & integrations — data sources, external systems (CRM/APIs)
6. Security & constraints — access control, compliance, budget, delivery constraints

## Asking one question

Ask one question at a time. Offer 3-4 concrete options plus an explicit
"Don't know / not important yet" option. Use this format:

    [Category N/6 · <name>]
    <question>
      A) <concrete option>
      B) <concrete option>
      C) <concrete option>
      D) Don't know / not important yet

## Labeling each answer

After each answer, assign and state the label:

- Concrete option chosen -> **Confirmed**.
- "Don't know" but the design needs a value -> **Assumption**; state the assumed
  value out loud ("assuming ~100 req/s, correct later").
- "Don't know" and genuinely unresolved -> **Unknown**; move it to open questions.

## Progress and stopping

After each category, report "Covered N/6" and ask: "Enough for design, or
continue?" Stop early if the user says so.

## Approval gate

When the interview ends (all categories or early exit), render the full
`requirements.md` draft in chat using `assets/requirements-template.md`, with the
Confirmed (section 2), Assumption (section 5), and Unknown (section 6) items
clearly separated. Ask for explicit approval. Write the file only after the user
approves.
```

- [ ] **Step 3: Add a workflow pointer in `SKILL.md`**

In `skills/ml-system-hld/SKILL.md`, under `## Reference selection`, add this bullet as the first item in the list:

```markdown
- [Discovery interview](references/discovery-interview.md) to run the interactive
  requirements interview before writing `requirements.md`.
```

Also, in the `## Workflow` section, change step 2 so it begins by pointing at the interview. Replace the existing step 2 sentence start "Create a claim ledger." with:

```markdown
2. Run the [discovery interview](references/discovery-interview.md) to build the
   claim ledger interactively. Label every material claim **Confirmed**,
```

(keep the remainder of the original step 2 text unchanged).

- [ ] **Step 4: Verify the reference exists and is wired (passing check)**

Run: `test -f skills/ml-system-hld/references/discovery-interview.md && rg -n "discovery-interview.md" skills/ml-system-hld/SKILL.md`
Expected: file exists and at least one `SKILL.md` match.

- [ ] **Step 5: Verify protocol completeness (passing check)**

Run: `rg -n "Prime directive|Category frame|Labeling each answer|Approval gate|Covered N/6" skills/ml-system-hld/references/discovery-interview.md`
Expected: matches on all five anchors.

- [ ] **Step 6: Commit**

```bash
git add skills/ml-system-hld/references/discovery-interview.md skills/ml-system-hld/SKILL.md
git commit -m "feat: add interactive discovery interview protocol"
```

---

### Task 3: Rewrite the requirements command to run the interview

**Files:**
- Modify: `commands/hld/requirements.toml`

**Interfaces:**
- Consumes: `skills/ml-system-hld/references/discovery-interview.md` (Task 2) and `assets/requirements-template.md` (Task 1).
- Produces: the `/hld:requirements` behavior that later `/hld:design` depends on (an approved `requirements.md` in the workspace).

- [ ] **Step 1: Verify the command still says "stop before architecture design" without an interview (failing check)**

Run: `rg -n "discovery-interview|interview|Do NOT write" commands/hld/requirements.toml`
Expected: no matches (exit 1).

- [ ] **Step 2: Replace the prompt body**

Replace the entire contents of `commands/hld/requirements.toml` with:

```toml
description = "Run an interactive discovery interview, then draft the requirements brief."
prompt = """
Fuzzy task from the user: {{args}}

Activate the ml-system-hld skill. Do NOT write any file yet. Conduct the
interactive discovery interview defined in
skills/ml-system-hld/references/discovery-interview.md:

- Ask one question at a time across the six-category frame, offering concrete
  options plus a "Don't know / not important yet" option.
- Label every answer Confirmed, Assumption, or Unknown. Never mark anything
  Confirmed unless the user stated it in their own words. Speak every Assumption
  aloud so the user can correct it.
- After each category, report "Covered N/6" and offer to stop early.

When the interview ends, render the full requirements.md draft in chat using
assets/requirements-template.md, with Confirmed, Assumption, and Unknown items
clearly separated. Write requirements.md in the current workspace ONLY after the
user explicitly approves the draft.

Produce Presales Lite only: no LLD, cloud deployment topology, or cloud-vendor
mapping. Use logical component names only. Stop before architecture design.
"""
```

- [ ] **Step 3: Verify TOML is valid**

Run: `python -c "import tomllib,sys; tomllib.load(open(sys.argv[1],'rb')); print('ok')" commands/hld/requirements.toml`
Expected: prints `ok`. (If Python 3.11+ is unavailable, visually confirm the triple-quoted string is closed and the `description`/`prompt` keys are intact.)

- [ ] **Step 4: Verify the interview wiring is present (passing check)**

Run: `rg -n "discovery-interview.md|Do NOT write any file yet|ONLY after the user explicitly approves" commands/hld/requirements.toml`
Expected: matches on all three anchors.

- [ ] **Step 5: Commit**

```bash
git add commands/hld/requirements.toml
git commit -m "feat: run discovery interview in hld:requirements command"
```

---

### Task 4: Update the README usage section

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: the interview behavior from Task 3.
- Produces: user-facing docs; no downstream code dependency.

- [ ] **Step 1: Verify the README still describes a one-shot write (failing check)**

Run: `rg -n "interview|one question at a time" README.md`
Expected: no matches (exit 1).

- [ ] **Step 2: Rewrite the "Step 1" usage paragraph**

In `README.md`, under **Step 1: Generate requirements from a one-line task**, replace the sentence that begins "This writes `requirements.md` in your current directory." with:

```markdown
This starts an interactive discovery interview. Instead of writing the file
immediately, the skill asks one question at a time across six categories
(business outcome, users, functional scope, scale, data & integrations,
security & constraints), offering concrete options plus a "Don't know / not
important yet" choice. Each answer is labeled **Confirmed**, **Assumption**, or
**Unknown** — nothing becomes Confirmed unless you say it. After you approve the
drafted brief, it writes `requirements.md`. The file distinguishes:
```

(keep the existing three bullet points — Confirmed inputs / Assumptions / Critical questions — immediately after this paragraph).

- [ ] **Step 3: Verify the interactive description is present (passing check)**

Run: `rg -n "interactive discovery interview|one question at a time|Don't know" README.md`
Expected: matches on the interview description.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: describe interactive discovery flow in README"
```

---

### Task 5: Manual Gemini CLI smoke test

**Files:** none (acceptance only).

**Interfaces:**
- Consumes: all prior tasks, installed as a Gemini extension.

- [ ] **Step 1: Install/refresh the extension**

```bash
gemini extensions install /path/to/high-level-design-skill
```
(or `gemini extensions update --all` if already installed)

- [ ] **Step 2: Run the interview**

In a scratch working directory:
```text
/hld:requirements "a system that moderates uploaded product images for unsafe content"
```
Expected: the model asks one question at a time with lettered options and a "Don't know" choice, labels each answer Confirmed/Assumption/Unknown, shows "Covered N/6" between categories, and does NOT write `requirements.md` until you approve a rendered draft.

- [ ] **Step 3: Confirm the gate and file**

Approve the draft. Expected: `requirements.md` appears in the working directory with Confirmed inputs, Assumptions, and Critical questions separated, and no invented numeric SLA for anything you answered "Don't know."

- [ ] **Step 4: Confirm design still works**

```text
/hld:design
```
Expected: `hld.md` is produced from the approved brief, unchanged from prior behavior.

---

## Self-Review

- **Spec coverage:** Two-act structure (Tasks 3, and unchanged design) ✓; 6-category hybrid frame (Task 2 + constraints) ✓; one-question-at-a-time with options (Task 2, 3) ✓; Confirmed/Assumption/Unknown labeling (Tasks 1, 2, 3) ✓; progress + early exit (Task 2, 3) ✓; approval gate before file write (Tasks 2, 3) ✓; repo changes — requirements.toml (Task 3), discovery-interview.md (Task 2), SKILL.md (Task 2), requirements-template.md (Task 1), README.md (Task 4), design untouched ✓.
- **Placeholder scan:** all content steps contain literal file content; no TBD/TODO.
- **Type consistency:** the reference path `references/discovery-interview.md` and the template sections `## 2 / ## 5 / ## 6` and labels Confirmed/Assumption/Unknown are used identically across Tasks 1-4.
