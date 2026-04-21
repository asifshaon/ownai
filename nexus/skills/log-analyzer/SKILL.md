---
name: log-analyzer
description: Security log analysis, anomaly detection, and incident investigation
---

# Security Log Analyzer

Analyze security logs to detect anomalies, investigate incidents, and identify indicators of compromise.

## Capabilities

- Authentication log analysis (SSH, Windows Event, Web)
- Failed login detection and brute force identification
- Anomalous access pattern detection
- Timeline reconstruction for incident response
- IOC extraction from logs

## Standard Commands

### SSH Auth Log Analysis
```bash
# Failed SSH logins
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | head -20

# Successful logins
grep "Accepted" /var/log/auth.log | awk '{print $9, $11}' | sort | uniq -c | sort -rn

# Brute force detection (>10 failures from same IP)
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | awk '$1 > 10'
```

### Apache/Nginx Access Log Analysis
```bash
# Top requesting IPs
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -20

# HTTP status code distribution
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# 404 hunting (directory traversal attempts)
grep " 404 " access.log | awk '{print $7}' | sort | uniq -c | sort -rn | head -30

# SQL injection attempts
grep -iE "(union|select|drop|insert|delete|update|exec|xp_)" access.log

# Common attack patterns
grep -iE "(\.\.\/|%2e%2e|passwd|etc\/shadow|cmd\.exe|/bin/bash)" access.log
```

### Windows Event Log Analysis
```bash
# Parse exported Windows event logs (EVTX → text)
python3 -c "
import json, sys
# Parse JSON-exported Windows event logs
with open(sys.argv[1]) as f:
    for line in f:
        event = json.loads(line)
        eid = event.get('EventID', '')
        if eid in [4624, 4625, 4648, 4672, 4688, 4698, 4720, 7045]:
            print(f'{event.get(\"TimeCreated\",\"\")} | {eid} | {event.get(\"Message\",\"\")[:200]}')
" <LOG_FILE>
```

### Timeline Construction
```bash
# Merge and sort multiple log sources by timestamp
cat auth.log access.log syslog | sort -k1,3 > /data/engagements/$(date +%Y%m%d)_timeline.txt
```

### IOC Extraction
```bash
# Extract IPs
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' <LOG_FILE> | sort -u > /data/engagements/iocs_ips.txt

# Extract URLs
grep -oE 'https?://[^ ]+' <LOG_FILE> | sort -u > /data/engagements/iocs_urls.txt

# Extract email addresses
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' <LOG_FILE> | sort -u > /data/engagements/iocs_emails.txt
```

## Output

Generate incident analysis report:
- Anomalies detected with severity
- Attack timeline reconstruction
- IOCs extracted
- Affected systems/accounts
- Recommended response actions
