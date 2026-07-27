# Claude Code Plugin Port Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing HLD skill installable and usable from Claude Code as a plugin named `hld`, reusing the shared `skills/ml-system-hld/` directory, without changing the Gemini extension.

**Architecture:** The repo root doubles as the Claude plugin root. Add `.claude-plugin/plugin.json` (name `hld`) and `.claude-plugin/marketplace.json` (repo as its own marketplace, plugin `source: "./"`). Add two flat Claude command files `commands/requirements.md` and `commands/design.md` that produce `/hld:requirements` and `/hld:design` and delegate to the shared `ml-system-hld` skill. Update the README.

**Tech Stack:** Claude Code plugin (JSON manifests + Markdown commands); existing Gemini extension untouched. No code, no test runner — verification is structural (valid JSON, correct frontmatter, resolvable references) plus a manual Claude Code smoke test.

## Global Constraints

- Do NOT modify any Gemini file (`gemini-extension.json`, `commands/hld/*.toml`) or any shared skill file under `skills/ml-system-hld/`. This port is purely additive.
- Claude plugin name is `hld` (its namespace produces `/hld:requirements`, `/hld:design`).
- Claude commands are flat `.md` files in `commands/` (NOT nested in `commands/hld/`).
- Plugin lives at the repo root; marketplace root is the repo root; plugin `source` is `"./"`.
- Preserve valid JSON, YAML frontmatter, and Markdown syntax.
- Interview logic stays solely in `skills/ml-system-hld/references/discovery-interview.md`; command files are thin triggers.

### Verified facts (from Claude Code docs, fetched 2026-07-27)

- `plugin.json` fields: `name` (required; is the command/skill namespace), `description`, `version`, `author` (all optional). Lives in `.claude-plugin/`.
- Component dirs (`commands/`, `skills/`) live at the plugin ROOT, never inside `.claude-plugin/`.
- Plugin commands = flat markdown in `commands/`; filename minus `.md` is the command name, namespaced by plugin: `commands/requirements.md` in plugin `hld` → `/hld:requirements`.
- Default `skills/` directory is always scanned; `skills/ml-system-hld/SKILL.md` loads automatically.
- `marketplace.json` (in `.claude-plugin/`) required fields: `name`, `owner`, `plugins[]`. Each plugin entry needs `name` and `source`. A same-repo plugin at the marketplace root uses `"source": "./"`. Paths resolve relative to the marketplace root (the dir containing `.claude-plugin/`).
- Install: `/plugin marketplace add <owner>/<repo>` then `/plugin install <plugin>@<marketplace-name>` → here `/plugin install hld@hld-designer`.
- Local dev/test without a marketplace: `claude --plugin-dir .` then `/reload-plugins`.

---

## Target file structure (additions only)

```
high-level-design-skill/
├── .claude-plugin/
│   ├── plugin.json          # NEW
│   └── marketplace.json     # NEW
├── commands/
│   ├── requirements.md       # NEW  -> /hld:requirements
│   ├── design.md             # NEW  -> /hld:design
│   └── hld/                   # unchanged (Gemini .toml)
├── gemini-extension.json     # unchanged
├── README.md                 # MODIFY: add "Use with Claude Code"
└── skills/ml-system-hld/      # unchanged (shared)
```

**Verification note (every task):** No automated test runner. "Failing check" = a structural check that fails before the change and passes after. Validate JSON with: `python -c "import json,sys; json.load(open(sys.argv[1],encoding='utf-8')); print('JSON ok')" <file>`.

---

### Task 1: Add the Claude plugin manifest

**Files:**
- Create: `.claude-plugin/plugin.json`

**Interfaces:**
- Produces: plugin identity `name: "hld"` — the namespace later commands (Task 3) rely on for `/hld:...`.

- [ ] **Step 1: Verify the manifest does not exist (failing check)**

Run: `test -f .claude-plugin/plugin.json && echo EXISTS || echo MISSING`
Expected: `MISSING`.

- [ ] **Step 2: Create `.claude-plugin/plugin.json`**

Write exactly:

```json
{
  "name": "hld",
  "version": "0.1.0",
  "description": "Generate vendor-neutral Presales Lite High-Level Designs for ML/AI and general software/data systems, with an interactive discovery interview and Markdown + Mermaid output.",
  "author": {
    "name": "somebodywastoldme"
  },
  "homepage": "https://github.com/somebodywastoldme/high-level-design-skill",
  "repository": "https://github.com/somebodywastoldme/high-level-design-skill"
}
```

