#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_ROOT/common.sh"
source "$SCRIPT_DIR/helper.sh"

require_homebrew

GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
BLUE=$'\033[34m'
CYAN=$'\033[36m'
MAGENTA=$'\033[35m'
RESET=$'\033[0m'

print_header() {
  printf '%b\n' "${BLUE}🍎 ${CYAN}$1${RESET}"
  printf '%b\n' "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

show_navigation_options() {
  local context="$1"
  echo ""
  case "$context" in
    "main")
      echo "Navigation: [s] Quick Scan | [l] List Installed Tools | [q] Quit"
      ;;
    "category")
      echo "Navigation: [s] Quick Scan | [l] List Installed Tools | [b] Back to Main Menu | [q] Quit"
      ;;
    "tool")
      echo "Navigation: [l] List Installed Tools | [b] Back to Category | [m] Main Menu | [q] Quit"
      ;;
    "action")
      echo "Navigation: [l] List Installed Tools | [r] Repeat Action | [b] Back to Tool Menu | [c] Back to Category | [m] Main Menu | [q] Quit"
      ;;
  esac
}

pause_with_options() {
  local context="$1"
  echo ""
  show_navigation_options "$context"
  read -r -p "Press Enter to continue or choose a navigation option: " nav_choice
  nav_choice=$(echo "$nav_choice" | tr -d '[:space:]')

  case "$nav_choice" in
    b|B) return 1 ;;
    c|C) return 2 ;;
    m|M) return 3 ;;
    q|Q) exit 0 ;;
    r|R) return 4 ;;
    l|L) return 5 ;;
    *) return 0 ;;
  esac
}

get_tool_version() {
  local tool="$1"

  if ! command_exists "$tool"; then
    echo "Not installed"
    return
  fi

  case "$tool" in
    python)
      python3 --version 2>/dev/null | awk '{print $2}'
      ;;
    az)
      az version 2>/dev/null | python3 - <<'PY' 2>/dev/null
import json,sys
try:
    data=json.load(sys.stdin)
    print(data.get("azure-cli", "Unknown"))
except Exception:
    pass
PY
      ;;
    *)
      brew list --versions "$tool" 2>/dev/null | awk '{print $2}'
      ;;
  esac
}

scan_installed_packages() {
  print_header "Quick Brew Scan"
  printf '%b\n' "${CYAN}Scanning current Homebrew formulae and casks...${RESET}"
  echo ""

  if ! command_exists brew; then
    echo -e "${RED}Homebrew is not available.${RESET}"
    return 1
  fi

  printf '%b\n' "${YELLOW}Formulae${RESET}"
  if brew list --formula --versions 2>/dev/null | sort; then
    :
  else
    echo "  (none)"
  fi

  echo ""
  printf '%b\n' "${YELLOW}Casks${RESET}"
  if brew list --cask --versions 2>/dev/null | sort; then
    :
  else
    echo "  (none)"
  fi

  echo ""
  printf '%b\n' "${YELLOW}Tip: use 'brew outdated' for a quick upgrade check.${RESET}"
  echo ""
  pause_with_options "action"
  local nav_result=$?
  case $nav_result in
    5) list_installed_tools; return $? ;;
    *) return $nav_result ;;
  esac
}

list_installed_tools() {
  print_header "Installed macOS Tools"

  declare -A tools_by_category
  tools_by_category["Core CLI"]="git gh jq yq fzf ripgrep eza bat wget"
  tools_by_category["Developer Tools"]="docker colima kubectl helm kind k9s"
  tools_by_category["Cloud & DevOps"]="python ansible terraform azure-cli"
  tools_by_category["Shell & Terminal"]="tmux zsh curl tree htop ncdu"
  tools_by_category["Productivity & Apps"]="iterm2 visual-studio-code rectangle obsidian"

  printf "%-25s %-20s %-15s\n" "CATEGORY" "TOOL" "VERSION"
  printf "%-25s %-20s %-15s\n" "========================" "===================" "=============="

  for category in "Core CLI" "Developer Tools" "Cloud & DevOps" "Shell & Terminal" "Productivity & Apps"; do
    local tools="${tools_by_category[$category]}"
    local category_printed=false

    for tool in $tools; do
      local version
      version=$(get_tool_version "$tool")
      if [[ "$version" != "Not installed" && -n "$version" ]]; then
        if [[ "$category_printed" == "false" ]]; then
          printf "%-25s %-20s %-15s\n" "$category" "$tool" "$version"
          category_printed=true
        else
          printf "%-25s %-20s %-15s\n" "" "$tool" "$version"
        fi
      fi
    done
  done

  echo ""
  printf '%b\n' "${YELLOW}Note: Only installed tools are shown above.${RESET}"

  pause_with_options "action"
  local nav_result=$?
  case $nav_result in
    5) list_installed_tools; return $? ;;
    *) return $nav_result ;;
  esac
}

