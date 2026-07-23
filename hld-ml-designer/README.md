# hld-ml-designer

A Gemini CLI extension that turns a one-line ML task into High-Level Design documentation (markdown + Mermaid diagram) by reusing a catalog of standard building blocks. Write a functional requirement in plain English, and get back a complete architecture with rationale—all in two commands.

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

A two-step flow: first draft requirements, then design the architecture.

**Step 1: Generate requirements from a one-line task**

From your working directory, run:
```bash
/hld:requirements "a system that moderates uploaded product images for unsafe content at 2000 images per minute"
```

This writes `requirements.md` in your current directory. Open it, review the assumptions, and edit as needed. The file should contain:
- **Functional Requirements** (what the system does)
- **Non-Functional Requirements** (latency, throughput, freshness, access control, etc.)

**Step 2: Design the High-Level Architecture**

Once `requirements.md` is approved, run:
```bash
/hld:design
```

This reads `requirements.md` from your current directory and writes `hld.md`, which contains:
- A **Mermaid flowchart** showing data flow (ingestion on the left, serving on the right)
- A **Components table** mapping each NFR to the canonical block that satisfies it
- **Open questions** section for any ambiguities

**Note:** Always run these commands from the working directory where `requirements.md` and `hld.md` live.

## What you get

`hld.md` is markdown with an embedded Mermaid diagram. The diagram shows:
- **Left side:** data ingestion pipeline (inbound events → processing → store)
- **Right side:** serving pipeline (request → orchestration → model/retrieval → response)
- **Blocks:** each is a canonical component from the 12-block catalog (e.g., `Queue`, `Cache`, `Vector DB`, `Model / Embeddings`)

Paste the Mermaid block into an IDE, GitHub wiki, or https://mermaid.live to render it visually. The Components table explains why each block was chosen.

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
