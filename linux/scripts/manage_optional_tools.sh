#!/bin/bash

# Script to manage optional development tools.

# Note: Removed 'set -e' to prevent shell switching issues
# We'll handle errors explicitly where needed

# Preserve the original shell
ORIGINAL_SHELL="$SHELL"
export SHELL="$ORIGINAL_SHELL"

# --- Colors for Readability ---
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

# --- Navigation State Variables ---
CURRENT_CATEGORY=""
LAST_CATEGORY_CHOICE=""
LAST_TOOL_CHOICE=""

# --- Helper Functions ---
print_header() {
  echo -e "\n${BLUE}==>${RESET} ${CYAN}$1${RESET}"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- Navigation Helper ---
show_navigation_options() {
  local context="$1"
  echo ""
  case "$context" in
    "main")
      echo "Navigation: [l] List Installed Tools | [q] Quit"
      ;;
    "category")
      echo "Navigation: [l] List Installed Tools | [b] Back to Main Menu | [q] Quit"
      ;;
    "tool")
      echo "Navigation: [l] List Installed Tools | [b] Back to Category | [m] Main Menu | [q] Quit"
      ;;
    "action")
      echo "Navigation: [l] List Installed Tools | [r] Repeat Action | [b] Back to Tool Menu | [c] Back to Category | [m] Main Menu | [q] Quit"
      ;;
  esac
}

# Add this function to pause and show options after actions
pause_with_options() {
  local context="$1"
  echo ""
  show_navigation_options "$context"
  read -r -p "Press Enter to continue or choose navigation option: " nav_choice
  
  # Trim whitespace
  nav_choice=$(echo "$nav_choice" | tr -d '[:space:]')
  
  case "$nav_choice" in
    b|B) return 1;;  # Back
    c|C) return 2;;  # Category (only for action context)
    m|M) return 3;;  # Main menu
    q|Q) exit 0;;    # Quit
    r|R) return 4;;  # Repeat (only for action context)
    l|L) return 5;;  # List installed tools
    *) return 0;;    # Continue normally
  esac
}

