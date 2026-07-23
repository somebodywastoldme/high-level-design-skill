# Component Catalog

Vendor-neutral logical building blocks for ML/AI system HLDs. Use each exact
component name as the diagram label. A card describes a responsibility, not a
product, deployment unit, protocol, or implementation detail.

## Load Balancer
**Purpose:** Distribute incoming traffic across equivalent entry points or serving instances.
**Use when:** A service needs horizontal scaling, availability across instances, or traffic distribution.
**Avoid / do not add when:** The diagram only needs a logical external entry point; use API Gateway / Edge when edge policy or API concerns matter.
**Typical interactions:** Receives client traffic and forwards it to API Gateway / Edge or a directly exposed service.
**NFRs commonly addressed:** Availability, throughput, resilience, and latency under load.
**Draw as:** An ingress node before a horizontally scaled service boundary.

## Workflow Manager
**Purpose:** Coordinate a multi-step process, including sequencing, state transitions, retries, and compensation.
**Use when:** A business or ML process spans several asynchronous or long-running steps.
**Avoid / do not add when:** A service is simply applying domain rules to one request; that responsibility belongs in Core Domain Service.
**Typical interactions:** Starts work through Queue or Event Bus, calls domain and ML components, and routes exceptions to DLQ → Review.
**NFRs commonly addressed:** Reliability, recoverability, traceability, and controlled long-running execution.
**Draw as:** A process-orchestration node connected to the steps it coordinates.

## Queue
**Purpose:** Buffer work for one or more consumers so producers and consumers can proceed independently.
**Use when:** Work can be processed asynchronously, needs back-pressure, or arrives in bursts.
**Avoid / do not add when:** Multiple consumers need to react independently to a published fact; use Event Bus for that fan-out.
**Typical interactions:** Accepts commands or work items from services and delivers them to a designated processing stage; failed work may go to DLQ → Review.
**NFRs commonly addressed:** Load smoothing, resilience, scalability, and fault isolation.
**Draw as:** A buffer between a producer and a downstream worker or service.

## Cache
**Purpose:** Retain reusable data or results close to the request path to reduce repeated work.
**Use when:** Repeated reads or computations make latency or dependency load a concern.
**Avoid / do not add when:** Users need discoverable corpus retrieval with filtering and ranking; use Search Index for that responsibility.
**Typical interactions:** Is read before an expensive source or model call and refreshed or invalidated by the owning service.
**NFRs commonly addressed:** Latency, throughput, cost efficiency, and dependency protection.
**Draw as:** A side store adjacent to the service that owns cache validity.

## Vector DB
**Purpose:** Store vector representations and support similarity-based retrieval.
**Use when:** The system retrieves semantically similar items or performs nearest-neighbor matching.
**Avoid / do not add when:** Retrieval relies only on structured queries or conventional text search without vector similarity.
**Typical interactions:** Receives embeddings from Model / Embeddings and returns candidate items to Workflow Manager or Re-ranking service.
**NFRs commonly addressed:** Retrieval quality, query latency, scalability, and data freshness.
**Draw as:** A retrieval store connected to embedding generation and candidate retrieval flows.

## Feature Store
**Purpose:** Provide governed, reusable feature definitions and values for ML training and serving.
**Use when:** The same features must remain consistent across offline preparation and online inference.
**Avoid / do not add when:** Features are local to one model and no cross-context consistency or reuse is required.
**Typical interactions:** Is populated by data-processing flows and read by training and Model / Embeddings serving flows.
**NFRs commonly addressed:** Consistency, reproducibility, freshness, and model quality.
**Draw as:** A shared ML data component between feature production and model use.

## Model / Embeddings
**Purpose:** Produce predictions, scores, classifications, generated outputs, or vector representations.
**Use when:** A system needs an ML inference or embedding-generation capability.
**Avoid / do not add when:** A deterministic domain rule or lookup can meet the requirement without ML inference.
**Typical interactions:** Consumes request context or features, may call Model API Proxy, and supplies results to Vector DB, Re-ranking service, or Core Domain Service.
**NFRs commonly addressed:** Quality, latency, scalability, reproducibility, and controlled model change.
**Draw as:** A logical ML inference component on the serving or processing path.

