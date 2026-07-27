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
high-level-design-skill/            # this dir is BOTH the Gemini extension AND the Claude plugin root
├── .claude-plugin/
│   ├── plugin.json          # NEW — Claude plugin manifest (name: "hld")
│   └── marketplace.json     # NEW — repo acts as its own marketplace for GitHub install
├── gemini-extension.json    # unchanged (Gemini)
├── commands/
│   ├── requirements.md       # NEW — Claude command (flat), -> /hld:requirements
│   ├── design.md             # NEW — Claude command (flat), -> /hld:design
│   └── hld/
│       ├── requirements.toml # unchanged (Gemini) -> /hld:requirements
│       └── design.toml       # unchanged (Gemini) -> /hld:design
└── skills/ml-system-hld/     # SHARED — read by both platforms, unchanged
    ├── SKILL.md
    ├── assets/
    └── references/
        └── discovery-interview.md   # single source of truth for interview logic
```

### Naming (verified against Claude Code plugin docs)

- A Claude plugin's command/skill namespace **is the plugin name**. To produce
  `/hld:requirements` and `/hld:design`, the plugin is named **`hld`**. (The
  Gemini extension keeps its own name `hld-ml-designer`; the two identities are
  independent.)
- Claude plugin commands are **flat markdown files** in `commands/`; the filename
  (minus `.md`) becomes the command name under the plugin namespace. So
  `commands/requirements.md` -> `/hld:requirements`. They are NOT nested in a
  `hld/` subfolder (nesting is the Gemini convention, not Claude's).

### Coexistence

- Claude discovers `commands/` and `skills/` at the plugin root — exactly where
  they already live.
- Gemini reads only `.toml` files under `commands/<group>/`; Claude reads only
  `.md` files under `commands/`. The Gemini `.toml` files stay in `commands/hld/`;
  the Claude `.md` files sit at `commands/` root. No collision, each platform
  ignores the other's files.
- `skills/ml-system-hld/` is not duplicated. Both platforms load the same
  `SKILL.md` and `references/discovery-interview.md`. Under the `hld` plugin the
  skill is also reachable as `/hld:ml-system-hld`, but users interact through the
  two commands.

## Claude command twins (thin triggers)

Both `.md` commands delegate all depth to the shared skill.

`commands/requirements.md`:

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

`commands/design.md`:

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
`.claude-plugin/marketplace.json`, with the plugin's `source` set to `"./"`
(the plugin lives at the repository root, which is also the marketplace root).
Install becomes:

```
/plugin marketplace add somebodywastoldme/high-level-design-skill
/plugin install hld@hld-designer
```

- `plugin.json`: `{ "name": "hld", "version": "0.1.0", "description": ..., "author": ... }`.
- `marketplace.json`: `{ "name": "hld-designer", "owner": {...}, "plugins": [ { "name": "hld", "source": "./", "description": ... } ] }`.
- `/plugin install hld@hld-designer` = install plugin `hld` from marketplace
  `hld-designer`.

Manifest formats above are verified against the current Claude Code plugin and
marketplace reference docs (fetched during planning).

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
