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

Ask one question at a time. Prefer the host's native structured-choice UI so
the user can answer by clicking a button:

- In Codex, use `request_user_input` when it is available.
- In Claude Code, use `AskUserQuestion` when it is available.
- In another host, use its equivalent interactive question or choice tool.

Send one question per tool call. Provide 2-3 short, mutually exclusive options
that fit the host tool's limits. Make the recommended option first and explain
the effect of each choice in one short sentence. Include **Не знаю / поки
неважливо** as an explicit option when the tool has room; otherwise rely on the
tool's free-form **Інше** option. Write the question, header, option labels, and
descriptions in Ukrainian.

Do not print an A/B/C/D list in chat before or after opening the native choice
UI. If no interactive-choice tool is available, fall back to a concise numbered
list in Ukrainian and accept either a number or free-form answer.

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
