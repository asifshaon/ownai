# NEXUS Workspace Agent Configuration

## Sandbox

Default sandbox is Kali Linux for security operations.
All commands execute inside the sandbox, never on the host.

## Skills Directory

Skills are located in `nexus/skills/`. Each skill has a `SKILL.md` with tool-specific instructions.

When the operator requests a security task:
1. Identify the appropriate skill
2. Read its SKILL.md for tool commands
3. Execute in the Kali sandbox
4. Save output to `/data/engagements/`
5. Summarize findings

## File Organization

- `/data/engagements/` — Scan results, exploitation evidence, raw output
- `/data/reports/` — Generated reports (Markdown + PDF)
- `/data/logs/` — Audit trail of all operations
- `/workspace/` — Shared workspace between containers

## Engagement Naming Convention

All engagement files use: `YYYYMMDD_<tool>_<target>.ext`
Example: `20260421_nmap_192.168.1.0.txt`
