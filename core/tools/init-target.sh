#!/usr/bin/env bash
# Initialize a new target workspace
# Usage: bash core/tools/init-target.sh [target-name]
# Creates a fresh target/ directory from templates

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATES="$PROJECT_DIR/core/templates/target-init"
TARGET_DIR="$PROJECT_DIR/target"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET_NAME="${1:-}"

# Check if target/ already has data
if [[ -f "$TARGET_DIR/config.md" ]]; then
    echo -e "${YELLOW}Warning: target/ already has files.${NC}"
    read -p "Archive existing target and start fresh? [y/N] " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi

    # Archive existing target
    ARCHIVE_NAME=$(grep -m1 "Name" "$TARGET_DIR/config.md" | sed 's/.*: *//' | tr ' ' '-' | tr -cd '[:alnum:]-')
    [[ -z "$ARCHIVE_NAME" || "$ARCHIVE_NAME" == "_TBD_" ]] && ARCHIVE_NAME="unnamed"
    ARCHIVE_DATE=$(date +%Y-%m-%d)
    ARCHIVE_DIR="$PROJECT_DIR/archive/${ARCHIVE_DATE}-${ARCHIVE_NAME}"

    mkdir -p "$ARCHIVE_DIR"
    cp -r "$TARGET_DIR"/* "$ARCHIVE_DIR"/ 2>/dev/null || true
    echo -e "${GREEN}Archived existing target to: archive/${ARCHIVE_DATE}-${ARCHIVE_NAME}${NC}"

    # Clean target directory (keep subdirs)
    rm -f "$TARGET_DIR"/*.md
    rm -f "$TARGET_DIR"/recon/* "$TARGET_DIR"/leads/* "$TARGET_DIR"/primitives/*
    rm -f "$TARGET_DIR"/findings/* "$TARGET_DIR"/reports/* "$TARGET_DIR"/sessions/*
    rm -f "$TARGET_DIR"/workers/queue/* "$TARGET_DIR"/workers/running/* "$TARGET_DIR"/workers/done/*
fi

# Copy templates
cp "$TEMPLATES"/*.md "$TARGET_DIR"/
# Copy CHAINS.md to leads/
cp "$TEMPLATES"/CHAINS.md "$TARGET_DIR"/leads/ 2>/dev/null || true

# Set date
TODAY=$(date +%Y-%m-%d)
sed -i "s/YYYY-MM-DD/$TODAY/g" "$TARGET_DIR"/*.md

# Set target name if provided
if [[ -n "$TARGET_NAME" ]]; then
    sed -i "s/_TBD_/$TARGET_NAME/" "$TARGET_DIR/config.md"
    echo -e "${GREEN}Target initialized: $TARGET_NAME${NC}"
else
    echo -e "${GREEN}Target initialized. Edit target/config.md to configure.${NC}"
fi

echo ""
echo "Next steps:"
echo "  1. Edit target/config.md — set target type and details"
echo "  2. Edit target/SCOPE.md — define what's in/out of scope"
echo "  3. Run: bash core/tools/check-and-install.sh --playbook {type}"
echo "  4. Start hunting!"
