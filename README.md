# BugHunt Orchestrator v2

Autonomous bug hunting framework for [Claude Code](https://claude.ai/code). Opus model coordinates strategy while Sonnet workers execute tasks. File-based state management survives context compression for day-long hunting sessions.

## Quick Start

```bash
git clone https://github.com/b3ar-sudo/bughunt-orchestrator.git my-hunt
cd my-hunt
claude
# Tell it what to test: "test web app example.com, scope *.example.com"
```

The orchestrator auto-configures everything — target type, scope, tools, strategy — and starts hunting immediately.

## Architecture

```
CLAUDE.md                    ← Orchestrator brain (auto-loaded by Claude Code)
core/
├── playbooks/               ← Hunting methodology per target type
│   ├── web-app.md           ← OWASP, auth bypass, business logic
│   ├── api.md               ← REST/GraphQL, IDOR, mass assignment
│   ├── binary.md            ← Reverse engineering, memory corruption
│   ├── mobile.md            ← Android/iOS, API interception
│   ├── opensource.md         ← Full code review, taint analysis
│   └── cloud.md             ← AWS/GCP/Azure misconfig, IAM
├── prompts/                 ← Worker agent prompt templates
├── templates/               ← Templates for leads, findings, reports
└── tools/                   ← Auto-installer & target initializer
target/                      ← Active hunting workspace
├── STATE.md                 ← Single source of truth (survives compression)
├── STRATEGY.md              ← Hunting plan with reasoning
├── KNOWLEDGE.md             ← Accumulated intelligence
├── config.md                ← Target configuration
├── SCOPE.md                 ← What's in/out of scope
├── recon/                   ← Raw recon data
├── leads/                   ← Promising findings under investigation
│   └── CHAINS.md            ← Chain exploitation tracker
├── primitives/              ← Confirmed exploit primitives
├── findings/                ← Validated vulnerabilities
├── evidence/                ← Screenshots, recordings, PoCs
├── reports/                 ← Submission-ready reports
├── sessions/                ← Session logs
└── workers/                 ← Worker task queue
```

## How It Works

1. **You describe the target** — Claude auto-fills config, scope, installs tools
2. **Orchestrator (Opus)** reads playbook, creates strategy, spawns workers
3. **Workers (Sonnet)** execute focused tasks — recon, testing, code review
4. **Orchestrator reviews** worker results, updates state, decides next steps
5. **State files survive** context compression — no memory loss in long sessions

## Key Features

- **6 playbooks** for different target types with comprehensive methodologies
- **Chain exploitation tracking** — always looking for multi-step exploit chains
- **Coverage matrix** — obsessively tracks what has/hasn't been tested
- **Auto-install** — missing tools detected and installed automatically
- **Funnel system** — recon → leads → primitives → findings → reports
- **Honest by design** — never fabricates findings, distinguishes confirmed/inferred/speculated

## New Target (same workspace)

```bash
bash core/tools/init-target.sh "new-target"
```

Archives the previous target and creates a fresh workspace.

## Tool Management

```bash
# Install tools for a specific playbook
bash core/tools/check-and-install.sh --playbook web-app

# Combine multiple playbooks
bash core/tools/check-and-install.sh --playbook web-app,api

# Install everything
bash core/tools/check-and-install.sh --playbook all

# Check without installing
bash core/tools/check-and-install.sh --check-only --playbook web-app
```

## Requirements

- [Claude Code](https://claude.ai/code) with Opus model
- Linux or macOS
- Go, Python 3, pip3 (for tool installation)
