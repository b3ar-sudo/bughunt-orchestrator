# Pre-flight Readiness Check

**Date:** YYYY-MM-DD
**Target:** (not configured)

## 1. Account & Access

- [ ] Test account(s) created on target platform
- [ ] Email verification completed (if required)
- [ ] Phone verification completed (if required)
- [ ] Multiple accounts created for multi-role testing (user, admin, guest)
- [ ] API keys/tokens obtained (if target provides developer access)
- [ ] Test payment method configured (if testing payment flows)
- [ ] All user roles documented with access levels

**Accounts:**
| Role | Username/Email | Status |
|------|---------------|--------|
| User | | not created |
| Admin | | not created |
| Guest | | N/A |

## 2. Authorization & Legal

- [ ] Bug bounty program rules READ completely
- [ ] In-scope assets confirmed and documented in SCOPE.md
- [ ] Out-of-scope exclusions noted below
- [ ] Safe harbor clause verified
- [ ] Rate limiting / DoS restrictions noted
- [ ] Automated scanning policy checked
- [ ] Disclosure policy understood
- [ ] VPN/proxy requirements checked

**Program restrictions:**
- Automated scanning allowed: YES / NO / LIMITED
- Rate limit: ___
- Disclosure timeline: ___
- Special rules: ___

## 3. Tools & Environment

- [ ] All required tools installed (check-and-install.sh passed)
- [ ] Proxy/interceptor configured (Burp / mitmproxy / Caido)
- [ ] Browser profile isolated for testing
- [ ] Scope configured in proxy (only in-scope domains)
- [ ] Wordlists ready (SecLists, custom)
- [ ] DNS resolver configured

**Tool status:**
| Tool | Status | Notes |
|------|--------|-------|
| Proxy | | |
| Scanner | | |
| Fuzzer | | |

## 4. Target Understanding

- [ ] Target application explored manually as normal user
- [ ] All user-facing features identified and listed
- [ ] Authentication mechanism understood
- [ ] Technology stack fingerprinted
- [ ] API documentation found and reviewed
- [ ] Mobile app downloaded (if in scope)

**Tech stack:**
- Server: 
- Framework: 
- CDN: 
- WAF: 
- Auth: 

## 5. Workspace Ready

- [ ] STATE.md initialized
- [ ] STRATEGY.md has attack plan
- [ ] SCOPE.md matches program scope
- [ ] Session log created
- [ ] Evidence directory ready

---

## Status: BLOCKED

**Reason:** Waiting for target configuration

**Blockers:**
- (none yet)

**Next steps:**
1. Configure target (orchestrator handles this automatically)
2. Complete account setup
3. Verify all checklist items
4. Begin testing
