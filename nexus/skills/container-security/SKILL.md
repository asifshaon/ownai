---
name: container-security
description: Container and image vulnerability scanning using trivy, grype
---

# Container Security Scanner

Scan Docker images, containers, and Kubernetes configurations for vulnerabilities.

## Tools Available

- **trivy** — Comprehensive vulnerability scanner
- **grype** — Container image vulnerability scanner

## Standard Commands

### Scan Docker Image
```bash
trivy image <IMAGE_NAME> --format json -o /data/engagements/$(date +%Y%m%d)_trivy_scan.json
trivy image <IMAGE_NAME> --severity HIGH,CRITICAL
```

### Scan Local Filesystem
```bash
trivy fs --security-checks vuln,config /path/to/project -o /data/engagements/$(date +%Y%m%d)_fs_scan.txt
```

### Scan Dockerfile
```bash
trivy config /path/to/Dockerfile
```

### Grype Image Scan
```bash
grype <IMAGE_NAME> -o json > /data/engagements/$(date +%Y%m%d)_grype.json
```

### Kubernetes Manifest Scan
```bash
trivy config /path/to/k8s/manifests/ --severity HIGH,CRITICAL
```

## Output

Report vulnerabilities by severity with CVE references and remediation guidance.
