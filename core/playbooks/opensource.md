# Playbook: Open Source Code Review

## GOLDEN RULE: Understand EVERYTHING Before Attacking

**DO NOT start hunting until you have read and understood the ENTIRE codebase.**
- Read ALL source files. No skimming. No "probably not important".
- Understand the COMPLETE architecture: how data flows, how auth works, how requests are processed.
- Map EVERY entry point, EVERY sink, EVERY trust boundary.
- Only THEN create a targeted attack plan based on real understanding.

Blind pattern matching finds surface bugs. Deep comprehension finds the real vulnerabilities.

## Phase 0: FULL COMPREHENSION (MANDATORY — Cannot Be Skipped)

### Step 0.1: Build Knowledge Graph
```
1. Clone target repo to a working directory
2. build_or_update_graph_tool(repo_root="path/to/repo", full_rebuild=true)
3. get_architecture_overview_tool() → understand ALL components
4. list_communities_tool() → understand code clusters
5. get_hub_nodes_tool(top_n=20) → find critical code (most connected)
6. get_bridge_nodes_tool(top_n=20) → find architectural chokepoints
7. list_flows_tool() → understand ALL execution paths
```

### Step 0.2: Read ALL Code (via parallel workers)

Spawn workers to read and document EVERY module. Each worker:
- Reads every file in their assigned module/directory
- Documents: purpose, inputs, outputs, dependencies, security-relevant behavior
- Identifies: entry points, sinks, trust boundaries, auth checks
- Flags: anything unusual, unexpected, or inconsistent
- Notes: potential chain components

**Worker assignment strategy:**
```
Worker 1: Core/framework code (routing, middleware, request handling)
Worker 2: Authentication & authorization (login, sessions, permissions, JWT)
Worker 3: Data access layer (database queries, ORM, file I/O)
Worker 4: Business logic (domain-specific features, payment, user management)
Worker 5: API layer (endpoints, input parsing, response formatting)
Worker 6: Infrastructure (config, deployment, dependencies, CI/CD)
```

Scale worker count to codebase size. Small repo (<50 files): 2-3 workers. Large repo (>500 files): 6-10 workers.

### Step 0.3: Build Mental Model

After workers report back, the orchestrator MUST synthesize:

1. **Architecture document** → write to `target/recon/001-architecture.md`
   - Component diagram (text-based)
   - Data flow: request → processing → response
   - Trust boundaries: where user input crosses into privileged ops
   - Authentication/authorization model

2. **Entry point map** → write to `target/recon/002-entry-points.md`
   - EVERY HTTP handler/route with method, path, auth requirement
   - CLI commands and arguments
   - File processing entry points
   - Scheduled tasks / background jobs
   - WebSocket handlers
   - Event listeners / message consumers

3. **Sink map** → write to `target/recon/003-sinks.md`
   - EVERY dangerous function call with file:line
   - Categorized: SQL, command, file, network, template, crypto, serialization
   - For each sink: what input reaches it? is it sanitized?

4. **Data flow document** → write to `target/recon/004-data-flow.md`
   - For EACH entry point: trace user input through the entire path to the response
   - Mark where validation/sanitization happens
   - Mark where user input reaches a sink
   - Identify paths where input reaches sinks WITHOUT validation

### Step 0.4: Verify Comprehension

Before proceeding to Phase 1, confirm:
- [ ] Can explain the app's purpose and architecture in detail
- [ ] Know ALL entry points (endpoints, CLI, file processors)
- [ ] Know ALL sinks (SQL, command, file, network, template)
- [ ] Know the auth model (how users authenticate, how permissions are checked)
- [ ] Know the data flow for the main features
- [ ] Know the trust boundaries
- [ ] Architecture, entry points, sinks, and data flow are documented in target/recon/

**If ANY checkbox is unchecked → go back and fill the gap. Do NOT proceed.**

## Phase 1: Automated Scanning (Parallel)

Launch these workers in parallel:

### Worker A: Dependency Audit
```
Objective: Find ALL vulnerable dependencies
Steps:
1. Identify ALL package managers (npm, pip, cargo, go.mod, composer, etc.)
2. Run dependency audit for EACH package manager
3. Cross-reference with NVD/OSV/GitHub Advisory databases
4. Check for outdated packages with known vulns
5. Check for abandoned/unmaintained dependencies
6. Check for typosquatting risks in dependency names
7. Check postinstall scripts for suspicious behavior
Output: Complete dependency vulnerability report
```

