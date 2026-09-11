# Playbook: API Security Testing

## Phase 1: API Discovery

### Discovery Workers

#### Endpoint Enumeration Worker
```
Objective: Discover all API endpoints for [target]
Steps:
1. Check /openapi.json, /swagger.json, /api-docs, /graphql
2. Crawl web app, extract API calls from JS/network traffic
3. Check mobile app traffic (if applicable)
4. Wayback machine for historical API endpoints
5. Brute force common paths (/api/v1/, /api/v2/, /graphql, /rest/)
6. Check GitHub/docs for API documentation
Output: Complete endpoint list with methods, params, auth requirements
```

#### GraphQL Introspection Worker
```
Objective: Map GraphQL schema for [target]
Steps:
1. Test introspection query: { __schema { types { name fields { name } } } }
2. If blocked, try:
   - __type queries individually
   - Field suggestion exploitation
   - Introspection with different content types
3. Map all queries, mutations, subscriptions
4. Identify interesting types (User, Admin, Payment, etc.)
5. Check for deprecated fields/queries
Output: Full schema with annotated interesting endpoints
```

## Phase 2: Authentication & Authorization

### Auth Testing Matrix

| Test | Method | Impact |
|------|--------|--------|
| No auth on sensitive endpoints | Remove auth header | CRITICAL |
| Broken function-level auth | Access admin APIs as user | CRITICAL |
| BOLA/IDOR | Change object IDs | HIGH-CRITICAL |
| JWT none algorithm | Set alg to "none" | CRITICAL |
| JWT weak secret | Brute force HMAC secret | CRITICAL |
| JWT key confusion | RS256→HS256 with public key | CRITICAL |
| API key in URL | Check logs, referer leakage | MEDIUM |
| OAuth redirect manipulation | Change redirect_uri | HIGH |
| Token leakage | Check responses, logs, errors | HIGH |
| Rate limiting bypass | Header rotation, IP cycling | MEDIUM |

### Auth Worker Template
```
Objective: Test authentication for [API group]
Context: Auth type is [JWT/OAuth/API key/session], roles are [roles]
Steps:
1. Test each endpoint WITHOUT auth → find unprotected
2. Test with lowest privilege → find over-permissive
3. Test horizontal access → user A accessing user B data
4. Test vertical access → user accessing admin data
5. Test token manipulation (if JWT)
6. Test session management (expiry, revocation)
Output: Auth bypass findings with evidence
```

## Phase 3: Input Testing

### Parameter-Level Testing

#### Mass Assignment Worker
```
Objective: Test mass assignment on [create/update endpoints]
Steps:
1. Find all endpoints accepting JSON bodies
2. Identify hidden/internal fields from:
   - API docs, error messages, responses
   - Adding common fields: role, admin, is_admin, verified, active
3. Test adding admin/privileged fields in requests
4. Test updating read-only fields
Output: Mass assignment vulnerabilities with payload + evidence
```

#### Injection Testing Worker
```
Objective: Test injection on [endpoint group]
Steps:
1. SQL injection: ' OR 1=1--, UNION SELECT, blind techniques
2. NoSQL injection: {"$gt":""}, {"$regex":".*"}
3. Command injection: ;id, |cat /etc/passwd, $(whoami)
4. SSRF: internal URLs, cloud metadata (169.254.169.254)
5. Path traversal: ../../etc/passwd in file parameters
6. XXE: in XML-accepting endpoints
Output: Confirmed injections with payload + evidence
```

### Rate Limiting & Business Logic

#### Rate Limit Worker
```
Objective: Test rate limiting on [critical endpoints]
Steps:
1. Identify critical endpoints: login, register, reset, OTP, API calls
2. Send rapid parallel requests (10, 50, 100, 1000)
3. Check per-endpoint, per-user, per-IP limits
4. Test bypass: X-Forwarded-For, X-Real-IP headers
5. Test with distributed IPs if applicable
Output: Rate limiting gaps with impact assessment
```

#### Race Condition Worker
```
Objective: Test race conditions on [one-time action endpoints]
Steps:
1. Identify one-time actions: coupon redeem, transfer, vote, claim
2. Send 20+ parallel requests simultaneously
3. Check if action executed multiple times
4. Test with slight timing variations
5. Check database state for duplicates
Output: Race condition findings with evidence of multiple execution
```

## Phase 4: Data Exposure

### Response Analysis
- Excessive data in responses (password hashes, internal IDs, PII)
- Verbose error messages (stack traces, SQL errors, file paths)
- Debug endpoints left in production
- API versioning leaking old vulnerable endpoints
- CORS misconfiguration allowing unauthorized origins

### Bulk Data Worker
```
Objective: Test for excessive data exposure on [endpoints]
Steps:
1. Compare response data with what's needed by the client
2. Check if filtering happens client-side vs server-side
3. Test pagination bypass (limit=999999, page=-1)
4. Test search/filter for data leakage
5. Check if PII is exposed in list endpoints
Output: Data exposure findings with comparison of needed vs returned data
```

## GraphQL-Specific Tests

| Test | How | Impact |
|------|-----|--------|
| Nested query DoS | Deep nesting: { user { posts { comments { user { posts ... } } } } } | HIGH |
| Batch query abuse | [query1, query2, ...query100] in single request | MEDIUM |
| Field duplication | Alias same field 1000x: { a1:user a2:user ... } | MEDIUM |
| Query cost bypass | Fragment spreading, aliases, directive abuse | MEDIUM |
| Mutation without auth | Test all mutations with no/low auth | CRITICAL |
| Subscription leaks | Subscribe to events you shouldn't see | HIGH |

## REST-Specific Tests

| Test | How | Impact |
|------|-----|--------|
| HTTP method tampering | Try PUT/PATCH/DELETE on GET-only endpoints | HIGH |
| Content-type confusion | Send JSON as form-data and vice versa | MEDIUM |
| API version rollback | Use /v1/ instead of /v2/ for patched bugs | HIGH |
| Verb tunneling | X-HTTP-Method-Override header | MEDIUM |
| Parameter pollution | Same param multiple times with different values | MEDIUM |
