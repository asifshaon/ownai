---
name: threat-intel
description: Threat intelligence gathering from public feeds and reputation services
---

# Threat Intelligence

Gather threat intelligence from public sources, check IOCs against reputation databases, and compile threat reports.

## APIs & Sources

- **VirusTotal** — File/URL/IP reputation (requires API key in VIRUSTOTAL_API_KEY)
- **AbuseIPDB** — IP reputation (requires API key in ABUSEIPDB_API_KEY)
- **AlienVault OTX** — Open threat intelligence (requires API key in OTX_API_KEY)
- **Shodan** — Internet device search (requires API key in SHODAN_API_KEY)

## Standard Commands

### Check IP Reputation (VirusTotal)
```bash
curl -s "https://www.virustotal.com/api/v3/ip_addresses/<IP>" \
  -H "x-apikey: $VIRUSTOTAL_API_KEY" | jq '.data.attributes.last_analysis_stats'
```

### Check IP on AbuseIPDB
```bash
curl -s "https://api.abuseipdb.com/api/v2/check?ipAddress=<IP>&maxAgeInDays=90" \
  -H "Key: $ABUSEIPDB_API_KEY" -H "Accept: application/json" | jq '.data'
```

### Check File Hash (VirusTotal)
```bash
curl -s "https://www.virustotal.com/api/v3/files/<HASH>" \
  -H "x-apikey: $VIRUSTOTAL_API_KEY" | jq '.data.attributes.last_analysis_stats'
```

### Shodan Host Lookup
```bash
shodan host <IP>
```

### AlienVault OTX Pulse Search
```python
python3 << 'EOF'
from OTXv2 import OTXv2
import os, json
otx = OTXv2(os.environ.get('OTX_API_KEY', ''))
results = otx.get_indicator_details_full(otx.IndicatorTypes.IPv4, '<IP>')
print(json.dumps(results.get('general', {}), indent=2))
EOF
```

### Bulk IOC Check
```bash
while read ioc; do
  echo -n "$ioc: "
  curl -s "https://www.virustotal.com/api/v3/ip_addresses/$ioc" \
    -H "x-apikey: $VIRUSTOTAL_API_KEY" | jq -r '.data.attributes.last_analysis_stats.malicious'
  sleep 15  # Rate limiting
done < /data/engagements/iocs.txt > /data/engagements/$(date +%Y%m%d)_ioc_results.txt
```

## Output

Compile threat intelligence brief with source attribution, confidence levels, and recommended actions.
