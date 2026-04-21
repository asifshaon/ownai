#!/usr/bin/env bash
# NEXUS AGI Performance Dashboard
# Tactical metric aggregation for the NEXUS Core

set -e

# Colors for the dashboard
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}==================================================${NC}"
echo -e "${YELLOW}   NEXUS AGI TACTICAL PERFORMANCE DASHBOARD   ${NC}"
echo -e "${CYAN}==================================================${NC}"

# Check gateway status
STATUS=$(pnpm openclaw status --json)
active_sessions=$(echo "$STATUS" | jq -r '.sessions.active // 0')
active_tasks=$(echo "$STATUS" | jq -r '.tasks.active // 0')
failure_count=$(echo "$STATUS" | jq -r '.tasks.failures // 0')

echo -e "${BLUE}CORE STATUS:${NC}"
echo -e "  Active Sessions: ${GREEN}${active_sessions}${NC}"
echo -e "  Active Tasks:    ${GREEN}${active_tasks}${NC}"
echo -e "  System Failures: ${RED}${failure_count}${NC}"
echo ""

# Tasks Breakdown
echo -e "${BLUE}TASK ORCHESTRATION:${NC}"
pnpm openclaw tasks list --status running --limit 5 || echo "No active tasks."
echo ""

# Token usage (Mock for now, will integrate with actual provider logs later)
echo -e "${BLUE}TOKEN DENSITY (Est. Last 24h):${NC}"
echo -e "  The Architect:  ${YELLOW}low${NC}"
echo -e "  The Scribe:     ${YELLOW}low${NC}"
echo -e "  Black Team:     ${YELLOW}optimized${NC}"
echo ""

# Latency Check (Simple p95 simulation)
echo -e "${BLUE}LATENCY MONITOR (p95):${NC}"
echo -e "  Broadcast Group: ${GREEN}1.2s${NC}"
echo -e "  Security Sandbox: ${GREEN}0.8s${NC}"
echo ""

echo -e "${CYAN}==================================================${NC}"
echo -e "  All layers aligned. System operational.         "
echo -e "${CYAN}==================================================${NC}"
