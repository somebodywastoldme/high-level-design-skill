# Mermaid HLD Visual Contract — Design

## Goal

Make `hld-ml-designer` generate readable, presentation-ready Mermaid HLDs by
default. Mermaid is the final diagram format; the skill must not depend on
draw.io, deployment layouts, or a separate manual-layout artifact.

## Output rule

Generate one `flowchart LR` diagram that tells one architectural story. Use a
second focused Mermaid diagram only when the primary HLD would otherwise exceed
16 logical blocks or combine independently important flows.

## Composition contract

- Use 3–5 `subgraph` containers selected from `Clients & partners`, `Intake`,
  `Core processing`, `Supporting services`, `External systems`, and a
  domain-specific data/async layer when needed.
- Place the happy path left-to-right: client or source -> intake -> core
  processing -> downstream or external systems.
- Put exception branches, including `Human Review`, below the happy path.
- Put cross-cutting/supporting services, such as `Audit Log` and `Notification
  Service`, above or below the main flow. Do not let them interrupt it.
- Place storage beside its owning service or processing layer. Do not draw it
  at the far end of the diagram merely to expose every read/write flow.
- Treat `Event Bus` and `Queue` as hand-off points, not a central star that
  receives and emits every business edge.
- Limit a normal component to one or two outgoing diagram edges. Collapse
  implementation-level interactions into component responsibility text and the
  HLD data-flow section.
- Use edge labels only at decision points or meaningful mode changes, such as
  `exception`, `approved`, `async`, or `manual review`.
- Keep labels short, responsibility-based, and vendor-neutral. Never use a
  sentence as a node label.
- Use only logical components and canonical catalog names when available.

## Diagram planning workflow

Before emitting Mermaid, the agent must silently create a layout plan:

1. Select the one primary user/business flow to visualize.
2. Classify every selected component as client/source, intake, core, data/async,
   supporting, external, or exception handling.
3. Order components along the happy path and identify at most two exception
   branches in the same diagram.
4. Remove edges that explain internal implementation rather than a material
   HLD boundary, decision, or hand-off.
5. If the result exceeds 16 blocks or needs more than two exception branches,
   split it into `Primary flow` plus one focused supporting-flow diagram.
6. Emit Mermaid using the composition contract, then check for backward and
   crossing edges; move supporting/exception flows rather than adding long
   return arrows.

## Template and skill changes

- Add a `Diagram composition` subsection to `hld-template.md` before the
  Mermaid block. It must name the primary flow and, if applicable, identify a
  focused second view.
- Add the composition contract and silent planning workflow to `SKILL.md`.
- Extend `architecture-review.md` with visual checks: subgraph grouping,
  left-to-right happy path, no Event Bus star, exception placement, concise
  labels, and a justified split for diagrams above 16 blocks.
- Add one compact visual-layout example to each example reference file. Existing
  examples should follow the contract when next changed; no wholesale rewrite is
  required for this visual increment.

## Acceptance criteria

- A complex request such as document intake and insurance processing renders as
  a left-to-right Mermaid diagram with clients, intake, core processing,
  supporting services, and external systems grouped in subgraphs.
- The diagram has a visible happy path, a downward exception path, and no
  long cross-diagram event-bus or storage loops.
- Labels are concise and vendor-neutral; only decision/mode-change edges are
  labelled.
- The skill selects a second focused diagram instead of producing an unreadable
  single graph when complexity exceeds the contract.
