---
name: social-engineer
description: Social engineering simulation and phishing awareness testing
---

# Social Engineering Operations

Phishing simulation, pretexting, and social engineering awareness testing for authorized engagements.

## Capabilities

- Email phishing campaign simulation
- Credential harvesting page creation
- Pretext scenario development
- Social engineering report generation

## Phishing Page Generator

```bash
# Create a simple credential harvesting page
cat << 'PHISH' > /data/engagements/phish_page.html
<!DOCTYPE html>
<html>
<head><title>Login</title></head>
<body>
<form method="POST" action="/capture">
  <input type="text" name="username" placeholder="Username">
  <input type="password" name="password" placeholder="Password">
  <button type="submit">Login</button>
</form>
</body>
</html>
PHISH
```

## Email Template Generation

Generate realistic phishing awareness emails based on target organization context. Always mark as TEST/SIMULATION.

## Pretext Scenarios

Build social engineering pretexts for:
- Helpdesk impersonation
- Vendor/supplier scenarios
- Internal IT communications
- Urgent action requests

## Reporting

Document social engineering findings:
- Click rates and credential submission rates
- User awareness gaps identified
- Training recommendations
- Policy improvements needed
