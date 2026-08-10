#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_ROOT/common.sh"
source "$SCRIPT_DIR/helper.sh"

require_homebrew

brew update

echo "Installing macOS packages..."
install_packages_from_file "$REPO_ROOT/macos/packages.txt"

echo "Starting Colima..."

if command -v colima >/dev/null 2>&1; then
    colima start
else
    echo "Colima is not available after package install; skipping start." >&2
fi