---
name: wireless-audit
description: Wireless network security assessment using aircrack-ng suite
---

# Wireless Security Audit

Wireless network security assessment. Note: hardware-dependent tools have limited functionality in Docker containers.

## Tools Available

- **aircrack-ng** — WEP/WPA cracking
- **airodump-ng** — Wireless packet capture
- **aireplay-ng** — Packet injection

## Offline Hash Cracking (Primary Use in Docker)

### Crack WPA Handshake
```bash
aircrack-ng -w /usr/share/wordlists/rockyou.txt -b <BSSID> /data/engagements/capture.cap
```

### Convert to hashcat format
```bash
aircrack-ng /data/engagements/capture.cap -J /data/engagements/wpa_hash
hashcat -m 22000 /data/engagements/wpa_hash.hccapx /usr/share/wordlists/rockyou.txt
```

## Note

Full wireless testing (monitor mode, deauth, injection) requires:
- Physical wireless adapter with monitor mode support
- Host machine with USB passthrough to Docker container
- Most operations work better on bare metal Kali

This skill is primarily useful for offline handshake cracking and wireless security policy analysis.
