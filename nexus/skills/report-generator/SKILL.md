---
name: report-generator
description: Generate professional penetration testing and security assessment reports
---

# Report Generator

Generate professional, structured security assessment reports with executive summaries, technical findings, CVSS scoring, and remediation recommendations.

## Report Templates

### Full Pentest Report
```bash
cat << 'EOF' > /data/reports/$(date +%Y%m%d)_pentest_report.md
# Penetration Test Report

**Client:** [CLIENT_NAME]
**Date:** $(date +%Y-%m-%d)
**Tester:** NEXUS AI Security Platform
**Classification:** CONFIDENTIAL

---

## 1. Executive Summary

This report presents the findings of [TYPE] penetration test conducted against [SCOPE].

**Overall Risk Rating:** [CRITICAL/HIGH/MEDIUM/LOW]

### Key Statistics
| Metric | Count |
|--------|-------|
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 0 |
| Informational | 0 |

---

## 2. Scope & Methodology

### 2.1 Scope
- Target(s): [TARGETS]
- Testing Type: [BLACKBOX/GREYBOX/WHITEBOX]
- Duration: [START] to [END]

### 2.2 Methodology
- OWASP Testing Guide v4
- PTES (Penetration Testing Execution Standard)
- NIST SP 800-115

---

## 3. Findings

### Finding 1: [TITLE]
- **Severity:** [CRITICAL/HIGH/MEDIUM/LOW]
- **CVSS Score:** [X.X]
- **Affected Asset:** [TARGET]
- **Description:** [DETAILED DESCRIPTION]
- **Evidence:** [PROOF OF CONCEPT]
- **Impact:** [BUSINESS IMPACT]
- **Remediation:** [FIX STEPS]

---

## 4. Remediation Summary

| # | Finding | Severity | Status | Priority |
|---|---------|----------|--------|----------|
| 1 | [TITLE] | [SEV] | Open | [P1-P4] |

---

## 5. Appendices

### A. Tools Used
### B. Raw Scan Output
### C. Screenshots/Evidence

EOF
echo "Report template created at /data/reports/"
```

### Convert to PDF
```bash
pandoc /data/reports/report.md -o /data/reports/report.pdf \
  --pdf-engine=wkhtmltopdf \
  --css=/data/reports/style.css \
  -V margin-top=20mm -V margin-bottom=20mm
```

### CVSS Calculator
```python
python3 << 'CVSS'
import sys

# CVSS v3.1 Base Score Calculator (simplified)
vectors = {
    'AV': {'N': 0.85, 'A': 0.62, 'L': 0.55, 'P': 0.20},
    'AC': {'L': 0.77, 'H': 0.44},
    'PR': {'N': 0.85, 'L': 0.62, 'H': 0.27},
    'UI': {'N': 0.85, 'R': 0.62},
    'S':  {'U': 'unchanged', 'C': 'changed'},
    'C':  {'H': 0.56, 'L': 0.22, 'N': 0},
    'I':  {'H': 0.56, 'L': 0.22, 'N': 0},
    'A':  {'H': 0.56, 'L': 0.22, 'N': 0},
}

# Usage: python3 cvss.py AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
vector_string = sys.argv[1] if len(sys.argv) > 1 else "AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H"
print(f"CVSS Vector: {vector_string}")
print("Use https://www.first.org/cvss/calculator/3.1 for precise scoring")
CVSS
```

## Output

Professional reports in Markdown and PDF format, suitable for client delivery.
