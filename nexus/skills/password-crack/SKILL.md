---
name: password-crack
description: Password auditing and hash cracking using hashcat, john, hydra, medusa
---

# Password Cracking & Credential Auditing

You are a credential security specialist. Use this skill for hash cracking, password auditing, brute force testing, and credential stuffing against authorized targets.

## Tools Available

- **hashcat** — GPU-accelerated hash cracking (CPU mode in Docker)
- **john** (John the Ripper) — Versatile password cracker
- **hydra** — Network login brute forcer
- **medusa** — Parallel network login brute forcer
- **crunch** — Wordlist generator
- **cewl** — Custom wordlist from website content

## Hash Identification

```bash
# Identify hash type
hashcat --identify <HASH_FILE>
# or manually check: https://hashcat.net/wiki/doku.php?id=example_hashes
```

Common hash modes:
- `0` = MD5
- `100` = SHA1
- `1000` = NTLM
- `1800` = sha512crypt (Linux)
- `3200` = bcrypt
- `1400` = SHA-256
- `5600` = NetNTLMv2

## Standard Commands

### Hashcat Dictionary Attack
```bash
hashcat -m <MODE> -a 0 <HASH_FILE> /usr/share/wordlists/rockyou.txt -o /data/engagements/$(date +%Y%m%d)_cracked.txt
```

### Hashcat with Rules
```bash
hashcat -m <MODE> -a 0 <HASH_FILE> /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule -o /data/engagements/cracked.txt
```

### Hashcat Brute Force
```bash
hashcat -m <MODE> -a 3 <HASH_FILE> ?a?a?a?a?a?a?a?a --increment
```

### John the Ripper
```bash
john --wordlist=/usr/share/wordlists/rockyou.txt <HASH_FILE>
john --show <HASH_FILE> > /data/engagements/$(date +%Y%m%d)_john_cracked.txt
```

### Hydra SSH Brute Force
```bash
hydra -l <USER> -P /usr/share/wordlists/rockyou.txt <TARGET> ssh -t 4 -o /data/engagements/$(date +%Y%m%d)_hydra_ssh.txt
```

### Hydra HTTP POST Login
```bash
hydra -l <USER> -P /usr/share/wordlists/rockyou.txt <TARGET> http-post-form "/login:username=^USER^&password=^PASS^:Invalid" -o /data/engagements/hydra_http.txt
```

### Hydra FTP
```bash
hydra -l <USER> -P /usr/share/wordlists/rockyou.txt <TARGET> ftp -o /data/engagements/hydra_ftp.txt
```

### Custom Wordlist from Target Website
```bash
cewl <TARGET_URL> -d 3 -m 6 -w /data/engagements/$(date +%Y%m%d)_custom_wordlist.txt
```

### Generate Wordlist with Crunch
```bash
crunch 8 12 abcdefghijklmnopqrstuvwxyz0123456789 -o /data/engagements/custom_brute.txt
```

## Output

Report includes:
- Hashes cracked vs total
- Cracked credentials (sanitized in reports)
- Password policy analysis
- Time taken and method used
- Recommendations for password policy improvement
