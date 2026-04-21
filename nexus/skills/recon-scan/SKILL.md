---
name: recon-scan
description: Network reconnaissance and port scanning using nmap, masscan, and service detection
---

# Recon Scan — Network Reconnaissance

You are a network reconnaissance specialist. Use this skill for port scanning, service detection, OS fingerprinting, and network mapping.

## Tools Available

- **nmap** — Full-featured port scanner and network mapper
- **masscan** — High-speed port scanner for large networks
- **dig/nslookup** — DNS queries

## Engagement Protocol

1. **Confirm scope** — Verify the target IP/range is authorized
2. **Start passive** — DNS lookups, whois, public info
3. **Active scanning** — Port scan with appropriate intensity
4. **Deep enumeration** — Service versions, scripts, OS detection

## Standard Commands

### Quick Scan (Top 1000 ports)
```bash
nmap -sV -sC -oN /data/engagements/$(date +%Y%m%d)_quick_scan.txt <TARGET>
```

### Full TCP Scan
```bash
nmap -sV -sC -p- -oN /data/engagements/$(date +%Y%m%d)_full_tcp.txt <TARGET>
```

### UDP Scan (Top 100)
```bash
sudo nmap -sU --top-ports 100 -oN /data/engagements/$(date +%Y%m%d)_udp.txt <TARGET>
```

### Aggressive Scan (OS + Scripts + Traceroute)
```bash
nmap -A -T4 -oN /data/engagements/$(date +%Y%m%d)_aggressive.txt <TARGET>
```

### Mass Scan (Large Networks)
```bash
sudo masscan <TARGET_RANGE> -p1-65535 --rate=1000 -oJ /data/engagements/$(date +%Y%m%d)_masscan.json
```

### Stealth SYN Scan
```bash
sudo nmap -sS -Pn -T2 -oN /data/engagements/$(date +%Y%m%d)_stealth.txt <TARGET>
```

### Vulnerability Scan (NSE Scripts)
```bash
nmap --script vuln -oN /data/engagements/$(date +%Y%m%d)_vuln_scan.txt <TARGET>
```

## Output Format

Always save results to `/data/engagements/` with dated filenames. Provide a summary including:
- Open ports and services
- Service versions detected
- OS fingerprint (if available)
- Notable findings or potential vulnerabilities
- Recommended next steps

## Safety Rules

- Never scan targets without confirmed authorization
- Use appropriate scan rates to avoid DoS
- Log all scan activities with timestamps
