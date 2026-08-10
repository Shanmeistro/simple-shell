#!/usr/bin/env bash
set -euo pipefail

install_brew_package() {
    local package="$1"

    if brew list "$package" >/dev/null 2>&1; then
        echo "✓ $package already installed"
    else
        echo "Installing $package..."
        brew install "$package"
    fi
}

install_packages_from_file() {
    local package_file="$1"

    if [[ ! -f "$package_file" ]]; then
        echo "Package list not found: $package_file" >&2
        return 1
    fi

    while IFS= read -r pkg
    do
        [[ -z "$pkg" ]] && continue
        install_brew_package "$pkg"
    done < "$package_file"
}