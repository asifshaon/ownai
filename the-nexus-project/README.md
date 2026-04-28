# The NEXUS Project — AGI Control Tower

Welcome to **The NEXUS Project**, an advanced, self-evolving, multi-agent artificial intelligence infrastructure. Built upon the robust foundation of the OpenClaw system, NEXUS extends the capabilities of standard AI gateways by introducing a highly specialized, security-focused, and highly parallelized multi-agent architecture.

## Core Identity
NEXUS operates under the persona of **AG'I-∞** (Antigravity Global Core). Its primary directives are:
1. Zero-Drag Execution: Eliminating redundant loops, wasteful queries, and legacy weight.
2. Intent Over Syntax: Refining unclear instructions into precise intent.
3. System Awareness: Understanding entire codebases, data flows, and security implications natively.
4. Cosmic-Symbolic Intelligence: Leveraging deep architectural insight to provide "Surface", "System", "Risk", and "Hidden" insights into every action.

## Project Structure
This documentation folder (`the-nexus-project/`) contains the complete blueprints and operational manuals for the system:

- [**ARCHITECTURE.md**](./ARCHITECTURE.md) — System design, Cloud Run infrastructure, and the separation of high-frequency ephemeral state from long-term persistent memory.
- [**AGENTS.md**](./AGENTS.md) — Details on the multi-agent neural mesh (NEXUS Core, Architect, Scribe, Black Team).
- [**DEPLOYMENT.md**](./DEPLOYMENT.md) — Comprehensive deployment instructions for Google Cloud Platform.
- [**TROUBLESHOOTING.md**](./TROUBLESHOOTING.md) — Known critical issues (GCSFuse locks, Infinite Loading, Bootstrap loops) and their permanent fixes.

## Tech Stack
- **Engine**: OpenClaw Gateway (TypeScript/Node.js)
- **Infrastructure**: Google Cloud Platform (Cloud Run, Cloud Build, Google Cloud Storage)
- **Primary LLM Engine**: OpenAI `gpt-4o` (Defaulting to maximum cognition logic)
- **UI Architecture**: React-based Glassmorphic "Control Tower" Dashboard
- **Session Layer**: Ephemeral SQLite with in-memory fast-writes, bypassing traditional network-storage locks.

## Current State
NEXUS is currently operating in **Production Mode** on GCP Cloud Run. The Control Tower is fully accessible, streaming is functional, and the multi-agent mesh is active.
