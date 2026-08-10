#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ./labs/destroy.sh [kubernetes|ansible-aap|rhel-lab]

Removes the local Docker images created for the selected lab environment.
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

remove_lab() {
  local name="$1"
  local image="simple-shell:$name"

  if docker image inspect "$image" >/dev/null 2>&1; then
    echo "Removing $image"
    docker image rm "$image" >/dev/null
  else
    echo "$image not found"
  fi
}

if [[ "$lab" == "all" ]]; then
  for name in kubernetes ansible-aap rhel-lab; do
    remove_lab "$name"
  done
else
  remove_lab "$lab"
fi

echo "Lab container cleanup complete."
