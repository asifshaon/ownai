---
name: network-monitor
description: Network traffic capture and protocol analysis using tcpdump and tshark
---

# Network Monitor

Capture and analyze network traffic for security monitoring, protocol analysis, and traffic forensics.

## Tools Available

- **tcpdump** — Command-line packet capture
- **tshark** — Terminal-based Wireshark
- **ngrep** — Network grep

## Standard Commands

### Capture All Traffic
```bash
sudo tcpdump -i eth0 -w /data/engagements/$(date +%Y%m%d)_capture.pcap -c 10000
```

### Capture Specific Host
```bash
sudo tcpdump -i eth0 host <TARGET_IP> -w /data/engagements/$(date +%Y%m%d)_host_capture.pcap
```

### Capture Specific Port
```bash
sudo tcpdump -i eth0 port <PORT> -nn -X | tee /data/engagements/$(date +%Y%m%d)_port_capture.txt
```

### HTTP Traffic Only
```bash
sudo tcpdump -i eth0 -A -s0 'tcp port 80 or tcp port 443' | tee /data/engagements/http_traffic.txt
```

### DNS Traffic
```bash
sudo tcpdump -i eth0 port 53 -nn | tee /data/engagements/dns_traffic.txt
```

### Tshark Analysis
```bash
# Protocol hierarchy
tshark -r /data/engagements/capture.pcap -z io,phs

# HTTP requests
tshark -r /data/engagements/capture.pcap -Y "http.request" -T fields -e ip.src -e http.host -e http.request.uri

# DNS queries
tshark -r /data/engagements/capture.pcap -Y "dns.qr == 0" -T fields -e ip.src -e dns.qry.name

# Credentials in cleartext
tshark -r /data/engagements/capture.pcap -Y "http.request.method == POST" -T fields -e ip.src -e http.host -e http.file_data
```

### Network Grep
```bash
sudo ngrep -d eth0 "password|login|user" port 80
```

## Output

Traffic analysis report with protocol breakdown, anomalies, and notable findings.
