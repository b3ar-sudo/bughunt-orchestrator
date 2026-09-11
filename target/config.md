# Target Configuration

## Basic Info
- **Name**: _TBD_
- **Type**: web-app | api | binary | mobile | opensource | cloud
- **Platform**: HackerOne | Bugcrowd | Intigriti | VDP | private | CTF | research
- **URL/Location**: _TBD_
- **Priority**: HIGH | MEDIUM | LOW

## Playbook
- **Primary**: _auto-loaded from Type_
- **Secondary**: _optional second playbook (e.g., api for mobile backend)_

## Credentials
- **Test accounts**: _(stored securely, not in this file)_
- **API keys**: _(reference to env vars or vault)_
- **Proxy config**: _(Burp/mitmproxy port)_

## Rate Limits
- **Max requests/sec**: 10
- **Delay between workers**: 2s
- **Respect rate limit headers**: yes

## Worker Config
- **Max parallel workers**: 3
- **Worker model**: sonnet
- **Orchestrator model**: opus
- **Worker time budget**: 15 minutes per task

## Notes
_Any additional context about this target_
