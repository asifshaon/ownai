# 🧿 NEXUS — AI Cybersecurity Operations Platform

**An autonomous AI assistant for security operations, built on OpenClaw.**

## Architecture

```
[You] → [Cloud Run: OpenClaw Gateway + Gemini] → [GCE: Kali Sandbox + Ubuntu Worker]
```

## Quick Start

### Prerequisites
- Google Cloud SDK (`gcloud`)
- Docker & Docker Compose
- GCP project with billing enabled

### 1. Set Environment Variables
```bash
export GCP_PROJECT_ID="ai-assistent-491400"
export GOOGLE_API_KEY="your-gemini-api-key"
```

### 2. Provision Sandbox Infrastructure
```bash
chmod +x nexus/scripts/*.sh
./nexus/scripts/provision-nexus-gce.sh
```

### 3. Deploy Gateway to Cloud Run
```bash
./nexus/scripts/deploy-nexus-cloudrun.sh
```

### 4. Start/Stop Sandbox (Save Money)
```bash
./nexus/scripts/nexus-start.sh   # Start when you need it
./nexus/scripts/nexus-stop.sh    # Stop to save compute cost
```

## Skills (15 Total)

### Offensive (9)
| Skill | Purpose |
|-------|---------|
| `recon-scan` | Port scanning, service detection (nmap, masscan) |
| `web-vuln-scan` | Web app vulnerabilities (sqlmap, nikto, wfuzz) |
| `osint-gather` | OSINT collection (theHarvester, amass, subfinder) |
| `password-crack` | Hash cracking, brute force (hashcat, john, hydra) |
| `exploit-ops` | Exploitation (Metasploit, msfvenom) |
| `network-ops` | Lateral movement (impacket, responder, crackmapexec) |
| `social-engineer` | Phishing simulation |
| `wireless-audit` | WiFi security (aircrack-ng) |
| `post-exploit` | Privilege escalation, persistence |

### Defensive (5)
| Skill | Purpose |
|-------|---------|
| `log-analyzer` | Security log analysis, anomaly detection |
| `container-security` | Docker/image vulnerability scanning (trivy) |
| `threat-intel` | Threat feeds (VirusTotal, OTX, AbuseIPDB) |
| `forensic-analysis` | Memory forensics, file carving (volatility3) |
| `network-monitor` | Traffic capture and analysis (tcpdump, tshark) |

### Reporting (1)
| Skill | Purpose |
|-------|---------|
| `report-generator` | Professional pentest reports (Markdown + PDF) |

## Directory Structure

```
nexus/
├── Dockerfile.sandbox-kali       # Kali Linux security container
├── Dockerfile.sandbox-ubuntu     # Ubuntu worker container
├── docker-compose.nexus.yml      # Container orchestration
├── config/
│   ├── nexus-openclaw.json       # OpenClaw configuration
│   ├── nexus_key                 # SSH private key (generated)
│   └── nexus_key.pub             # SSH public key (generated)
├── workspace/
│   ├── SOUL.md                   # AI persona
│   └── AGENTS.md                 # Agent configuration
├── skills/                       # 15 cybersecurity skills
│   ├── recon-scan/
│   ├── web-vuln-scan/
│   ├── osint-gather/
│   ├── password-crack/
│   ├── exploit-ops/
│   ├── network-ops/
│   ├── social-engineer/
│   ├── wireless-audit/
│   ├── post-exploit/
│   ├── log-analyzer/
│   ├── container-security/
│   ├── threat-intel/
│   ├── forensic-analysis/
│   ├── network-monitor/
│   └── report-generator/
└── scripts/
    ├── provision-nexus-gce.sh    # GCE setup
    ├── deploy-nexus-cloudrun.sh  # Gateway deployment
    ├── nexus-start.sh            # Start sandbox
    └── nexus-stop.sh             # Stop sandbox
```

## Upstream Sync

This is a fork of [OpenClaw](https://github.com/openclaw/openclaw). All NEXUS changes are isolated in the `nexus/` directory.

### Pull upstream updates:
```bash
git fetch upstream
git merge upstream/main
# NEXUS files in nexus/ will not conflict with upstream
```

### Never push to upstream:
```bash
# Always push to origin (your fork) only
git push origin nexus/phase-1
```

## Budget (60 Days)

| Resource | Cost |
|----------|------|
| Cloud Run Gateway | ~$50 |
| GCE Spot Instance | ~$30 |
| Storage + Network | ~$25 |
| Gemini API | ~$15-30 |
| **Total** | **~$120-135** |

## Security

- All operations run inside Docker sandboxes (never on host)
- SSH key authentication only (no passwords)
- GCE firewall: IAP tunnel only (no public IP)
- Engagement data stored in isolated volumes
- Audit logging for all tool invocations
