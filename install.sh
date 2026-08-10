#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

detect_os

echo "Detected OS: ${OS}"

case "$OS" in
    linux)
        (
            cd "$SCRIPT_DIR/linux"
            bash ./scripts/bootstrap.sh
        )
        ;;

    macos)
        bash "$SCRIPT_DIR/macos/scripts/bootstrap.sh"
        ;;

    *)
        echo "Unsupported operating system"
        exit 1
        ;;
esac