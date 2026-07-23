# Task 1 Report

Status: Implemented.

Changed exactly the four requested implementation paths:

- `hld-ml-designer/skills/ml-system-hld/assets/requirements-template.md`
- `hld-ml-designer/skills/ml-system-hld/assets/hld-template.md`
- `hld-ml-designer/commands/hld/requirements.toml`
- `hld-ml-designer/commands/hld/design.toml`

The requirements contract now uses the seven-section discovery structure and
the required NFR status table. The HLD contract now uses the eight-section
structure, Mermaid `flowchart LR`, the requirements-to-design table, and the
conditional alternatives table. Both prompts preserve the required injections,
uncertainty labels, Presales Lite scope, logical naming, and workspace outputs.

Verification:

- TOML parse command: passed; output `TOML OK`.
- HLD heading-count command: passed; `Count : 8`.

Concern: `design.toml` did not exist at the specified path before this task, so
it was created there as required.

## Review correction

The Section 6 heading is verified as `## 6. Requirements → design rationale`.
The existing heading-count check passed with `Count : 8`.
