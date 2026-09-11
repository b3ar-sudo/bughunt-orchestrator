# Playbook: Cloud & Infrastructure

## Phase 1: Reconnaissance

### External Recon Worker
```
Objective: Map external attack surface for [target]
Steps:
1. DNS enumeration: subdomains, MX, TXT (SPF/DKIM), NS
2. Cloud provider detection: AWS/GCP/Azure/DO headers, IP ranges
3. S3/GCS/Azure blob enumeration
4. Certificate transparency logs
5. Shodan/Censys for exposed services
6. BGP/ASN mapping for IP ranges
7. GitHub/GitLab for leaked infrastructure configs
Output: External surface map with cloud providers and exposed services
```

## Phase 2: Cloud-Specific Testing

### AWS Targets
| Test | Check | Impact |
|------|-------|--------|
| S3 misconfiguration | Public buckets, listing enabled, write access | HIGH-CRITICAL |
| Lambda abuse | Event injection, env var leaks | HIGH |
| IAM enumeration | sts:GetCallerIdentity, role assumption | HIGH |
| Metadata SSRF | 169.254.169.254/latest/meta-data/ | CRITICAL |
| Cognito misconfig | Unauthenticated role, identity pool | HIGH |
| API Gateway bypass | Direct Lambda URL, stage variables | HIGH |
| CloudFront bypass | Origin header, direct S3 access | MEDIUM |
| SNS/SQS exposure | Public topics/queues | HIGH |

### GCP Targets
| Test | Check | Impact |
|------|-------|--------|
| Storage buckets | Public access, allUsers/allAuthenticatedUsers | HIGH-CRITICAL |
| Metadata SSRF | metadata.google.internal, recursive header | CRITICAL |
| Firebase misconfig | Public database, storage rules | CRITICAL |
| Cloud Functions | Event injection, env leaks | HIGH |
| IAM enumeration | Service account key leakage | HIGH |
| GKE exposed | Dashboard, kubelet API | CRITICAL |

### Azure Targets
| Test | Check | Impact |
|------|-------|--------|
| Blob storage | Public containers, SAS token leaks | HIGH-CRITICAL |
| IMDS SSRF | 169.254.169.254/metadata/ with header | CRITICAL |
| App Service misconfig | SCM site exposure, env vars | HIGH |
| Function Apps | Auth bypass, env leaks | HIGH |
| Key Vault access | Overly permissive policies | CRITICAL |
| Azure AD | Token abuse, tenant enumeration | HIGH |

## Phase 3: Container & Kubernetes

### Container Security Worker
```
Objective: Test container/K8s security for [target]
Steps:
1. Check for exposed Docker socket (/var/run/docker.sock)
2. Check for exposed Kubernetes API (6443, 8443)
3. Test kubelet API (10250, 10255)
4. Check for exposed dashboards (Kubernetes Dashboard, Grafana, etc.)
5. Test etcd access (2379)
6. Check for privileged containers
7. Test service account token abuse
8. Check network policies (pod-to-pod access)
Output: Container/K8s findings with severity
```

## Phase 4: Network Services

### Exposed Service Matrix

| Service | Port | Test | Impact |
|---------|------|------|--------|
| SSH | 22 | Weak passwords, key auth bypass | CRITICAL |
| FTP | 21 | Anonymous access, dir traversal | HIGH |
| RDP | 3389 | Brute force, BlueKeep | CRITICAL |
| SMB | 445 | Null session, EternalBlue | CRITICAL |
| Redis | 6379 | No auth, command exec | CRITICAL |
| MongoDB | 27017 | No auth, data dump | CRITICAL |
| Elasticsearch | 9200 | No auth, data exposure | CRITICAL |
| MySQL | 3306 | Weak credentials, UDF | HIGH |
| PostgreSQL | 5432 | Weak credentials, COPY FROM | HIGH |
| Jenkins | 8080 | Script console, no auth | CRITICAL |
| Docker API | 2375 | Container escape, host access | CRITICAL |
| Kubernetes | 6443/8443 | API access, pod exec | CRITICAL |

### Service Testing Worker
```
Objective: Test exposed [service] on [host:port]
Steps:
1. Version detection
2. Default/weak credential testing
3. Known CVE check for detected version
4. Configuration audit
5. Data access testing (if authenticated)
6. Privilege escalation testing
Output: Service security findings
```

## Phase 5: DNS & Email

### DNS Security Worker
```
Objective: Test DNS security for [domain]
Steps:
1. Zone transfer attempt (AXFR)
2. SPF record analysis — permissive senders?
3. DMARC policy — p=none? missing?
4. DKIM validation
5. Subdomain takeover — dangling CNAMEs to deprovisioned services
6. NS delegation issues
Output: DNS findings with evidence
```

## Tools Reference

| Category | Tools |
|----------|-------|
| Cloud enum | ScoutSuite, Prowler, CloudMapper |
| AWS | aws-cli, pacu, enumerate-iam |
| GCP | gcloud, gcpbucketbrute |
| Azure | az-cli, MicroBurst, ROADtools |
| K8s | kubectl, kube-hunter, kubeaudit |
| Network | nmap, masscan, Shodan CLI |
| DNS | dig, dnsrecon, subfinder, amass |
| Containers | trivy, grype, docker-bench |