- [ ] **Step 3: Verify JSON validity and name (passing check)**

Run: `python -c "import json; d=json.load(open('.claude-plugin/plugin.json',encoding='utf-8')); assert d['name']=='hld', d['name']; print('JSON ok, name=hld')"`
Expected: `JSON ok, name=hld`.

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "feat: add Claude Code plugin manifest (hld)"
```

---

### Task 2: Add the marketplace manifest

**Files:**
- Create: `.claude-plugin/marketplace.json`

**Interfaces:**
- Consumes: plugin name `hld` from Task 1.
- Produces: marketplace `hld-designer` exposing plugin `hld` at `source: "./"`, enabling `/plugin install hld@hld-designer`.

- [ ] **Step 1: Verify the marketplace file does not exist (failing check)**

Run: `test -f .claude-plugin/marketplace.json && echo EXISTS || echo MISSING`
Expected: `MISSING`.

- [ ] **Step 2: Create `.claude-plugin/marketplace.json`**

Write exactly:

```json
{
  "name": "hld-designer",
  "owner": {
    "name": "somebodywastoldme"
  },
  "plugins": [
    {
      "name": "hld",
      "source": "./",
      "description": "Interactive Presales Lite HLD designer: discovery interview then a vendor-neutral high-level design with a Mermaid diagram."
    }
  ]
}
```

- [ ] **Step 3: Verify JSON validity and structure (passing check)**

Run: `python -c "import json; d=json.load(open('.claude-plugin/marketplace.json',encoding='utf-8')); p=d['plugins'][0]; assert d['name']=='hld-designer' and p['name']=='hld' and p['source']=='./', d; print('marketplace ok')"`
Expected: `marketplace ok`.

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "feat: add marketplace manifest for hld plugin"
```

---

### Task 3: Add the two Claude command twins

**Files:**
- Create: `commands/requirements.md`
- Create: `commands/design.md`

**Interfaces:**
- Consumes: plugin namespace `hld` (Task 1); the shared skill `ml-system-hld` and its `references/discovery-interview.md` and `assets/hld-template.md` (already in repo).
- Produces: user-facing commands `/hld:requirements` and `/hld:design`.

- [ ] **Step 1: Verify the command files do not exist (failing check)**

Run: `ls commands/requirements.md commands/design.md 2>/dev/null; echo "exit=$?"`
Expected: no such files, `exit=` non-zero.

- [ ] **Step 2: Create `commands/requirements.md`**

Write exactly:

```markdown
---
description: Run an interactive discovery interview, then draft the requirements brief.
argument-hint: <one-line task>
---
Fuzzy task from the user: $ARGUMENTS

Use the **ml-system-hld** skill. Do NOT write any file yet. Run the discovery
interview defined in the skill's `references/discovery-interview.md`:

- Ask one question at a time across the six-category frame, offering concrete
  options plus a "Don't know / not important yet" option.
- Label every answer Confirmed, Assumption, or Unknown. Never mark anything
  Confirmed unless I stated it in my own words. Speak every Assumption aloud so
  I can correct it.
- After each category, report "Covered N/6" and offer to stop early.

When the interview ends, render the full requirements.md draft in chat using the
skill's `assets/requirements-template.md`, with Confirmed, Assumption, and
Unknown items clearly separated. Write `requirements.md` in the current
directory ONLY after I explicitly approve the draft. Presales Lite only: no LLD,
cloud deployment topology, or cloud-vendor mapping. Stop before architecture
design.
```

- [ ] **Step 3: Create `commands/design.md`**

Write exactly:

```markdown
---
description: Draft a Presales Lite high-level design from the approved requirements.
---
Use the **ml-system-hld** skill. Read `requirements.md` from the current
directory as the only input. Produce `hld.md` using the skill's
`assets/hld-template.md` output contract with all eight sections in order.

Presales Lite only: use logical component names, preserve uncertainty, and do
not produce LLD, cloud deployment topology, or cloud-vendor mapping. Select one
baseline architecture and no more than two conditional alternatives. Explain the
architecture pattern and its architectural drivers, including
requirement-to-design rationale. Write `hld.md` in the current directory.
```

- [ ] **Step 4: Verify frontmatter and content anchors (passing check)**

Run: `rg -n "^description:|ml-system-hld|discovery-interview.md|ONLY after I explicitly approve" commands/requirements.md && rg -n "^description:|ml-system-hld|assets/hld-template.md|Read .requirements.md." commands/design.md`
Expected: `requirements.md` matches all four anchors; `design.md` matches its three.