# --- Get tool version safely ---
get_tool_version() {
  local tool="$1"
  local version_output=""
  
  if ! command_exists "$tool"; then
    echo "Not installed"
    return
  fi
  
  case "$tool" in
    "nodejs"|"node")
      version_output=$(node --version 2>/dev/null | tr -d 'v')
      ;;
    "python3"|"python")
      version_output=$(python3 --version 2>/dev/null | cut -d' ' -f2)
      ;;
    "pip"|"pip3")
      version_output=$(pip3 --version 2>/dev/null | cut -d' ' -f2)
      ;;
    "uv")
      version_output=$(uv --version 2>/dev/null | cut -d' ' -f2)
      ;;
    "go")
      version_output=$(go version 2>/dev/null | cut -d' ' -f3 | tr -d 'go')
      ;;
    "rust"|"rustc")
      version_output=$(rustc --version 2>/dev/null | cut -d' ' -f2)
      ;;
    "java"|"openjdk")
      version_output=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
      ;;
    "maven"|"mvn")
      version_output=$(mvn --version 2>/dev/null | head -n1 | cut -d' ' -f3)
      ;;
    "gradle")
      version_output=$(gradle --version 2>/dev/null | grep "Gradle" | cut -d' ' -f2)
      ;;
    "awscli"|"aws")
      version_output=$(aws --version 2>/dev/null | cut -d'/' -f2 | cut -d' ' -f1)
      ;;
    "gcloud")
      version_output=$(gcloud version 2>/dev/null | head -n1 | cut -d' ' -f4)
      ;;
    "azurecli"|"az")
      version_output=$(az version 2>/dev/null | grep '"azure-cli"' | cut -d'"' -f4)
      ;;
    "jupyter")
      version_output=$(jupyter --version 2>/dev/null | head -n1 | cut -d' ' -f2)
      ;;
    "tmux")
      version_output=$(tmux -V 2>/dev/null | cut -d' ' -f2)
      ;;
    "vim")
      version_output=$(vim --version 2>/dev/null | head -n1 | grep -oP '\d+\.\d+' | head -n1)
      ;;
    "neovim")
      version_output=$(nvim --version 2>/dev/null | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
      ;;
    *)
      # Generic version check
      version_output=$("$tool" --version 2>/dev/null | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
      if [[ -z "$version_output" ]]; then
        version_output=$("$tool" -v 2>/dev/null | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
      fi
      if [[ -z "$version_output" ]]; then
        version_output=$("$tool" -V 2>/dev/null | head -n1 | grep -oP '\d+\.\d+(\.\d+)?' | head -n1)
      fi
      if [[ -z "$version_output" ]]; then
        version_output="Unknown"
      fi
      ;;
  esac
  
  if [[ -z "$version_output" ]]; then
    echo "Unknown"
  else
    echo "$version_output"
  fi
}

# --- List installed tools function ---
list_installed_tools() {
  print_header "Installed Development Tools"
  
  # Define all tools by category (simplified, with security tools properly handled)
  declare -A tools_by_category
  tools_by_category["Debugging Tools"]="htop strace gdb tmux vim neovim"
  tools_by_category["Monitoring Tools"]="ncdu iftop bmon nethogs iperf3 mtr vnstat"
  tools_by_category["Network Tools"]="net-tools dnsutils nmap netcat traceroute whois sshpass sshfs"
  tools_by_category["Text Utilities"]="bat lynx jq tree ripgrep"
  tools_by_category["Security Tools"]="nmap nikto hydra sqlmap john hashcat wireshark-cli"
  tools_by_category["Programming Tools"]="nodejs python3 pip uv go rust openjdk maven gradle ruby perl php lua"
  
  echo ""
  printf "%-25s %-20s %-15s\n" "CATEGORY" "TOOL" "VERSION"
  printf "%-25s %-20s %-15s\n" "========================" "===================" "=============="
  
  for category in "Debugging Tools" "Monitoring Tools" "Network Tools" "Text Utilities" "Security Tools" "Programming Tools"; do
    local tools="${tools_by_category[$category]}"
    local category_printed=false
    
    for tool in $tools; do
      local version
      version=$(get_tool_version "$tool")
      if [[ "$version" != "Not installed" ]]; then
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
  echo -e "${YELLOW}Note: Only installed tools are shown above.${RESET}"
  
  pause_with_options "action"
  local nav_result=$?
  case $nav_result in
    5) list_installed_tools; return $?;;  # Refresh the list and return its result
    *) return $nav_result;;  # Return the navigation choice
  esac
}



# --- Custom Install/Remove for UV ---
install_uv() {
  echo -e "${YELLOW}Installing UV (Python package manager)...${RESET}"
  curl -LsSf https://astral.sh/uv/install.sh 2>/dev/null | sh || true
  source "$HOME/.cargo/env" 2>/dev/null || true
  echo -e "${GREEN}UV installed successfully. Please restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc'.${RESET}"
}

remove_uv() {
  echo -e "${YELLOW}Removing UV...${RESET}"
  rm -rf ~/.cargo/bin/uv 2>/dev/null || true
  echo -e "${GREEN}UV removed successfully.${RESET}"
}

version_package() {
  local package="$1"
  local version=$(get_tool_version "$package")
  if [[ "$version" != "Not installed" ]]; then
    echo -e "${GREEN}$package version: $version${RESET}"
  else
    echo -e "${RED}$package is not installed.${RESET}"
  fi
}

