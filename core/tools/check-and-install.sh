#!/usr/bin/env bash
# Tool dependency checker and auto-installer
# Usage: bash check-and-install.sh tool1 tool2 tool3 ...
# Or:    bash check-and-install.sh --playbook web-app
# Or:    bash check-and-install.sh --check-only tool1 tool2

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="$SCRIPT_DIR/tool-registry.sh"
LOG_FILE="${SCRIPT_DIR}/install.log"
CHECK_ONLY=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[tools]${NC} $1"; }
ok()  { echo -e "${GREEN}[  OK ]${NC} $1"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $1"; }
err() { echo -e "${RED}[FAIL]${NC} $1"; }

# Source the registry
source "$REGISTRY"

# Parse arguments
TOOLS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --playbook)
            shift
            PLAYBOOK="$1"
            case "$PLAYBOOK" in
                web-app)  TOOLS+=(${TOOLS_WEB_APP[@]}) ;;
                api)      TOOLS+=(${TOOLS_API[@]}) ;;
                binary)   TOOLS+=(${TOOLS_BINARY[@]}) ;;
                mobile)   TOOLS+=(${TOOLS_MOBILE[@]}) ;;
                opensource) TOOLS+=(${TOOLS_OPENSOURCE[@]}) ;;
                cloud)    TOOLS+=(${TOOLS_CLOUD[@]}) ;;
                *)        err "Unknown playbook: $PLAYBOOK"; exit 1 ;;
            esac
            ;;
        --check-only)
            CHECK_ONLY=true
            ;;
        *)
            TOOLS+=("$1")
            ;;
    esac
    shift
done

if [[ ${#TOOLS[@]} -eq 0 ]]; then
    echo "Usage: $0 [--check-only] [--playbook <name>] [tool1 tool2 ...]"
    echo ""
    echo "Playbooks: web-app, api, binary, mobile, opensource, cloud"
    echo ""
    echo "Run with --check-only to see what's missing without installing."
    exit 0
fi

# De-duplicate
TOOLS=($(printf '%s\n' "${TOOLS[@]}" | sort -u))

MISSING=()
INSTALLED=()
FAILED=()

# Check each tool
for tool in "${TOOLS[@]}"; do
    if check_tool "$tool"; then
        ok "$tool"
        INSTALLED+=("$tool")
    else
        if $CHECK_ONLY; then
            warn "$tool — NOT INSTALLED"
            MISSING+=("$tool")
        else
            log "Installing $tool..."
            if install_tool "$tool" >> "$LOG_FILE" 2>&1; then
                ok "$tool — installed"
                INSTALLED+=("$tool")
            else
                err "$tool — installation failed (see $LOG_FILE)"
                FAILED+=("$tool")
            fi
        fi
    fi
done

# Summary
echo ""
echo "=== Summary ==="
echo -e "${GREEN}Installed: ${#INSTALLED[@]}${NC}"
[[ ${#MISSING[@]} -gt 0 ]] && echo -e "${YELLOW}Missing: ${#MISSING[@]} — ${MISSING[*]}${NC}"
[[ ${#FAILED[@]} -gt 0 ]]  && echo -e "${RED}Failed: ${#FAILED[@]} — ${FAILED[*]}${NC}"

# Exit code: 0 if all good, 1 if any missing/failed
[[ ${#MISSING[@]} -eq 0 && ${#FAILED[@]} -eq 0 ]]
