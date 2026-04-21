#!/usr/bin/env bash
# NEXUS AGI Evolution Setup
# Configures the autonomous refactoring loop and self-correction cycles.

set -e

echo "Activating Architectural Self-Evolution Loop..."

# Add daily refactoring task for the Architect agent
# This job runs in an isolated session and uses 'nexus-architect'
pnpm openclaw cron add \
  --name "Architectural-Self-Evolution" \
  --cron "0 0 * * *" \
  --session isolated \
  --agent nexus-architect \
  --message "Scan the entire workspace (d:\work\ownai). Identify logic density issues, violations of AGENTS.md, or architectural drift. Stage a detailed refactor proposal in /proposals/architect/latest.md." \
  --announce \
  --channel system

echo "AGI Evolution Loop Registered Successfully."

# List cron jobs to verify
pnpm openclaw cron list