update_package() {
  local package="$1"
  echo -e "${YELLOW}Attempting to update '$package'...${RESET}"
  if [[ "$(uname -s)" == "Linux" ]]; then
    if command_exists apt-get; then
      if [[ "$package" == "uv" ]]; then
        echo -e "${YELLOW}For UV, please reinstall to get the latest version.${RESET}"
        return 0
      else
        sudo apt-get update -y 2>/dev/null || true
        sudo apt-get install --only-upgrade -y "$package" 2>/dev/null || true
      fi
    elif command_exists yum; then
      sudo yum update -y "$package" 2>/dev/null || true
    elif command_exists dnf; then
      sudo dnf update -y "$package" 2>/dev/null || true
    elif command_exists pacman; then
      sudo pacman -Syu --noconfirm "$package" 2>/dev/null || true
    else
      echo -e "${RED}Error: Update not supported on this system. Please update '$package' manually.${RESET}"
      return 1
    fi
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    if command_exists brew; then
      if [[ "$package" == "uv" ]]; then
        brew upgrade uv 2>/dev/null || true
      else
        brew upgrade "$package" 2>/dev/null || true
      fi
    else
      echo -e "${RED}Error: Homebrew not found. Please update '$package' manually.${RESET}"
      return 1
    fi
  else
    echo -e "${RED}Error: Unsupported OS. Please update '$package' manually.${RESET}"
    return 1
  fi
  
  echo -e "${GREEN}Update attempt completed for '$package'.${RESET}"
  return 0
}

install_package() {
  local package="$1"
  echo -e "${YELLOW}Attempting to install '$package'...${RESET}"
  if [[ "$(uname -s)" == "Linux" ]]; then
    if command_exists apt-get; then
      if [[ "$package" == "nodejs" ]]; then
        curl -fsSL https://deb.nodesource.com/setup_18.x 2>/dev/null | sudo -E bash - 2>/dev/null || true
        sudo apt-get install -y nodejs 2>/dev/null || true
      elif [[ "$package" == "jupyter" ]]; then
        sudo apt-get install -y python3-pip python3-venv 2>/dev/null || true
        pip3 install jupyter 2>/dev/null || true
      elif [[ "$package" == "pip" ]]; then
        sudo apt-get install -y python3-pip 2>/dev/null || true
      elif [[ "$package" == "uv" ]]; then
        install_uv
        return $?
      else
        sudo apt-get update -y 2>/dev/null || true
        sudo apt-get install -y "$package" 2>/dev/null || true
      fi
    elif command_exists yum; then
      sudo yum install -y "$package" 2>/dev/null || true
    elif command_exists dnf; then
      sudo dnf install -y "$package" 2>/dev/null || true
    elif command_exists pacman; then
      sudo pacman -S --noconfirm "$package" 2>/dev/null || true
    else
      echo -e "${RED}Error: Unsupported package manager. Please install '$package' manually.${RESET}"
      return 1
    fi
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    if command_exists brew; then
      if [[ "$package" == "uv" ]]; then
        brew install uv 2>/dev/null || true
      else
        brew install "$package" 2>/dev/null || true
      fi
    else
      echo -e "${RED}Error: Homebrew not found. Please install '$package' manually.${RESET}"
      return 1
    fi
  else
    echo -e "${RED}Error: Unsupported OS. Please install '$package' manually.${RESET}"
    return 1
  fi
  
  # Check installation success
  if command_exists "$package" || { [[ "$package" == "jupyter" ]] && command_exists "jupyter"; } || { [[ "$package" == "pip" ]] && command_exists "pip3"; }; then
    echo -e "${GREEN}'$package' installed successfully.${RESET}"
    return 0
  else
    echo -e "${RED}Error installing '$package'. Please check the output.${RESET}"
    return 1
  fi
}

