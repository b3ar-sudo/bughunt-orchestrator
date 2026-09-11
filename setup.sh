#!/usr/bin/env bash
# BugHunt Orchestrator v2 — Bootstrap
# Usage:
#   Method 1 (clone):  git clone <repo-url> my-hunt && cd my-hunt && bash setup.sh
#   Method 2 (fresh):  curl -sL <raw-url>/setup.sh | bash -s -- my-hunt
#   Method 3 (local):  bash setup.sh [directory-name]
#
# Creates a ready-to-use hunting workspace with full orchestrator architecture.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

TARGET_DIR="${1:-.}"

# If target dir specified and doesn't exist, create it
if [[ "$TARGET_DIR" != "." ]]; then
    mkdir -p "$TARGET_DIR"
    cd "$TARGET_DIR"
fi

echo -e "${BOLD}${BLUE}"
echo "╔══════════════════════════════════════════╗"
echo "║   BugHunt Orchestrator v2 — Bootstrap    ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# Check if this is already a clone (has core/ directory)
if [[ -d "core/playbooks" ]]; then
    echo -e "${GREEN}Detected existing installation. Resetting target workspace...${NC}"
    bash core/tools/init-target.sh
    exit 0
fi

echo -e "${BLUE}[1/4]${NC} Creating directory structure..."

mkdir -p \
    core/playbooks \
    core/prompts \
    core/templates/target-init \
    core/tools \
    target/{recon,leads,primitives,findings,reports,sessions} \
    target/workers/{queue,running,done} \
    archive

echo -e "${BLUE}[2/4]${NC} Downloading core files..."

# If we're in a git clone, files already exist
# If running standalone, we need to note that files should be copied
if [[ ! -f "CLAUDE.md" ]]; then
    echo -e "${YELLOW}This script works best when run inside a git clone.${NC}"
    echo -e "${YELLOW}Clone the repo first:${NC}"
    echo ""
    echo "  git clone <repo-url> my-hunt"
    echo "  cd my-hunt"
    echo "  bash setup.sh"
    echo ""
    echo -e "${YELLOW}Or copy the template directory:${NC}"
    echo ""
    echo "  cp -r /path/to/bughunt-orchestrator /path/to/new-hunt"
    echo "  cd /path/to/new-hunt"
    echo "  bash setup.sh"
    exit 1
fi

echo -e "${BLUE}[3/4]${NC} Initializing target workspace..."

# Copy templates to target/
cp core/templates/target-init/*.md target/
cp core/templates/target-init/CHAINS.md target/leads/ 2>/dev/null || true

# Set today's date (compatible with macOS and Linux)
TODAY=$(date +%Y-%m-%d)
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/YYYY-MM-DD/$TODAY/g" target/*.md 2>/dev/null || true
else
    sed -i "s/YYYY-MM-DD/$TODAY/g" target/*.md 2>/dev/null || true
fi

# Add .gitkeep to preserve empty dirs
for dir in target/recon target/leads target/primitives target/findings \
           target/reports target/sessions target/evidence target/workers/queue \
           target/workers/running target/workers/done archive; do
    touch "$dir/.gitkeep"
done

echo -e "${BLUE}[4/4]${NC} Setting permissions..."

chmod +x core/tools/*.sh

echo ""
echo -e "${GREEN}${BOLD}Setup complete!${NC}"
echo ""
echo -e "${BOLD}Project structure:${NC}"
echo "  CLAUDE.md              ← Orchestrator brain (read by Claude Code)"
echo "  core/playbooks/        ← Hunting methodology per target type"
echo "  core/prompts/          ← Worker agent prompt templates"
echo "  core/tools/            ← Auto-installer & helpers"
echo "  core/templates/        ← Templates for new targets"
echo "  target/                ← Active hunting workspace"
echo "  archive/               ← Completed targets"
echo ""
echo -e "${BOLD}Quick start:${NC}"
echo "  1. Edit ${YELLOW}target/config.md${NC}  — set target name & type"
echo "  2. Edit ${YELLOW}target/SCOPE.md${NC}   — define scope"
echo "  3. Run:  ${YELLOW}bash core/tools/check-and-install.sh --playbook web-app${NC}"
echo "  4. Open Claude Code in this directory — the orchestrator takes over"
echo ""
echo -e "${BOLD}Available playbooks:${NC} web-app, api, binary, mobile, opensource, cloud"
echo ""
echo -e "${BOLD}New target:${NC}  bash core/tools/init-target.sh [name]"
echo -e "${BOLD}Check tools:${NC} bash core/tools/check-and-install.sh --playbook [type]"
