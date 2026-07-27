# Claude Code Plugin Port — Design

## Problem

The HLD skill currently ships only as a Gemini CLI extension. We want the same
skill usable from Claude Code, without maintaining the interview logic twice and
without destabilizing the working Gemini demo.

The repository already matches a Claude Code plugin layout: `commands/` and
`skills/` sit at the repo root, and `skills/ml-system-hld/SKILL.md` already
carries `name` + `description` frontmatter that Claude skills require. The two
ecosystems diverge mainly in command files: Gemini uses `.toml` + `{{args}}`;
Claude uses `.md` + `$ARGUMENTS`, and Gemini's `@{file}` injection has no Claude
equivalent.

Goal: add a Claude Code plugin layer to the same repository, additively (Gemini
untouched), with the interview logic living once in the shared `skills/`
directory that both platforms read.

## Approach

Dual-target single repo. Add Claude-specific manifest and command files; reuse
the existing `skills/ml-system-hld/` directory verbatim as the single source of
truth for the interview protocol.

### File structure (additions only)

```
high-level-design-skill/
├── .claude-plugin/
│   ├── plugin.json          # NEW — Claude plugin manifest
│   └── marketplace.json     # NEW — repo acts as its own marketplace for GitHub install
├── gemini-extension.json    # unchanged (Gemini)
├── commands/hld/
│   ├── requirements.toml     # unchanged (Gemini)
│   ├── requirements.md       # NEW — Claude twin, thin trigger
│   ├── design.toml           # unchanged (Gemini)
│   └── design.md             # NEW — Claude twin, thin trigger
└── skills/ml-system-hld/     # SHARED — read by both platforms, unchanged
    ├── SKILL.md
    ├── assets/
    └── references/
        └── discovery-interview.md   # single source of truth for interview logic
```

### Coexistence

- Claude discovers `commands/` and `skills/` at the plugin root — exactly where
  they already live.
- Gemini reads only `.toml` command files; Claude reads only `.md` command
  files. Both formats live in `commands/hld/` without collision.
- `skills/ml-system-hld/` is not duplicated. Both platforms load the same
  `SKILL.md` and `references/discovery-interview.md`.

## Claude command twins (thin triggers)

Both `.md` commands delegate all depth to the shared skill.

`commands/hld/requirements.md`:

```markdown
---
description: Run an interactive discovery interview, then draft the requirements brief.
argument-hint: <one-line task>
---
Fuzzy task from the user: $ARGUMENTS

Use the **ml-system-hld** skill. Do NOT write any file yet. Run the discovery
interview from its `references/discovery-interview.md`: one question at a time,
concrete options plus a "Don't know / not important yet" choice, label every
answer Confirmed/Assumption/Unknown (never Confirmed unless I said it), and show
"Covered N/6" after each category. Write `requirements.md` in the current
directory ONLY after I explicitly approve the drafted brief. Presales Lite only.
```

`commands/hld/design.md`:

```markdown
---
description: Draft a Presales Lite high-level design from the approved requirements.
---
Use the **ml-system-hld** skill. Read `requirements.md` from the current
directory as the only input. Produce `hld.md` using the skill's
`assets/hld-template.md` contract (all eight sections in order). Presales Lite
only: logical component names, preserve uncertainty, no LLD, cloud deployment
topology, or cloud-vendor mapping. One baseline plus at most two conditional
alternatives.
```

The six-category frame, labeling rules, progress indicator, and approval gate
stay in `references/discovery-interview.md`. Editing the interview means editing
one file; both platforms pick it up.

## Distribution (parity with Gemini)

Claude plugins install via a "marketplace." To give the audience the same
one-line install as Gemini, the repo acts as its own marketplace via
`.claude-plugin/marketplace.json`. Install becomes:

```
/plugin marketplace add somebodywastoldme/high-level-design-skill
/plugin install hld-ml-designer
```

`plugin.json` and `marketplace.json` reuse the identity already in
`gemini-extension.json` (name `hld-ml-designer`, version, description).

**Manifest formats will be verified against current Claude Code plugin docs
during implementation** (via WebFetch) before finalizing — the exact
`marketplace.json` schema is load-bearing and must not rely on memory.

## Documentation

Add a "Use with Claude Code" section to `README.md` alongside the existing
Gemini instructions: install commands, the two-step `/hld:requirements` →
`/hld:design` workflow (identical command names), and a note that both platforms
share the same skill.

## Verification

- Structural: valid JSON for both manifests; `.md` commands have correct
  frontmatter; the skill reference (`ml-system-hld`) resolves.
- Manifest schemas confirmed against current Claude Code docs.
- Acceptance (run by the user): `/plugin install`, then `/hld:requirements "..."`
  in Claude Code — confirm the interview runs one question at a time and
  `requirements.md` is written only after approval; then `/hld:design`.

## Out of scope

- Any change to the Gemini extension files or the shared skill content.
- Changing command names (kept identical: `/hld:requirements`, `/hld:design`).
- A separate repository or a build/sync step between platforms.
