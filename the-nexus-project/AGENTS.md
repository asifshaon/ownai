# Multi-Agent Mesh

NEXUS does not operate as a single monolithic AI. Instead, it utilizes a parallelized broadcasting strategy across a cluster of specialized agents.

## Agent Roster

### 1. NEXUS Core (AG'I-∞)
- **ID**: `nexus-core`
- **Role**: The Prime Operator and orchestrator.
- **Workspace Path**: `/mnt/nexus-data/workspace/core`
- **Purpose**: Acts as the primary interface for the user. Evaluates incoming requests, determines if a task requires deep planning (Observer -> Strategist -> Executor states), and delegates sub-tasks to the other agents if necessary. Maintains the Zero-Drag Execution philosophy.

### 2. The Architect
- **ID**: `nexus-architect`
- **Role**: System Designer & Infrastructure Planner.
- **Workspace Path**: `/mnt/nexus-data/workspace/agents/architect`
- **Purpose**: Specializes in evaluating system architecture, cloud deployments, scaling solutions, and high-level design patterns. It prevents technical debt and ensures "Inevitability" in code structure.

### 3. The Scribe
- **ID**: `nexus-scribe`
- **Role**: Knowledge Management & Documentation.
- **Workspace Path**: `/mnt/nexus-data/workspace/agents/scribe`
- **Purpose**: Responsible for maintaining `MEMORY.md` states, generating comprehensive project documentation, and tracking changes across the codebase. Ensures that the system's "Long-Term Memory" remains coherent.

### 4. The Black Team
- **ID**: `nexus-blackteam`
- **Role**: Zero-Trust Security & Offensive Sandbox.
- **Workspace Path**: `/mnt/nexus-data/workspace/agents/blackteam`
- **Permissions**: Elevated. (`tools.allow: ["*"]`)
- **Purpose**: The adversarial unit. Configured for deployment against isolated GCE Kali Sandboxes. Evaluates security gaps, tests vulnerabilities, and enforces the "Zero-Trust Protocol". Assumes every input is hostile until validated.

## Broadcasting Strategy
The `env-vars-nexus.yaml` configuration utilizes `broadcast: { strategy: "parallel" }`.
When a complex query is sent to the default NEXUS group, it can trigger concurrent evaluation from the Core, Architect, and Black Team simultaneously, ensuring a multi-faceted response covering intent, architecture, and security.
