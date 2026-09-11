# Playbook: Web Application

## Phase 1: Reconnaissance

### Passive Recon Workers
1. **Subdomain enumeration**: subfinder, amass passive, crt.sh
2. **Technology fingerprint**: Wappalyzer, WhatWeb, builtwith
3. **JavaScript analysis**: Extract endpoints, API keys, secrets from JS
4. **Wayback mining**: waybackurls, gau for historical endpoints
5. **Google dorking**: site:target.com filetype:pdf/sql/env/log
6. **GitHub dorking**: org:target leaked secrets, configs, internal docs

### Active Recon Workers
1. **Directory bruteforce**: feroxbuster/dirsearch on discovered hosts
2. **Port scan**: nmap top 1000 on main assets
3. **API discovery**: Crawl + extract API endpoints
4. **Parameter discovery**: Arjun/param-miner on key endpoints
5. **Virtual host discovery**: Check for hidden vhosts

### Recon Output → KNOWLEDGE.md
- Full tech stack
- All discovered endpoints with auth requirements
- Cookie/header analysis
- Session management type (JWT/session/API key)

## Phase 2: Attack Surface Mapping

### Authentication Surface
| Vector | Check | Severity |
|--------|-------|----------|
| Login bypass | Default creds, SQL injection, auth logic | CRITICAL |
| Password reset | Token prediction, race condition, host header | HIGH |
| Session management | Fixation, JWT issues, cookie flags | HIGH |
| OAuth/OIDC | State param, redirect_uri validation | HIGH |
| MFA bypass | Backup codes, race condition, response manipulation | CRITICAL |
| Registration | Duplicate accounts, email verification bypass | MEDIUM |

### Authorization Surface (IDOR/BOLA)
| Vector | Check | Severity |
|--------|-------|----------|
| Direct object reference | Change IDs in API calls | HIGH-CRITICAL |
| Path traversal | ../../../etc/passwd in file params | HIGH |
| Role escalation | Modify role in request/JWT | CRITICAL |
| Function-level access | Access admin endpoints as user | CRITICAL |
| Mass assignment | Add admin=true in registration | HIGH |

### Injection Surface
| Vector | Check | Severity |
|--------|-------|----------|
| SQL injection | All input params, headers, cookies | CRITICAL |
| XSS (reflected) | All reflected params | MEDIUM-HIGH |
| XSS (stored) | All user-controlled stored content | HIGH |
| SSTI | Template syntax in inputs ({{7*7}}) | CRITICAL |
| Command injection | Params that trigger system actions | CRITICAL |
| SSRF | URL params, webhook configs, image URLs | HIGH |
| XXE | XML upload/parsing endpoints | HIGH |

### Business Logic
| Vector | Check | Severity |
|--------|-------|----------|
| Price manipulation | Change price/quantity in requests | CRITICAL |
| Race conditions | Parallel requests for one-time actions | HIGH |
| Workflow bypass | Skip steps in multi-step processes | MEDIUM-HIGH |
| Rate limiting | Brute force, enumeration, DoS | MEDIUM |
| Feature abuse | Use features in unintended ways | VARIES |

## Phase 3: Testing Protocol

### Worker Task Templates

#### Auth Testing Worker
```
Objective: Test authentication mechanisms for [endpoint]
Context: [auth type, known endpoints, session format]
Steps:
1. Test default/weak credentials
2. Test login bypass techniques
3. Test password reset flow
4. Test session management
5. Test JWT (if applicable) - alg:none, key confusion, claim tampering
Output: List of findings with severity + repro steps
```

#### IDOR Testing Worker  
```
Objective: Test for IDOR on [endpoint group]
Context: [user roles, object types, API patterns]
Steps:
1. Create two test accounts (if possible)
2. Map all endpoints with object IDs
3. Try horizontal access (user A → user B objects)
4. Try vertical access (user → admin objects)
5. Try indirect references (encoded IDs, GUIDs)
Output: List of accessible cross-account objects
```

#### Injection Testing Worker
```
Objective: Test [injection type] on [parameter set]
Context: [endpoint, param names, WAF info]
Steps:
1. Test basic payloads
2. Test WAF bypass variants
3. Test blind techniques (time-based, OOB)
4. Confirm with harmless proof (no destructive testing)
Output: Confirmed injections with payload + evidence
```

## Phase 4: Exploitation & Validation

### Validation Checklist
- [ ] Bug reproduces reliably
- [ ] Impact is clearly demonstrated
- [ ] No destructive actions taken
- [ ] Screenshots/recordings captured
- [ ] Minimum viable payload used

### Chaining Strategy
Look for chains:
- SSRF + cloud metadata = credential leak
- XSS + CSRF = account takeover
- IDOR + info disclosure = mass data access
- Auth bypass + priv esc = full admin access

## Tools Reference

| Category | Tools |
|----------|-------|
| Recon | subfinder, amass, httpx, nuclei |
| Crawling | katana, gospider, hakrawler |
| Fuzzing | ffuf, feroxbuster, wfuzz |
| Proxy | Burp Suite, mitmproxy, Caido |
| Injection | sqlmap, dalfox, tplmap |
| Auth | jwt_tool, oauth-toolkit |
| API | postman, insomnia, graphql-voyager |
