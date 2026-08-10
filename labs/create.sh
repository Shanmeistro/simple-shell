#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: ./labs/create.sh [kubernetes|ansible-aap|rhel-lab]

Creates a Dev Container for the selected lab environment.
EOF
}

if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

lab="${1:-all}"

case "$lab" in
  kubernetes|ansible-aap|rhel-lab|all)
    ;;
  *)
    usage
    exit 1
    ;;
esac

create_lab() {
  local name="$1"
  local dir="$REPO_ROOT/devcontainers/$name"

  if [[ ! -d "$dir" ]]; then
    echo "No devcontainer directory found for $name" >&2
    return 1
  fi

  echo "Creating $name lab container..."
  docker build -t "simple-shell:$name" "$dir"
}

if [[ "$lab" == "all" ]]; then
  for name in kubernetes ansible-aap rhel-lab; do
    create_lab "$name"
  done
else
  create_lab "$lab"
fi

echo "Lab container creation complete."