### Worker B: Secret Scanning
```
Objective: Find ALL hardcoded secrets in source AND git history
Steps:
1. Grep for API keys, tokens, passwords, private keys, certificates
2. Check ALL config files: .env, .yaml, .json, .toml, .ini, .xml
3. Check CI/CD configs: .github/workflows, .gitlab-ci, Jenkinsfile
4. Check Dockerfiles and docker-compose files
5. Search ENTIRE git history for removed secrets: git log -p --all -S 'password'
6. Check for debug/test credentials that might work in production
7. Check for AWS/GCP/Azure credentials in any format
8. Check for SSH keys, SSL certs, JWT secrets
Output: Every secret found with file:line (or git commit)
```

### Worker C: Static Analysis
```
Objective: Run automated static analysis tools
Steps:
1. Install semgrep if not present
2. Run semgrep with security rulesets for the detected language(s)
3. Run language-specific linters with security rules
4. Parse and deduplicate results
5. Cross-reference with our entry point and sink maps
Output: Prioritized static analysis findings
```

## Phase 2: Targeted Pattern Hunting

Based on Phase 0 comprehension, create targeted search workers for EACH pattern category.

### Pattern Categories by Language

#### Memory Safety (C/C++/Rust-unsafe)
| Pattern | What to grep | What to trace | Severity |
|---------|-------------|---------------|----------|
| Buffer overflow | `strcpy`, `sprintf`, `gets`, `memcpy`, `strncpy` (wrong size) | User input → buffer without bounds check | CRITICAL |
| Use-after-free | `free()` then continued pointer use | Allocation lifecycle, especially error paths | CRITICAL |
| Integer overflow | Arithmetic on sizes, lengths, counts from user input | User-controlled integers used for allocation/indexing | HIGH |
| Format string | `printf(var)`, `fprintf(fd, var)`, `syslog(var)` | User input reaching format parameter | CRITICAL |
| Double free | Multiple `free()` paths (error handling, cleanup) | All paths that free the same pointer | CRITICAL |
| Null deref | Missing null checks after malloc/calloc/realloc | Return values of allocation functions | MEDIUM |
| Off-by-one | Loop bounds, string termination, array indexing | Boundary conditions in loops and array access | HIGH |
| Type confusion | Void pointer casts, union usage, C++ RTTI bypass | Type casting without proper validation | HIGH |

#### Injection (Web/Script languages)
| Pattern | What to grep | What to trace | Severity |
|---------|-------------|---------------|----------|
| SQL injection | String concat/interpolation in queries, raw SQL, ORM bypass | User input → query construction | CRITICAL |
| Command injection | exec, system, popen, subprocess, child_process, spawn | User input → command string | CRITICAL |
| Path traversal | File operations with user-controlled paths, ../ | User input → file path construction | HIGH |
| SSTI | Template render with user-controlled template string | User input → template engine | CRITICAL |
| XSS | innerHTML, v-html, dangerouslySetInnerHTML, unescaped output | User input → HTML output | HIGH |
| Deserialization | pickle.loads, unserialize, readObject, YAML.load, JSON.parse (then eval) | User data → deserialization function | CRITICAL |
| LDAP injection | LDAP queries with user input | User input → LDAP filter construction | HIGH |
| XXE | XML parsing without disabling external entities | User XML → parser without security config | HIGH |
| NoSQL injection | MongoDB queries with user-controlled operators ($gt, $regex) | User input → NoSQL query object | HIGH |
| SSRF | HTTP requests with user-controlled URLs | User input → URL for server-side request | HIGH |
| Header injection | User input in HTTP response headers | User input → header values (especially Location, Set-Cookie) | MEDIUM |
| Log injection | User input in log messages | User input → log output without sanitization | MEDIUM |

#### Authentication/Authorization
| Pattern | What to grep | What to trace | Severity |
|---------|-------------|---------------|----------|
| Missing auth check | Route/handler without auth middleware | Request → handler without auth gate | CRITICAL |
| Broken access control | Auth check with logic errors, OR instead of AND | Permission checking logic | CRITICAL |
| Hardcoded credentials | password=, secret=, token=, api_key= | String literals that look like secrets | CRITICAL |
| Weak crypto | MD5/SHA1 for passwords, ECB mode, short keys, Math.random for security | Crypto function usage | HIGH |
| JWT issues | alg:none, HS256 with public key, missing expiry check, missing audience check | JWT verification logic | CRITICAL |
| Session fixation | No session ID regeneration after login | Session management code | HIGH |
| Timing attacks | != or == for secret comparison instead of constant-time compare | Secret comparison code | MEDIUM |
| Insecure password storage | Plaintext, reversible encryption, unsalted hashes | Password storage/verification code | CRITICAL |

