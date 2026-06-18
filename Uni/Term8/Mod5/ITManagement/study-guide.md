# IT Management — 10-Minute Study Guide

## 1. ITSM Fundamentals (2 min)

**ITSM** = set of processes, best practices, and tools to **plan, deliver, operate, and improve** IT services.

### Key Management Areas

| Area | Purpose |
|------|---------|
| Hardware Management | Maintain devices (servers, storage, network) operational |
| Software Management | Install, update, configure, monitor OS & apps |
| User & Permissions | Control resource access, enforce usage policies |
| Cybersecurity | Protect systems & data against attacks |
| Monitoring & Performance | Maintain efficient performance, detect issues early |
| Backup Management | Guarantee information recovery (non-negotiable) |
| Networking | Enable communication between devices |
| Incident Management | Restore services after unplanned events |
| Change Management | Evaluate & control infrastructure modifications |
| Planning & CI | Continuously optimize IT services |

**Goal**: Prevent errors through constant mgmt, backups, change mgmt, version control, and continuous improvement.

---

## 2. ITIL Overview (2 min)

**ITIL** (Information Technology Infrastructure Library) = best practices framework for ITSM, developed 1980s by UK govt.

**Purpose**: Align IT services with business needs, standardize processes, improve quality/efficiency/security, reduce risks, optimize costs, improve customer satisfaction.

### Version Evolution

| Version | Year | Focus |
|---------|------|-------|
| v1 | 1989 | 30+ books, functional |
| v2 | 2001 | 7 titles, process-based, global standard |
| v3 | 2007 | **Service lifecycle** (5 stages, 26 processes) |
| 2011 | 2011 | Corrections to v3 |
| **ITIL 4** | **2019** | **Holistic SVS, 4 dimensions, Agile/DevOps/Lean** |
| **ITIL 5** | **2026** | **AI-native, product+service lifecycle, AI governance** |

---

## 3. ITIL 4 — Key Concepts (3 min)

### Service Value System (SVS)

Components that work together to enable value creation:

- **Guiding Principles**
- **Governance**
- **Service Value Chain (SVC)**
- **Practices**
- **Continual Improvement**

### 4 Dimensions of Service Management

1. **Organizations & People** — culture, roles, skills
2. **Information & Technology** — data, systems, AI capabilities
3. **Partners & Suppliers** — external dependencies
4. **Value Streams & Processes** — workflows, activities

### 7 Guiding Principles

1. **Focus on value** — everything maps to stakeholder value
2. **Start where you are** — assess current state, reuse what works
3. **Progress iteratively with feedback** — short cycles, continuous feedback
4. **Collaborate and promote visibility** — cross-team, visible dashboards
5. **Think and work holistically** — consider the full system
6. **Keep it simple and practical** — avoid over-engineering
7. **Optimize and automate** — streamline, automate repetitive tasks

### Service Value Chain (SVC) — 6 Activities

`Plan → Improve → Engage → Design & Transition → Obtain/Build → Deliver & Support`

### Key Definitions

| Term | Definition |
|------|------------|
| **Service** | Enables value co-creation by facilitating outcomes without managing specific costs/risks |
| **Utility** | "What the service does" — fit for purpose |
| **Warranty** | "How the service performs" — fit for use (availability, capacity, security, continuity) |
| **Service Management** | Specialized organizational capabilities for enabling value as services |

---

## 4. ITIL Lifecycle (v3) — Still Important (2 min)

| Stage | Objective | Key Processes |
|-------|-----------|---------------|
| **Service Strategy** | What services to offer? How to generate value? | Portfolio mgmt, financial mgmt, demand mgmt |
| **Service Design** | Design/modify services per business needs | SLM, capacity mgmt, availability mgmt, security, continuity, service catalogue |
| **Service Transition** | Build, test, deploy with minimal risk | Change mgmt, CMDB, release & deployment, testing |
| **Service Operation** | Daily effective & efficient delivery | Incident mgmt, problem mgmt, service requests, event mgmt, access mgmt |
| **Continual Service Improvement (CSI)** | Continuously evaluate & improve | CSI model, metrics-based improvement |

### Critical Distinctions

- **Incident** = unplanned interruption (restore ASAP)
- **Problem** = root cause of incidents (prevent recurrence)
- **Known Error** = problem with documented root cause & workaround
- **CMDB** = Configuration Management Database — tracks all service assets

---

## 5. ITIL 5 (2026) — What's New (1 min)

Released **February 2026** by PeopleCert.

### Key Innovations

- **AI-native by design** — framework designed for AI augmentation across all roles, activities, and practices
- **Product & Service Lifecycle Model (PSLM)** — unified end-to-end lifecycle, breaking silos between dev and ops
- **AI Governance** — dedicated publication & certification for responsible AI: guardrails, ethics, risk mgmt
- **ITIL AI Capability Model (6C)**: Creation, Curation, Clarification, Cognition, Communication, Coordination
- **New publication structure**: ITIL Strategy, Product, Service, Experience, Transformation, AI Governance
- **Human accountability** — AI can recommend, but humans own decisions & risks

### Shifts from ITIL 4

| ITIL 4 | ITIL 5 |
|--------|--------|
| ITSM focus | Digital Product & Service Management |
| Cloud-native | AI-native + cloud |
| 4 dimensions | 4 dimensions + AI capability model |
| SVS | SVS + PSLM |
| Standard practices | AI-augmented practices |

---

## 6. Exam Tips (30 sec)

- **ITIL 4 Foundation**: 40 questions, 60 min, 65% pass (26/40)
- **7 practices in depth** = ~42% of exam marks (prioritize: Continual Improvement, Change Enablement, Incident, Problem, Service Request, Service Desk, SLM)
- Know your definitions (service, utility, warranty, SLA, etc.)
- Remember the **7 Guiding Principles** acronym: F-S-P-C-T-K-O (Focus, Start, Progress, Collaborate, Think, Keep, Optimize)