## Re-ranking service
**Purpose:** Improve the ordering of a small candidate set using richer relevance signals.
**Use when:** Initial retrieval is inexpensive but final result quality requires a more precise ranking step.
**Avoid / do not add when:** There is no candidate set or the first retrieval result already meets quality targets.
**Typical interactions:** Receives candidates from Vector DB, Search Index, or another retriever and returns an ordered subset to Workflow Manager.
**NFRs commonly addressed:** Result quality, relevance, latency budgeting, and explainability.
**Draw as:** A service after candidate retrieval and before result assembly.

## Scheduler
**Purpose:** Initiate work based on time, cadence, or planned windows.
**Use when:** The system needs periodic refresh, batch processing, expiry handling, or scheduled reconciliation.
**Avoid / do not add when:** Work begins solely from a user request or an event.
**Typical interactions:** Triggers Workflow Manager, Queue, or Core Domain Service for scheduled work.
**NFRs commonly addressed:** Freshness, timeliness, operational predictability, and cost control.
**Draw as:** A timer-trigger node off the main request path.

## Rights check
**Purpose:** Determine whether the current actor may access or perform an operation on a resource or result.
**Use when:** Data, model outputs, or actions have user-, tenant-, role-, or entitlement-specific restrictions.
**Avoid / do not add when:** Access is fully enforced at the edge and no resource-level decision remains; use Identity & Access for identity and broad authorization concerns.
**Typical interactions:** Receives actor and resource context from Core Domain Service or Workflow Manager and gates returned results.
**NFRs commonly addressed:** Security, privacy, compliance, and tenant isolation.
**Draw as:** A decision point immediately before protected data or an action is released.

## DLQ → Review
**Purpose:** Isolate failed, malformed, or repeatedly unprocessable work for diagnosis and corrective handling.
**Use when:** Asynchronous processing needs a bounded failure path that preserves the original work item.
**Avoid / do not add when:** A human must make a business decision on otherwise valid work; use Human Review for that explicit decision step.
**Typical interactions:** Receives exhausted or invalid messages from Queue or Event Bus consumers and sends selected items to Human Review or reprocessing.
**NFRs commonly addressed:** Resilience, recoverability, traceability, and operational safety.
**Draw as:** An exception branch from an asynchronous consumer to an isolated review path.

## Model API Proxy
**Purpose:** Provide one internal boundary for requests to externally managed model capabilities.
**Use when:** Multiple internal components need consistent access, policy enforcement, or observability for model calls.
**Avoid / do not add when:** No external or separately governed model boundary exists.
**Typical interactions:** Receives calls from Model / Embeddings or application services and invokes an external model capability under shared controls.
**NFRs commonly addressed:** Security, portability, cost control, observability, and resilience.
**Draw as:** A boundary component between internal services and an external model capability.

## API Gateway / Edge
**Purpose:** Apply API-facing concerns at the system boundary, such as request routing, rate limits, and protocol adaptation.
**Use when:** Multiple clients or APIs need a governed, externally visible entry point.
**Avoid / do not add when:** The only concern is distributing traffic among equivalent backends; use Load Balancer for that narrower responsibility.
**Typical interactions:** Accepts client requests, consults Identity & Access or Policy / Rules Service, and routes to Backend for Frontend or Core Domain Service.
**NFRs commonly addressed:** Security, API governance, availability, rate control, and compatibility.
**Draw as:** The outermost API boundary before internal application components.

## Identity & Access
**Purpose:** Establish actor identity and apply authentication, authorization, and entitlement decisions.
**Use when:** Users, services, tenants, or administrators require controlled access to system capabilities.
**Avoid / do not add when:** The diagram has no actors or protected capabilities in scope.
**Typical interactions:** Supplies identity context to API Gateway / Edge, Core Domain Service, Rights check, and Audit Log.
**NFRs commonly addressed:** Security, privacy, compliance, accountability, and tenant isolation.
**Draw as:** A shared security service connected to entry points and protected services.

## Core Domain Service
**Purpose:** Own domain behavior, invariants, and the authoritative handling of a business capability.
**Use when:** The system must apply business rules and manage domain state for a bounded capability.
**Avoid / do not add when:** The concern is only coordinating a multi-step process; use Workflow Manager for orchestration across services.
**Typical interactions:** Serves Backend for Frontend or API Gateway / Edge, persists to Operational Database, and publishes domain events through Event Bus.
**NFRs commonly addressed:** Correctness, maintainability, integrity, auditability, and evolvability.
**Draw as:** A service within a bounded domain area, connected to its authoritative data and events.