#### Logic & Design
| Pattern | What to grep | What to trace | Severity |
|---------|-------------|---------------|----------|
| Race condition | Check-then-act without lock, TOCTOU file operations | Shared state modification, file access patterns | HIGH |
| Mass assignment | Object spread/merge with user input into models | User input → model/entity creation | HIGH |
| Insecure defaults | Debug=true, verbose errors, permissive CORS | Default configuration values | MEDIUM |
| Missing rate limiting | Auth endpoints without rate limit | Login, registration, password reset handlers | MEDIUM |
| Information disclosure | Stack traces, detailed errors, version headers | Error handling code, response headers | MEDIUM |
| Privilege escalation | Role/permission stored client-side, modifiable in request | User role handling, especially during updates | HIGH |
| Business logic bypass | Workflow steps that can be skipped, price tampering | Multi-step processes, payment flows | HIGH |

### Pattern Search Worker Template
```
Objective: Find [pattern category] vulnerabilities in ENTIRE codebase
Context: Language is [lang], framework is [framework]
Reference: Entry point map at target/recon/002-entry-points.md
           Sink map at target/recon/003-sinks.md
           Data flow at target/recon/004-data-flow.md

Approach (for EACH pattern in the category):
1. Use semantic_search_nodes_tool to find relevant functions
2. Grep for specific dangerous patterns across ALL files
3. For EACH hit:
   a. Is this reachable from user input? Trace back using query_graph(callers_of)
   b. Is there validation/sanitization in the path? Check EVERY function in the chain
   c. Can the sanitization be bypassed? (encoding, double encoding, type juggling, etc.)
   d. What's the impact if exploited?
   e. Could this be part of a chain? What does it enable?
4. Mark each hit as: CONFIRMED | NEEDS_DEEPER_ANALYSIS | FALSE_POSITIVE
5. For FALSE_POSITIVE: document WHY it's false (what protection exists)

Output: ALL hits categorized, with data flow traces for confirmed ones
IMPORTANT: Report WHAT YOU DID NOT CHECK too — any files or patterns you couldn't analyze
```

## Phase 3: Taint Analysis (Deep)

For EACH entry point identified in Phase 0:

### Full Data Flow Trace
```
1. Start at entry point (HTTP handler, CLI arg, file read, etc.)
2. Use query_graph(pattern="callees_of") to trace forward
3. For EACH function in the call chain:
   - Does it validate/sanitize the input? How?
   - Does it pass to a dangerous sink?
   - Does it transform the data? (could transformation bypass validation?)
   - Are there error paths that skip validation?
   - Are there conditional paths that skip validation?
4. Document the COMPLETE taint chain from source to sink
5. For each chain that reaches a sink without adequate protection:
   → Create a LEAD with test plan
```

### Bypass Analysis
For each "protected" sink (has validation):
- Can the validation be bypassed with encoding? (URL, HTML, unicode, double encoding)
- Can it be bypassed with type juggling? (PHP: "0" == 0)
- Can it be bypassed with truncation? (length limits, null bytes)
- Can it be bypassed with second-order injection? (stored then used later)
- Can it be bypassed with race conditions? (validate, then use different value)
- Can it be bypassed with parameter pollution? (multiple values for same param)
- Is the validation applied consistently? (all paths, not just the main one)

## Phase 4: Deep Analysis by Language

### JavaScript/TypeScript
- Prototype pollution: Object.assign, lodash.merge, deep-merge, spread with user input
- ReDoS: Complex regex on user input (especially .*, .+, nested groups)
- eval/Function: Any dynamic code execution with user influence
- postMessage: Missing origin checks in message handlers
- DOM clobbering: Document properties overridden by HTML elements
- npm supply chain: Check ALL dependencies for typosquatting, suspicious postinstall

### Python
- Pickle/marshal deserialization on ANY user-controlled data
- SSTI: Jinja2/Mako/Django templates with user-controlled template strings
- os.system/subprocess with user input (even partial)
- yaml.load with Loader=Loader (unsafe) instead of SafeLoader
- __import__/__builtins__ access from user input (sandbox escape)
- format string: f-strings or .format() with user-controlled format strings
- ast.literal_eval is safe; eval() is not — check which one is used

