#!/usr/bin/env bash

detect_os() {
    case "$(uname -s)" in
        Linux*)
            OS="linux"
            ;;
        Darwin*)
            OS="macos"
            ;;
        *)
            echo "Unsupported operating system"
            exit 1
            ;;
    esac
}

require_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew not found."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew installation failed or is not available on PATH." >&2
        exit 1
    fi
}