remove_package() {
  local package="$1"
  echo -e "${YELLOW}Attempting to remove '$package'...${RESET}"
  if [[ "$(uname -s)" == "Linux" ]]; then
    if command_exists apt-get; then
      if [[ "$package" == "jupyter" ]]; then
        pip3 uninstall -y jupyter 2>/dev/null || true
      elif [[ "$package" == "uv" ]]; then
        remove_uv
        return $?
      else
        sudo apt-get remove -y "$package" 2>/dev/null || true
      fi
    elif command_exists yum; then
      sudo yum remove -y "$package" 2>/dev/null || true
    elif command_exists dnf; then
      sudo dnf remove -y "$package" 2>/dev/null || true
    elif command_exists pacman; then
      sudo pacman -Rns --noconfirm "$package" 2>/dev/null || true
    else
      echo -e "${RED}Error: Unsupported package manager. Please remove '$package' manually.${RESET}"
      return 1
    fi
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    if command_exists brew; then
      if [[ "$package" == "uv" ]]; then
        brew uninstall uv 2>/dev/null || true
      else
        brew uninstall "$package" 2>/dev/null || true
      fi
    else
      echo -e "${RED}Error: Homebrew not found. Please remove '$package' manually.${RESET}"
      return 1
    fi
  else
    echo -e "${RED}Error: Unsupported OS. Please remove '$package' manually.${RESET}"
    return 1
  fi
  echo -e "${GREEN}'$package' removed.${RESET}"
  return 0
}

purge_package() {
  local package="$1"
  if [[ "$(uname -s)" == "Linux" ]] && command_exists apt-get; then
    echo -e "${YELLOW}Attempting to purge '$package' (remove with config)...${RESET}"
    if [[ "$package" == "jupyter" ]]; then
      pip3 uninstall -y jupyter 2>/dev/null || true
      echo -e "${GREEN}'$package' purged (pip uninstall).${RESET}"
    elif [[ "$package" == "uv" ]]; then
      remove_uv
      echo -e "${GREEN}'$package' purged.${RESET}"
    else
      sudo apt-get purge -y "$package" 2>/dev/null || true
      echo -e "${GREEN}'$package' purged.${RESET}"
    fi
    return 0
  else
    echo -e "${YELLOW}Purge not supported or not Linux (apt-get). Using regular remove for '$package'.${RESET}"
    remove_package "$package"
    return 0
  fi
}