### Go
- goroutine leaks: goroutines that never exit (missing context cancellation)
- unsafe package: pointer arithmetic, type casting bypassing safety
- Error handling: errors ignored with `_` that should be checked
- Race conditions: shared state without mutex (run with -race flag)
- Template injection: text/template vs html/template (the former doesn't escape)
- Integer overflow: converting between int types without bounds check

### Java/Kotlin
- Deserialization: ObjectInputStream.readObject on untrusted data
- JNDI injection: lookup with user-controlled string (log4j pattern)
- XXE: DocumentBuilderFactory/SAXParser without security features enabled
- SpEL injection: Spring Expression Language with user input
- Path traversal: File/Path construction with user input
- Reflection: Class.forName or Method.invoke with user input

### Rust
- unsafe blocks: ALL unsafe code is high-priority review target
- FFI boundaries: Data crossing between Rust and C/C++
- Integer overflow: Arithmetic in release mode (wraps silently, unlike debug)
- Unsafe unwrap: .unwrap() on user-influenced Result/Option (panic = DoS)
- Memory leaks: mem::forget, circular Rc references
- Soundness holes: lifetime elision issues, variance problems

### C/C++
- ALL of memory safety patterns from Phase 2
- Use-after-return: Stack variables referenced after function return
- Uninitialized memory: Variables used before assignment
- Signed integer overflow: Undefined behavior exploitable by compiler
- Variadic functions: Format string and type mismatch issues
- Macro hygiene: Macros that evaluate arguments multiple times

## Phase 5: Exploitation & Chain Building

### For EACH confirmed vulnerability:
1. **Can I exploit it alone?** → Build minimal PoC
2. **Can I chain it?** → Check against primitives/CHAINS.md
3. **Can I escalate the impact?** → Info leak → targeted attack → deeper access
4. **What's the realistic worst case?** → Honest impact assessment

### Chain Assembly
When multiple primitives exist:
1. Map all primitives on a kill chain diagram
2. Test each combination systematically
3. Document successful chains with full repro steps
4. Each chain gets its own finding file with combined severity

### CVE Hunting Specific
1. Compare with ALL past CVEs in the same project (`gh api /repos/{owner}/{repo}/security-advisories`)
2. Check if past patches are COMPLETE (look for variants, edge cases)
3. Look at issue tracker for security discussions, especially closed ones
4. Check forks for independently patched vulns that might indicate undisclosed issues
5. Check for pattern: same bug type in different parts of the code

## Graph Tool Quick Reference

| Need | Tool | Use When |
|------|------|----------|
| Find functions by name | `semantic_search_nodes_tool(query="handleAuth")` | Looking for specific functionality |
| Who calls this | `query_graph_tool(pattern="callers_of", target="validateToken")` | Tracing what reaches a function |
| What this calls | `query_graph_tool(pattern="callees_of", target="processInput")` | Tracing what a function uses |
| Tests exist? | `query_graph_tool(pattern="tests_for", target="parseConfig")` | Checking test coverage |
| File overview | `query_graph_tool(pattern="file_summary", target="auth.py")` | Quick file understanding |
| What it imports | `query_graph_tool(pattern="imports_of", target="server.js")` | Understanding dependencies |
| Blast radius | `get_impact_radius_tool(changed_files=["auth.py"])` | Impact of a change |
| Dead code | `refactor_tool(mode="dead_code")` | Finding unused (potentially interesting) code |
| Large functions | `find_large_functions_tool(min_lines=100)` | Complex code = more bugs |
| Architectural gaps | `get_knowledge_gaps_tool()` | Untested hotspots |
| Surprising connections | `get_surprising_connections_tool()` | Unexpected coupling = potential bugs |

## Coverage Tracking for Code Review

```
| Module/File | Read? | Entry Points? | Sinks? | Taint Traced? | Status |
|-------------|-------|---------------|--------|---------------|--------|
| auth/login.py | YES | 3 found | 2 SQL | All traced | DONE |
| api/users.py | YES | 5 found | 1 cmd | 3/5 traced | PARTIAL |
| utils/crypto.py | NO | - | - | - | NOT STARTED |
```

**Goal: Every row should be DONE before reporting.**
