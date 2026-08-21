---
description: Run an interactive discovery interview, then draft the requirements brief.
argument-hint: <one-line task>
---
Fuzzy task from the user: $ARGUMENTS

Use the **ml-system-hld** skill. Do NOT write any file yet. Run the discovery
interview defined in the skill's `references/discovery-interview.md`:

- Ask one question at a time across the six-category frame. Use the host's
  native interactive choice tool (`request_user_input` in Codex or
  `AskUserQuestion` in Claude Code) so I can click an option. Keep every UI
  label and description in Ukrainian. Do not duplicate choices as A/B/C/D text
  in chat. Fall back to a numbered text list only if no choice tool is available.
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
