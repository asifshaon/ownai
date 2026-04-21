---
name: osint-gather
description: Open Source Intelligence gathering using theHarvester, amass, subfinder, Shodan
---

# OSINT Gathering

You are an OSINT specialist. Use this skill for information gathering from public sources — domains, emails, subdomains, exposed services, and digital footprints.

## Tools Available

- **theHarvester** — Email, subdomain, and name harvesting
- **amass** — Attack surface mapping and subdomain enumeration
- **subfinder** — Fast subdomain discovery
- **Shodan CLI** — Internet-connected device search (requires API key)
- **whois/dig** — Domain registration and DNS info
- **recon-ng** — Full OSINT framework

## Standard Commands

### Domain Information
```bash
whois <DOMAIN> | tee /data/engagements/$(date +%Y%m%d)_whois_$(echo <DOMAIN> | tr '.' '_').txt
```

### DNS Enumeration
```bash
dig <DOMAIN> ANY +noall +answer | tee /data/engagements/$(date +%Y%m%d)_dns.txt
dig <DOMAIN> MX +short >> /data/engagements/$(date +%Y%m%d)_dns.txt
dig <DOMAIN> TXT +short >> /data/engagements/$(date +%Y%m%d)_dns.txt
dig <DOMAIN> NS +short >> /data/engagements/$(date +%Y%m%d)_dns.txt
```

### Email Harvesting
```bash
theHarvester -d <DOMAIN> -b all -f /data/engagements/$(date +%Y%m%d)_harvest
```

### Subdomain Enumeration (Fast)
```bash
subfinder -d <DOMAIN> -o /data/engagements/$(date +%Y%m%d)_subdomains.txt
```

### Subdomain Enumeration (Thorough)
```bash
amass enum -d <DOMAIN> -o /data/engagements/$(date +%Y%m%d)_amass.txt
```

### HTTP Probe Discovered Subdomains
```bash
cat /data/engagements/$(date +%Y%m%d)_subdomains.txt | httpx -silent -status-code -title -o /data/engagements/$(date +%Y%m%d)_live_hosts.txt
```

### Shodan Search (requires SHODAN_API_KEY)
```bash
shodan search "hostname:<DOMAIN>" --fields ip_str,port,org,os --separator "," > /data/engagements/$(date +%Y%m%d)_shodan.csv
```

### Reverse DNS Lookup
```bash
for ip in $(cat /data/engagements/ips.txt); do
  echo "$ip: $(dig +short -x $ip)" >> /data/engagements/$(date +%Y%m%d)_rdns.txt
done
```

### Full Recon Pipeline
```bash
DOMAIN=<DOMAIN>
DATE=$(date +%Y%m%d)
OUT=/data/engagements/${DATE}_${DOMAIN//\./_}
mkdir -p $OUT

whois $DOMAIN > $OUT/whois.txt
dig $DOMAIN ANY +noall +answer > $OUT/dns.txt
subfinder -d $DOMAIN -o $OUT/subdomains.txt
cat $OUT/subdomains.txt | httpx -silent -status-code -title > $OUT/live_hosts.txt
theHarvester -d $DOMAIN -b all -f $OUT/harvest
echo "Recon complete. Results in $OUT/"
```

## Output

Compile findings into structured intelligence report:
- Domain registration details
- DNS configuration
- Discovered subdomains (with HTTP status)
- Email addresses found
- Exposed services
- Attack surface summary