install_package() {
  local package="$1"
  echo -e "${YELLOW}Attempting to install '$package'...${RESET}"

  if ! command_exists brew; then
    printf '%b\n' "${RED}Homebrew is not available. Please install it first.${RESET}"
    return 1
  fi

  if brew install "$package" >/dev/null 2>&1; then
    printf '%b\n' "${GREEN}'$package' installed successfully.${RESET}"
    return 0
  fi

  printf '%b\n' "${RED}Error installing '$package'.${RESET}"
  return 1
}

remove_package() {
  local package="$1"
  echo -e "${YELLOW}Attempting to remove '$package'...${RESET}"

  if brew uninstall "$package" >/dev/null 2>&1; then
    printf '%b\n' "${GREEN}'$package' removed.${RESET}"
    return 0
  fi

  printf '%b\n' "${RED}Error removing '$package'.${RESET}"
  return 1
}

update_package() {
  local package="$1"
  echo -e "${YELLOW}Attempting to update '$package'...${RESET}"

  if brew upgrade "$package" >/dev/null 2>&1; then
    printf '%b\n' "${GREEN}'$package' updated.${RESET}"
    return 0
  fi

  printf '%b\n' "${RED}Update skipped or failed for '$package'.${RESET}"
  return 1
}

manage_tool() {
  local tool="$1"

  while true; do
    echo ""
    print_header "Managing Tool: $tool"
    echo "What do you want to do with '$tool'?"
    echo "  i) Install"
    echo "  r) Remove"
    echo "  c) Check if Installed"
    echo "  v) Check Version"
    echo "  u) Update"
    echo ""
    show_navigation_options "tool"
    read -r -p "Enter your choice: " action_choice

    case "$action_choice" in
      i)
        install_package "$tool"
        ;;
      r)
        remove_package "$tool"
        ;;
      c)
        if command_exists "$tool"; then
          printf '%b\n' "${GREEN}$tool is installed.${RESET}"
        else
          printf '%b\n' "${RED}$tool is not installed.${RESET}"
        fi
        ;;
      v)
        printf '%b\n' "${CYAN}$tool version: $(get_tool_version "$tool")${RESET}"
        ;;
      u)
        update_package "$tool"
        ;;
      b|B) return 1 ;;
      m|M) return 3 ;;
      l|L)
        list_installed_tools
        local list_result=$?
        case $list_result in
          1|2|3) return $list_result ;;
          *) continue ;;
        esac
        ;;
      q|Q) exit 0 ;;
      *) echo "Invalid option." ;;
    esac

    pause_with_options "action"
    local nav_result=$?
    case $nav_result in
      1) continue ;;
      2) return 2 ;;
      3) return 3 ;;
      4) continue ;;
      5)
        list_installed_tools
        local list_result=$?
        case $list_result in
          1|2) return $list_result ;;
          3) return 3 ;;
          *) continue ;;
        esac
        ;;
      0) continue ;;
    esac
  done
}

