# hld-ml-designer

A vendor-neutral Gemini CLI extension that turns a one-line product or system need into a Presales Lite High-Level Design (HLD) in Markdown with a Mermaid diagram. It supports ML/AI and general software/data systems: API/SaaS, integration, data, enterprise workflow, reliability, and ML/AI.

The skill separates confirmed inputs from assumptions and critical discovery questions, so the design remains useful without presenting unknowns as facts. Its diagrams are logical HLDs: they describe responsibilities and flows without selecting a cloud vendor or deployment-level implementation.

## Install

Choose one:

**Option 1: Clone and install**
```bash
git clone <repo-url> && cd hld-ml-designer
gemini extensions install ./hld-ml-designer
```

**Option 2: Copy into your extensions folder**
```bash
cp -r hld-ml-designer ~/.gemini/extensions/
```

Verify it loaded:
```bash
gemini extensions list
```
You should see `hld-ml-designer` in the output.

## Usage

A two-command workflow: first capture the requirements, then create the Presales Lite HLD.

For example:
```text
/hld:requirements "A B2B platform receives contracts, validates them, routes exceptions to specialists, and integrates with a CRM."
/hld:design
```

**Step 1: Generate requirements from a one-line task**

From your working directory, run:
```bash
/hld:requirements "a system that moderates uploaded product images for unsafe content at 2000 images per minute"
```

This writes `requirements.md` in your current directory. Open it, confirm the inputs, and resolve the assumptions and critical questions before proceeding. The file distinguishes:
- **Confirmed inputs** (facts supplied in the prompt)
- **Assumptions** (explicit, reviewable working hypotheses)
- **Critical questions** (discovery items that could materially change the design)

**Step 2: Design the High-Level Architecture**

Once `requirements.md` is approved, run:
```bash
/hld:design
```

This reads `requirements.md` from your current directory and writes `hld.md`, a Presales Lite HLD with all eight required sections. It includes a vendor-neutral Mermaid logical diagram, a baseline design, meaningful trade-offs, discovery questions, and no more than two alternatives.

**Note:** Always run these commands from the working directory where `requirements.md` and `hld.md` live.

## What you get

`hld.md` is Markdown with an embedded Mermaid diagram. The diagram is a logical HLD and shows:
- **Left side:** data ingestion pipeline (inbound events → processing → store)
- **Right side:** serving pipeline (request → orchestration → model/retrieval → response)
- **Blocks:** each is a canonical component from the 12-block catalog (e.g., `Queue`, `Cache`, `Vector DB`, `Model / Embeddings`)

Paste the Mermaid block into an IDE, GitHub wiki, or https://mermaid.live to render it visually. The Components table explains why each block was chosen.

## Manual smoke test

Gemini CLI is required for this acceptance test and is not run as part of the local structural checks. After installing or refreshing the extension, run:

```text
/hld:requirements "A B2B platform receives contracts, validates them, routes exceptions to specialists, and integrates with a CRM."
/hld:design
```

Check that `requirements.md` distinguishes confirmed inputs, assumptions, and critical questions without inventing a numeric SLA. Check that `hld.md` contains all eight Presales Lite sections, uses vendor-neutral logical components in its Mermaid diagram, names a baseline and at least one meaningful trade-off and discovery questions, includes at most two alternatives, and contains no cloud-vendor or deployment-level details.

## The 12-block catalog at a glance

Every HLD reuses these standard building blocks:

- **Load Balancer** — Distribute incoming requests across serving replicas; single entry point.
- **Workflow Manager** — Orchestrate a request end-to-end, calling downstream services and assembling the response.
- **Queue** — Decouple producers from consumers and absorb bursty or asynchronous load.
- **Cache** — Serve repeated or recent results quickly without recomputation.
- **Vector DB** — Store embeddings and serve similarity search over them.
- **Feature Store** — Provide consistent features shared between online serving and offline training.
- **Model / Embeddings** — Run inference (score, classify, or embed) against a trained model.
- **Re-ranking service** — Improve result quality by re-scoring candidates after cheap retrieval.
- **Scheduler** — Trigger periodic or batch work on a timer, independent of user requests.
- **Rights check** — Enforce per-user access control on results before returning them.
- **DLQ → Review** — Capture low-confidence or failed items for human review instead of silently dropping them.
- **Model API Proxy** — Mediate calls to external LLM or embeddings providers behind a single internal interface.

## Troubleshooting

**`/hld:requirements` or `/hld:design` commands don't appear**

Confirm the extension is installed:
```bash
gemini extensions list
```

If `hld-ml-designer` is listed but the commands don't appear, reload commands:
```bash
/commands reload
```

Or list all commands to verify:
```bash
/commands list
```

**`@{...}` file injection can't find the template or `requirements.md`**

Make sure:
1. You are running the command from the directory where `requirements.md` and `hld.md` should live.
2. The extension is installed (step 1 above).
3. The skill paths resolve correctly by re-running `/commands reload`.

If the error persists, confirm the extension folder structure:
```
~/.gemini/extensions/hld-ml-designer/
├── gemini-extension.json
├── skills/
│   └── ml-system-hld/
│       ├── SKILL.md
│       ├── assets/
│       └── references/
└── commands/
    └── hld/
```

**Generated Mermaid diagram won't render**

Paste the `mermaid` block into https://mermaid.live to check for syntax errors. Report the error; most issues are missing arrows or node labels with special characters. Regenerate with `/hld:design` to retry.