# --- Enhanced Tool Management Function ---
manage_tool() {
  local tool="$1"
  local remove_only="$2" # Optional flag for tools where purge is risky

  while true; do
    echo ""
    print_header "Managing Tool: $tool"
    echo "What do you want to do with '$tool'?"
    echo "  i) Install"
    echo "  r) Remove"
    if [[ -z "$remove_only" ]]; then
      echo "  p) Purge (Linux apt-get only)"
    fi
    echo "  c) Check if Installed"
    echo "  v) Check Version"
    echo "  u) Update (apt-get only)"
    echo ""
    show_navigation_options "tool"
    read -r -p "Enter your choice: " action_choice

    case "$action_choice" in
      i)
        if [[ "$tool" == "uv" ]]; then
          install_uv
        else
          install_package "$tool"
        fi
        
        pause_with_options "action"
        local nav_result=$?
        case $nav_result in
          1) continue;;      # Back to tool menu (repeat loop)
          2) return 2;;      # Back to category
          3) return 3;;      # Main menu
          4) continue;;      # Repeat action (repeat loop)
          5) 
            list_installed_tools
            local list_result=$?
            case $list_result in
              1|2) return $list_result;;  # Navigate back from list
              3) return 3;;                # Main menu from list
              *) continue;;                # Stay in tool menu
            esac
            ;;
          0) continue;;      # Continue normally
        esac
        ;;
      r)
        if [[ "$tool" == "uv" ]]; then
          remove_uv
        else
          remove_package "$tool"
        fi
        
        pause_with_options "action"
        local nav_result=$?
        case $nav_result in
          1) continue;;      # Back to tool menu
          2) return 2;;      # Back to category
          3) return 3;;      # Main menu
          4) continue;;      # Repeat action
          5) 
            list_installed_tools
            local list_result=$?
            case $list_result in
              1|2) return $list_result;;
              3) return 3;;
              *) continue;;
            esac
            ;;
          0) continue;;
        esac
        ;;
      p) 
        if [[ -z "$remove_only" ]]; then 
          if [[ "$tool" == "uv" ]]; then
            remove_uv
          else
            purge_package "$tool"
          fi
          pause_with_options "action"
          local nav_result=$?
          case $nav_result in
            1) continue;;      # Back to tool menu
            2) return 2;;      # Back to category
            3) return 3;;      # Main menu
            4) continue;;      # Repeat action
            5) 
              list_installed_tools
              local list_result=$?
              case $list_result in
                1|2) return $list_result;;
                3) return 3;;
                *) continue;;
              esac
              ;;
            0) continue;;
          esac
        else 
          echo "Purge not available for this tool."
          pause_with_options "action"
          local nav_result=$?
          case $nav_result in
            1) continue;;      # Back to tool menu
            2) return 2;;      # Back to category
            3) return 3;;      # Main menu
            5) 
              list_installed_tools
              local list_result=$?
              case $list_result in
                1|2) return $list_result;;
                3) return 3;;
                *) continue;;
              esac
              ;;
            0) continue;;
          esac
        fi
        ;;
      c)
        if command_exists "$tool"; then
          echo -e "${GREEN}$tool is installed.${RESET}"
        else
          echo -e "${RED}$tool is not installed.${RESET}"
        fi
        
        pause_with_options "action"
        local nav_result=$?
        case $nav_result in
          1) continue;;      # Back to tool menu
          2) return 2;;      # Back to category
          3) return 3;;      # Main menu
          4) continue;;      # Repeat action
          5) 
            list_installed_tools
            local list_result=$?
            case $list_result in
              1|2) return $list_result;;
              3) return 3;;
              *) continue;;
            esac
            ;;
          0) continue;;
        esac
        ;;
      v)
        version_package "$tool"
        pause_with_options "action"
        local nav_result=$?
        case $nav_result in
          1) continue;;      # Back to tool menu
          2) return 2;;      # Back to category
          3) return 3;;      # Main menu
          4) continue;;      # Repeat action
          5) 
            list_installed_tools
            local list_result=$?
            case $list_result in
              1|2) return $list_result;;
              3) return 3;;
              *) continue;;
            esac
            ;;
          0) continue;;
        esac
        ;;
      u)
        update_package "$tool"
        pause_with_options "action"
        local nav_result=$?
        case $nav_result in
          1) continue;;      # Back to tool menu
          2) return 2;;      # Back to category
          3) return 3;;      # Main menu
          4) continue;;      # Repeat action
          5) 
            list_installed_tools
            local list_result=$?
            case $list_result in
              1|2) return $list_result;;
              3) return 3;;
              *) continue;;
            esac
            ;;
          0) continue;;
        esac
        ;;
      b|B) return 1;;        # Back to category
      m|M) return 3;;        # Main menu
      l|L) 
        list_installed_tools
        local list_result=$?
        case $list_result in
          1) return 1;;      # Back to category
          2) return 2;;      # Back to category (same as 1)
          3) return 3;;      # Main menu
          *) continue;;      # Stay in tool menu
        esac
        ;;
      q|Q) exit 0;;          # Quit
      *) echo "Invalid option.";;
    esac
  done
}