## Backend for Frontend
**Purpose:** Tailor an API and response composition to the needs of one client experience.
**Use when:** A web, mobile, partner, or specialized client needs a client-specific backend contract.
**Avoid / do not add when:** A general API can serve all clients without client-specific aggregation or adaptation.
**Typical interactions:** Receives requests from API Gateway / Edge and composes responses from Core Domain Service, Workflow Manager, or read-oriented components.
**NFRs commonly addressed:** Client performance, API usability, change isolation, and latency.
**Draw as:** A client-facing service between the edge and internal domain capabilities.

## Policy / Rules Service
**Purpose:** Evaluate centrally managed business, risk, eligibility, or compliance rules.
**Use when:** Rules change independently of application releases or must be consistently applied across capabilities.
**Avoid / do not add when:** Rules are simple, stable, and local to a single Core Domain Service.
**Typical interactions:** Is called by API Gateway / Edge, Core Domain Service, Workflow Manager, or Human Review to produce a decision or obligation.
**NFRs commonly addressed:** Consistency, compliance, change agility, explainability, and governance.
**Draw as:** A shared decision service on paths where policy affects an outcome.

## Event Bus
**Purpose:** Publish domain facts for independent subscribers without coupling the publisher to their processing.
**Use when:** Several consumers must react to the same event, or the architecture needs event-driven integration.
**Avoid / do not add when:** A producer is assigning one unit of work to a specific consumer; use Queue for that handoff.
**Typical interactions:** Receives events from Core Domain Service and distributes them to Analytics, Notification Service, Integration Adapter, and other subscribers.
**NFRs commonly addressed:** Scalability, extensibility, resilience, and integration decoupling.
**Draw as:** A central event channel with one publisher and multiple independent subscribers.

## Notification Service
**Purpose:** Decide and initiate user or stakeholder notifications about system events or outcomes.
**Use when:** The system must inform people through one or more communication channels.
**Avoid / do not add when:** The only requirement is reliable delivery to another system; use Webhook Delivery or Integration Adapter.
**Typical interactions:** Subscribes to Event Bus, uses Policy / Rules Service for preferences, and records delivery outcomes in Audit Log.
**NFRs commonly addressed:** Timeliness, user experience, reliability, preference compliance, and observability.
**Draw as:** A subscriber to business events with outbound notification channels beyond the system boundary.

## Webhook Delivery
**Purpose:** Reliably deliver event notifications to a registered external endpoint.
**Use when:** External systems must receive near-real-time callbacks about system events.
**Avoid / do not add when:** The recipient is a human user or the integration requires rich bidirectional translation; use Notification Service or Integration Adapter respectively.
**Typical interactions:** Receives delivery requests from Event Bus or Core Domain Service, invokes external endpoints, and routes failed attempts to DLQ → Review.
**NFRs commonly addressed:** Delivery reliability, retry safety, security, observability, and partner isolation.
**Draw as:** An outbound boundary component between internal events and an external system.

## Object Storage
**Purpose:** Retain large, immutable, or file-like objects separately from transactional records.
**Use when:** The system manages documents, media, datasets, model artifacts, or other binary content.
**Avoid / do not add when:** Data is small, highly relational, and requires transactional updates with domain records.
**Typical interactions:** Is written by ingestion or Core Domain Service and referenced by Operational Database, Model / Embeddings, or Human Review.
**NFRs commonly addressed:** Durability, scale, cost efficiency, retention, and data lifecycle management.
**Draw as:** A durable object repository adjacent to content producers and consumers.

## Operational Database
**Purpose:** Store authoritative, current operational state needed to execute domain transactions.
**Use when:** A Core Domain Service requires durable state with consistent reads and writes.
**Avoid / do not add when:** The workload is predominantly historical aggregation, reporting, or exploratory analysis; use Analytical Store.
**Typical interactions:** Is owned by Core Domain Service and may emit changes as events to Event Bus or feed governed data flows.
**NFRs commonly addressed:** Integrity, consistency, availability, recoverability, and auditability.
**Draw as:** A service-owned system-of-record data store.