show_category_menu() {
  local category_num="$1"
  local category_name="$2"

  while true; do
    print_header "$category_name"

    case "$category_num" in
      1)
        echo "  1) git"
        echo "  2) gh"
        echo "  3) jq"
        echo "  4) yq"
        echo "  5) fzf"
        echo "  6) ripgrep"
        echo "  7) eza"
        echo "  8) bat"
        echo "  9) wget"
        ;;
      2)
        echo "  1) docker"
        echo "  2) colima"
        echo "  3) kubectl"
        echo "  4) helm"
        echo "  5) kind"
        echo "  6) k9s"
        ;;
      3)
        echo "  1) python"
        echo "  2) ansible"
        echo "  3) terraform"
        echo "  4) azure-cli"
        ;;
      4)
        echo "  1) tmux"
        echo "  2) zsh"
        echo "  3) curl"
        echo "  4) tree"
        echo "  5) htop"
        echo "  6) ncdu"
        ;;
      5)
        echo "  1) iterm2"
        echo "  2) visual-studio-code"
        echo "  3) rectangle"
        echo "  4) obsidian"
        ;;
    esac

    echo ""
    show_navigation_options "category"
    read -r -p "Enter option: " tool_choice

    case "$tool_choice" in
      b|B) return 1 ;;
      l|L)
        list_installed_tools
        local list_result=$?
        case $list_result in
          1|2|3) return $list_result ;;
          *) continue ;;
        esac
        ;;
      s|S)
        scan_installed_packages
        ;;
      q|Q) exit 0 ;;
      *)
        local tool_result=0
        case "$category_num" in
          1)
            case "$tool_choice" in
              1) manage_tool "git"; tool_result=$? ;;
              2) manage_tool "gh"; tool_result=$? ;;
              3) manage_tool "jq"; tool_result=$? ;;
              4) manage_tool "yq"; tool_result=$? ;;
              5) manage_tool "fzf"; tool_result=$? ;;
              6) manage_tool "ripgrep"; tool_result=$? ;;
              7) manage_tool "eza"; tool_result=$? ;;
              8) manage_tool "bat"; tool_result=$? ;;
              9) manage_tool "wget"; tool_result=$? ;;
              *) echo "Invalid option."; continue ;;
            esac
            ;;
          2)
            case "$tool_choice" in
              1) manage_tool "docker"; tool_result=$? ;;
              2) manage_tool "colima"; tool_result=$? ;;
              3) manage_tool "kubectl"; tool_result=$? ;;
              4) manage_tool "helm"; tool_result=$? ;;
              5) manage_tool "kind"; tool_result=$? ;;
              6) manage_tool "k9s"; tool_result=$? ;;
              *) echo "Invalid option."; continue ;;
            esac
            ;;
          3)
            case "$tool_choice" in
              1) manage_tool "python"; tool_result=$? ;;
              2) manage_tool "ansible"; tool_result=$? ;;
              3) manage_tool "terraform"; tool_result=$? ;;
              4) manage_tool "azure-cli"; tool_result=$? ;;
              *) echo "Invalid option."; continue ;;
            esac
            ;;
          4)
            case "$tool_choice" in
              1) manage_tool "tmux"; tool_result=$? ;;
              2) manage_tool "zsh"; tool_result=$? ;;
              3) manage_tool "curl"; tool_result=$? ;;
              4) manage_tool "tree"; tool_result=$? ;;
              5) manage_tool "htop"; tool_result=$? ;;
              6) manage_tool "ncdu"; tool_result=$? ;;
              *) echo "Invalid option."; continue ;;
            esac
            ;;
          5)
            case "$tool_choice" in
              1) manage_tool "iterm2"; tool_result=$? ;;
              2) manage_tool "visual-studio-code"; tool_result=$? ;;
              3) manage_tool "rectangle"; tool_result=$? ;;
              4) manage_tool "obsidian"; tool_result=$? ;;
              *) echo "Invalid option."; continue ;;
            esac
            ;;
        esac

        case $tool_result in
          1) continue ;;
          2) continue ;;
          3) return 3 ;;
          0) continue ;;
        esac
        ;;
    esac
  done
}

while true; do
  print_header "Manage Optional macOS Tools"
  echo "Choose a category:"
  echo "  1) Core CLI"
  echo "  2) Developer Tools"
  echo "  3) Cloud & DevOps"
  echo "  4) Shell & Terminal"
  echo "  5) Productivity & Apps"
  echo ""
  show_navigation_options "main"
  read -r -p "Enter your choice: " category_choice

  case "$category_choice" in
    1) show_category_menu 1 "Core CLI" ;;
    2) show_category_menu 2 "Developer Tools" ;;
    3) show_category_menu 3 "Cloud & DevOps" ;;
    4) show_category_menu 4 "Shell & Terminal" ;;
    5) show_category_menu 5 "Productivity & Apps" ;;
    l|L)
      list_installed_tools
      ;;
    s|S)
      scan_installed_packages
      ;;
    q|Q)
      echo "Exiting tool management."
      break
      ;;
    *)
      if [[ -n "$category_choice" ]]; then
        echo "Invalid choice."
      fi
      ;;
  esac
done

printf '%b\n' "${GREEN}Exiting tool management.${RESET}"