# --- Enhanced Category Management ---
show_category_menu() {
  local category_num="$1"
  local category_name="$2"
  
  while true; do
    print_header "$category_name"
    
    case "$category_num" in
      1)
        echo "  1) htop (Install/Remove/Purge)"
        echo "  2) strace (Install/Remove/Purge)"
        echo "  3) gdb (Install/Remove/Purge)"
        echo "  4) tmux (Install/Remove/Purge)"
        echo "  5) vim (Install/Remove/Purge)"
        echo "  6) neovim (Install/Remove/Purge)"
        ;;
      2)
        echo "  1) ncdu (Install/Remove/Purge)"
        echo "  2) iftop (Install/Remove/Purge)"
        echo "  3) bmon (Install/Remove/Purge)"
        echo "  4) nethogs (Install/Remove/Purge)"
        echo "  5) iperf3 (Install/Remove/Purge)"
        echo "  6) mtr (Install/Remove/Purge)"
        echo "  7) vnstat (Install/Remove/Purge)"
        ;;
      3)
        echo "  1) net-tools (Install/Remove/Purge)"
        echo "  2) dnsutils (Install/Remove/Purge)"
        echo "  3) nmap (Install/Remove/Purge)"
        echo "  4) netcat (Install/Remove/Purge)"
        echo "  5) traceroute (Install/Remove/Purge)"
        echo "  6) whois (Install/Remove/Purge)"
        echo "  7) sshpass (Install/Remove/Purge)"
        echo "  8) sshfs (Install/Remove/Purge)"
        ;;
      4)
        echo "  1) bat (Install/Remove/Purge)"
        echo "  2) lynx (Install/Remove/Purge)"
        echo "  3) jq (Install/Remove/Purge)"
        echo "  4) tree (Install/Remove/Purge)"
        echo "  5) ripgrep (Install/Remove/Purge)"
        ;;
      5)
        echo "  1) nmap (Install/Remove/Purge) - Network scanner"
        echo "  2) nikto (Install/Remove/Purge) - Web vulnerability scanner"
        echo "  3) hydra (Install/Remove/Purge) - Password cracker"
        echo "  4) sqlmap (Install/Remove/Purge) - SQL injection tool"
        echo "  5) john (Install/Remove/Purge) - Password hash cracker"
        echo "  6) hashcat (Install/Remove/Purge) - Advanced hash cracker"
        echo "  7) wireshark-cli (Install/Remove/Purge) - Network analyzer CLI"
        ;;
      6)
        echo "  1) nodejs (Install/Remove/Purge)"
        echo "  2) python3 (Install/Remove/Purge)"
        echo "  3) pip (Install/Remove/Purge)"
        echo "  4) uv (Install/Remove/Purge)"
        echo "  5) go (Install/Remove/Purge)"
        echo "  6) rust (Install/Remove/Purge)"
        echo "  7) openjdk (Install/Remove/Purge)"
        echo "  8) maven (Install/Remove/Purge)"
        echo "  9) gradle (Install/Remove/Purge)"
        echo " 10) ruby (Install/Remove/Purge)"
        echo " 11) perl (Install/Remove/Purge)"
        echo " 12) php (Install/Remove/Purge)"
        echo " 13) lua (Install/Remove/Purge)"
        ;;
    esac
    
    echo ""
    show_navigation_options "category"
    read -r -p "Enter option: " tool_choice
    
    case "$tool_choice" in
      b|B) return 1;;  # Back to main menu
      l|L) 
        list_installed_tools
        local list_result=$?
        case $list_result in
          1|2|3) return $list_result;;  # Pass navigation up
          *) continue;;                  # Stay in category menu
        esac
        ;;
      q|Q) exit 0;;    # Quit
      *)
        # Handle tool selection based on category
        local tool_result=0
        case "$category_num" in
          1)
            case "$tool_choice" in
              1) manage_tool "htop"; tool_result=$?;;
              2) manage_tool "strace"; tool_result=$?;;
              3) manage_tool "gdb"; tool_result=$?;;
              4) manage_tool "tmux"; tool_result=$?;;
              5) manage_tool "vim"; tool_result=$?;;
              6) manage_tool "neovim"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          2)
            case "$tool_choice" in
              1) manage_tool "ncdu"; tool_result=$?;;
              2) manage_tool "iftop"; tool_result=$?;;
              3) manage_tool "bmon"; tool_result=$?;;
              4) manage_tool "nethogs"; tool_result=$?;;
              5) manage_tool "iperf3"; tool_result=$?;;
              6) manage_tool "mtr"; tool_result=$?;;
              7) manage_tool "vnstat"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          3)
            case "$tool_choice" in
              1) manage_tool "net-tools"; tool_result=$?;;
              2) manage_tool "dnsutils"; tool_result=$?;;
              3) manage_tool "nmap"; tool_result=$?;;
              4) manage_tool "netcat"; tool_result=$?;;
              5) manage_tool "traceroute"; tool_result=$?;;
              6) manage_tool "whois"; tool_result=$?;;
              7) manage_tool "sshpass"; tool_result=$?;;
              8) manage_tool "sshfs"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          4)
            case "$tool_choice" in
              1) manage_tool "bat"; tool_result=$?;;
              2) manage_tool "lynx"; tool_result=$?;;
              3) manage_tool "jq"; tool_result=$?;;
              4) manage_tool "tree"; tool_result=$?;;
              5) manage_tool "ripgrep"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          5)
            case "$tool_choice" in
              1) manage_tool "nmap"; tool_result=$?;;
              2) manage_tool "nikto"; tool_result=$?;;
              3) manage_tool "hydra"; tool_result=$?;;
              4) manage_tool "sqlmap"; tool_result=$?;;
              5) manage_tool "john"; tool_result=$?;;
              6) manage_tool "hashcat"; tool_result=$?;;
              7) manage_tool "wireshark-cli"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          6)
            case "$tool_choice" in
              1) manage_tool "nodejs"; tool_result=$?;;
              2) manage_tool "python3"; tool_result=$?;;
              3) manage_tool "pip"; tool_result=$?;;
              4) manage_tool "uv"; tool_result=$?;;
              5) manage_tool "go"; tool_result=$?;;
              6) manage_tool "rust"; tool_result=$?;;
              7) manage_tool "openjdk"; tool_result=$?;;
              8) manage_tool "maven"; tool_result=$?;;
              9) manage_tool "gradle"; tool_result=$?;;
              10) manage_tool "ruby"; tool_result=$?;;
              11) manage_tool "perl"; tool_result=$?;;
              12) manage_tool "php"; tool_result=$?;;
              13) manage_tool "lua"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
        esac
        
        # Handle return codes from manage_tool
        case $tool_result in
          1) continue;;      # Stay in category menu
          2) continue;;      # Stay in category menu (came back from tool)
          3) return 3;;      # Go to main menu
          0) continue;;      # Normal completion, stay in category
        esac
        ;;
    esac
  done
}

# --- Main Menu ---
while true; do
  print_header "Manage Optional Tools"
  echo "Choose a category:"
  echo "  1) Debugging Tools"
  echo "  2) Monitoring Tools"
  echo "  3) Network Tools"
  echo "  4) Text Utilities"
  echo "  5) Security Tools"
  echo "  6) Programming Tools"
  echo ""
  show_navigation_options "main"
  read -r -p "Enter your choice: " category_choice
  
  # Trim whitespace
  category_choice=$(echo "$category_choice" | tr -d '[:space:]')

  case "$category_choice" in
    1) show_category_menu 1 "Debugging Tools";;
    2) show_category_menu 2 "Monitoring Tools";;
    3) show_category_menu 3 "Network Tools";;
    4) show_category_menu 4 "Text Utilities";;
    5) show_category_menu 5 "Security Tools";;
    6) show_category_menu 6 "Programming Tools";;
    l|L) 
      list_installed_tools
      # Don't exit on any result from list, just continue to main menu
      ;;
    q|Q)
      echo "Exiting tool management."
      break;;
    *)
      if [[ -n "$category_choice" ]]; then
        echo "Invalid choice."
      fi
      ;;
  esac
done

echo -e "${GREEN}Exiting tool management.${RESET}"