## Analytical Store
**Purpose:** Retain historical, aggregated, and analysis-oriented data for reporting, measurement, and model evaluation.
**Use when:** The system needs cross-domain analysis, trends, experimentation, or large-scale read-heavy queries.
**Avoid / do not add when:** A transaction needs current authoritative state or strict operational update semantics; use Operational Database.
**Typical interactions:** Consumes events or governed data extracts and serves dashboards, analysis, and model evaluation workflows.
**NFRs commonly addressed:** Analytical performance, scalability, historical retention, and decision support.
**Draw as:** A read-oriented data destination outside the synchronous transaction path.

## Search Index
**Purpose:** Support user-facing retrieval over indexed content using text, filters, and relevance signals.
**Use when:** Users need discoverable search, filtering, faceting, or ranked results across a corpus.
**Avoid / do not add when:** The goal is only to reuse a known recent response; use Cache for temporary result reuse.
**Typical interactions:** Is populated from Object Storage, Operational Database, or Event Bus and queried by Core Domain Service, Backend for Frontend, or Re-ranking service.
**NFRs commonly addressed:** Search relevance, query latency, scalability, and data freshness.
**Draw as:** A derived read model fed from source-of-record changes.

## Integration Adapter
**Purpose:** Translate between the system's domain contract and an external system's interface or data model.
**Use when:** A partner, legacy, or third-party capability needs isolated integration logic.
**Avoid / do not add when:** The external party only needs event callbacks; use Webhook Delivery for the narrower outbound notification case.
**Typical interactions:** Exchanges commands or events with Core Domain Service or Event Bus and maps them to an external boundary.
**NFRs commonly addressed:** Maintainability, resilience, security, compatibility, and partner isolation.
**Draw as:** An anti-corruption boundary component between internal domain elements and an external system.

## Audit Log
**Purpose:** Preserve an append-only record of material actions, decisions, and access events.
**Use when:** The system needs accountability, investigation support, or evidence for governance obligations.
**Avoid / do not add when:** Operational telemetry alone is sufficient and no durable business or access record is required.
**Typical interactions:** Receives records from Identity & Access, Core Domain Service, Policy / Rules Service, Human Review, and administrative actions.
**NFRs commonly addressed:** Compliance, accountability, non-repudiation, traceability, and incident investigation.
**Draw as:** A shared append-only record fed by security and business decision points.

## Observability
**Purpose:** Collect and correlate signals that describe system behavior, health, and performance.
**Use when:** Operators need to detect, diagnose, and measure system behavior across services and workflows.
**Avoid / do not add when:** The diagram is intentionally limited to business capability boundaries and operational concerns are out of scope.
**Typical interactions:** Receives telemetry from all critical components and informs operational response and capacity decisions.
**NFRs commonly addressed:** Reliability, availability, performance, diagnosability, and operational readiness.
**Draw as:** A cross-cutting component connected lightly to the major runtime elements.

## Secrets / Key Management
**Purpose:** Govern sensitive credentials, cryptographic material, and their controlled use.
**Use when:** Components access protected dependencies, sign data, encrypt data, or rotate sensitive material.
**Avoid / do not add when:** The diagram has no sensitive credentials or cryptographic boundary in scope.
**Typical interactions:** Supplies controlled secret or key access to API Gateway / Edge, services, storage components, and Model API Proxy.
**NFRs commonly addressed:** Security, compliance, confidentiality, rotation safety, and auditability.
**Draw as:** A shared security component with restricted links to workloads that require sensitive material.

## Human Review
**Purpose:** Present valid but uncertain, exceptional, or high-impact cases to a person for a business decision.
**Use when:** Automation requires approval, correction, adjudication, or escalation before an outcome can proceed.
**Avoid / do not add when:** The item is merely a processing failure needing diagnosis; use DLQ → Review for that operational exception path.
**Typical interactions:** Receives cases from Workflow Manager, Policy / Rules Service, or DLQ → Review and returns a decision to Core Domain Service or Workflow Manager.
**NFRs commonly addressed:** Quality control, compliance, safety, explainability, and accountability.
**Draw as:** A human-in-the-loop decision step connected to the workflow that awaits its outcome.
