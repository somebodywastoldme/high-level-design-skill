# Component Catalog

Reusable HLD building blocks for ML/AI systems. Each card: purpose · when to
include (the NFR it satisfies) · typical tech · how to draw it. Use the exact
block name as the Mermaid node label.

## Load Balancer
- **Purpose:** Distribute incoming requests across serving replicas; the single entry point of the serving pipeline.
- **Include when:** any online serving NFR — high throughput (QPS) or availability target.
- **Typical tech:** NGINX, Envoy, cloud L7 LB.
- **Draw as:** rightmost node; external `Request` arrow enters here, then flows to `Workflow Manager`.

## Workflow Manager
- **Purpose:** Orchestrate a single request end to end, calling downstream services in the right order and assembling the response.
- **Include when:** always present in the serving path — it orchestrates the request regardless of other NFRs.
- **Typical tech:** application service or a step/task orchestrator.
- **Draw as:** placed right after `Load Balancer`; fans out to `Cache`, `Model / Embeddings`, `Re-ranking service`, and `Rights check`.

## Queue
- **Purpose:** Decouple producers from consumers and absorb bursty or asynchronous load without blocking the caller.
- **Include when:** the system needs async ingestion, decoupling between stages, or must tolerate bursty load.
- **Typical tech:** Kafka, SQS, RabbitMQ.
- **Draw as:** left side of the ingestion flow; an `event` arrow enters the `Queue`, which then feeds a processor.

## Cache
- **Purpose:** Serve repeated or recent results quickly, avoiding recomputation on the hot path.
- **Include when:** there is a tight latency p95 target or a workload with repeated queries.
- **Typical tech:** Redis, GPTCache (semantic caching).
- **Draw as:** sits between `Workflow Manager` and the heavy compute step; label whether it caches "semantic" (query-similarity) or plain "results".

## Vector DB
- **Purpose:** Store embeddings and serve similarity search over them.
- **Include when:** the system needs similarity search or embeddings retrieval.
- **Typical tech:** Elasticsearch, Qdrant, pgvector.
- **Draw as:** center of the diagram; written to by the ingestion path and read from by the serving path.

## Feature Store
- **Purpose:** Provide a consistent set of features shared between online serving and offline training/batch jobs.
- **Include when:** the system is a recommender or otherwise needs features shared across online and offline paths.
- **Typical tech:** Feast, or a custom feature store.
- **Draw as:** fed by feature-calculation jobs; read at serving time by `Workflow Manager` or the model step.

## Model / Embeddings
- **Purpose:** Run inference — score, classify, or embed — against a trained model.
- **Include when:** any inference step or embedding-generation step is needed.
- **Typical tech:** a served model endpoint or an embeddings API.
- **Draw as:** called both by the ingestion-side processor and by the serving path.

## Re-ranking service
- **Purpose:** Improve result quality by re-scoring a small candidate set after cheap retrieval.
- **Include when:** quality matters after an initial cheap candidate-retrieval step.
- **Typical tech:** a cross-encoder or dedicated ranking model.
- **Draw as:** placed after the similarity/candidate-retrieval step and before the response is returned.

## Scheduler
- **Purpose:** Trigger periodic or batch work on a timer, independent of user requests.
- **Include when:** the system needs periodic/batch reprocessing or freshness on a fixed interval.
- **Typical tech:** cron, Airflow.
- **Draw as:** drives the ingestion or feature-calculation path on a timer, off to the side of the main request flow.

## Rights check
- **Purpose:** Enforce per-user access control on results before they leave the system.
- **Include when:** results require per-user access control.
- **Typical tech:** an authorization (authz) service.
- **Draw as:** in the serving path, placed just before results are returned to the caller.

## DLQ → Review
- **Purpose:** Capture low-confidence or failed items for human review instead of silently serving or dropping them.
- **Include when:** the model can produce low-confidence outputs that need human-in-the-loop review.
- **Typical tech:** a dead-letter queue plus a review UI.
- **Draw as:** a branch off the main processing path for low-confidence items, leading to a review step.

## Model API Proxy
- **Purpose:** Mediate calls to external LLM or embeddings providers behind a single internal interface.
- **Include when:** the system calls an external LLM or embeddings provider.
- **Typical tech:** LiteLLM or an equivalent gateway.
- **Draw as:** between internal services and an external `LLM Provider` node, at the boundary of the diagram.