- [ ] **Step 5: Verify no accidental Gemini breakage (passing check)**

Run: `git status --porcelain commands/hld/ gemini-extension.json skills/`
Expected: empty output (no changes to Gemini or shared-skill files).

- [ ] **Step 6: Commit**

```bash
git add commands/requirements.md commands/design.md
git commit -m "feat: add Claude command twins for hld:requirements and hld:design"
```

---

### Task 4: Document the Claude Code workflow in the README

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: install commands and command names from Tasks 1-3.
- Produces: user-facing docs; no downstream dependency.

- [ ] **Step 1: Verify the README has no Claude section yet (failing check)**

Run: `rg -n "Use with Claude Code|/plugin marketplace add" README.md; echo "exit=$?"`
Expected: no matches, `exit=1`.

- [ ] **Step 2: Add a "Use with Claude Code" section**

In `README.md`, immediately after the `## Install` section (before `## Usage`), insert:

```markdown
## Use with Claude Code

The same skill works in Claude Code as a plugin named `hld`. Add this repository
as a plugin marketplace, then install the plugin:

```bash
/plugin marketplace add somebodywastoldme/high-level-design-skill
/plugin install hld@hld-designer
```

This gives you the same two commands as the Gemini version — `/hld:requirements`
and `/hld:design` — backed by the same shared skill. The interactive discovery
interview and the design step behave identically.

To develop or test locally without a marketplace, run Claude Code from the repo
root with the plugin loaded directly:

```bash
claude --plugin-dir .
```

Then run `/reload-plugins` after edits to pick up changes.
```

- [ ] **Step 3: Verify the section is present (passing check)**

Run: `rg -n "Use with Claude Code|/plugin install hld@hld-designer|--plugin-dir" README.md`
Expected: matches on the heading, the install command, and the local-dev command.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add Claude Code plugin install and usage to README"
```

---

### Task 5: Manual Claude Code smoke test

**Files:** none (acceptance only).

**Interfaces:**
- Consumes: all prior tasks.

- [ ] **Step 1: Load the plugin locally**

From the repo root:
```bash
claude --plugin-dir .
```
Then in Claude Code run `/reload-plugins` and confirm `/help` lists `/hld:requirements` and `/hld:design` under the `hld` plugin.

- [ ] **Step 2: Run the interview**

In a scratch working directory (not the plugin repo):
```text
/hld:requirements "a system that moderates uploaded product images for unsafe content"
```
Expected: the `ml-system-hld` skill activates; the model asks one question at a time with lettered options and a "Don't know" choice, labels each answer Confirmed/Assumption/Unknown, shows "Covered N/6", and does NOT write `requirements.md` until you approve a rendered draft.

- [ ] **Step 3: Confirm the gate and the file**

Approve the draft. Expected: `requirements.md` appears with Confirmed / Assumption / Unknown separated and no invented numeric SLA for anything answered "Don't know."

- [ ] **Step 4: Confirm design**

```text
/hld:design
```
Expected: `hld.md` is produced from the approved brief with the eight-section Presales Lite contract and a Mermaid diagram.

- [ ] **Step 5 (optional): Confirm marketplace install path**

In a fresh Claude Code session:
```text
/plugin marketplace add somebodywastoldme/high-level-design-skill
/plugin install hld@hld-designer
```
Expected: plugin `hld` installs and both commands appear. (Requires the branch to be pushed/merged so the remote reflects the new files.)

---

## Self-Review

- **Spec coverage:** plugin.json name `hld` (Task 1) ✓; marketplace.json with `source: "./"` (Task 2) ✓; flat Claude commands → `/hld:requirements`, `/hld:design` (Task 3) ✓; thin triggers delegating to shared skill/interview (Task 3) ✓; design reads requirements.md, no `@{}` injection (Task 3) ✓; README "Use with Claude Code" (Task 4) ✓; Gemini + shared skill untouched (Global Constraints + Task 3 Step 5 guard) ✓; verification incl. manual smoke test (Task 5) ✓.
- **Placeholder scan:** all file contents are literal; no TBD/TODO.
- **Type/name consistency:** plugin name `hld`, marketplace name `hld-designer`, install `hld@hld-designer`, command files `commands/requirements.md`/`commands/design.md`, skill `ml-system-hld` — used identically across all tasks and the README.
