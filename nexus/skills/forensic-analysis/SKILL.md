---
name: forensic-analysis
description: Digital forensics, memory analysis, file carving, and artifact examination
---

# Digital Forensics

Perform digital forensic analysis including memory forensics, file carving, metadata extraction, and artifact examination.

## Tools Available

- **volatility3** — Memory forensics framework
- **binwalk** — Firmware analysis and file extraction
- **foremost** — File carving from disk images
- **exiftool** — Metadata extraction
- **strings** — Extract printable strings from binaries
- **steghide** — Steganography detection

## Memory Forensics (Volatility3)

### List Processes
```bash
vol -f <MEMORY_DUMP> windows.pslist.PsList | tee /data/engagements/$(date +%Y%m%d)_processes.txt
```

### Network Connections
```bash
vol -f <MEMORY_DUMP> windows.netscan.NetScan | tee /data/engagements/$(date +%Y%m%d)_netconns.txt
```

### Command History
```bash
vol -f <MEMORY_DUMP> windows.cmdline.CmdLine | tee /data/engagements/$(date +%Y%m%d)_cmdline.txt
```

### Registry Hives
```bash
vol -f <MEMORY_DUMP> windows.registry.hivelist.HiveList
```

### File Extraction
```bash
vol -f <MEMORY_DUMP> windows.dumpfiles.DumpFiles --pid <PID> -o /data/engagements/dumped_files/
```

### Malware Detection
```bash
vol -f <MEMORY_DUMP> windows.malfind.Malfind | tee /data/engagements/$(date +%Y%m%d)_malfind.txt
```

## File Analysis

### Binwalk (Firmware/Binary Analysis)
```bash
binwalk <FILE>
binwalk -e <FILE> -C /data/engagements/extracted/  # Extract embedded files
```

### File Carving
```bash
foremost -i <DISK_IMAGE> -o /data/engagements/carved_files/
```

### Metadata Extraction
```bash
exiftool <FILE> | tee /data/engagements/$(date +%Y%m%d)_metadata.txt
```

### String Extraction
```bash
strings -n 8 <BINARY> | tee /data/engagements/$(date +%Y%m%d)_strings.txt
strings -el <BINARY> >> /data/engagements/$(date +%Y%m%d)_strings.txt  # Wide strings
```

### Steganography
```bash
steghide info <IMAGE_FILE>
steghide extract -sf <IMAGE_FILE> -p <PASSWORD>
```

## Output

Forensic report with:
- Evidence chain documentation
- Timeline of events
- Artifacts recovered
- IOCs identified
- Analysis methodology
