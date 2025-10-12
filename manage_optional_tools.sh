#!/bin/bash

# Script to manage optional development tools.

set -e # Exit script immediately on error

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
  read -p "Press Enter to continue or choose navigation option: " nav_choice
  
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
    "docker")
      version_output=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')
      ;;
    "terraform")
      version_output=$(terraform version 2>/dev/null | head -n1 | cut -d'v' -f2)
      ;;
    "kubectl")
      version_output=$(kubectl version --client --short 2>/dev/null | cut -d' ' -f3)
      ;;
    "helm")
      version_output=$(helm version --short 2>/dev/null | cut -d'v' -f2)
      ;;
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
    *)
      # Generic version check
      version_output=$("$tool" --version 2>/dev/null | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
      if [[ -z "$version_output" ]]; then
        version_output=$("$tool" -v 2>/dev/null | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
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
  
  # Define all tools by category
  declare -A tools_by_category
  tools_by_category["Debugging Tools"]="htop strace tcpdump wireshark gdb tmux vim neovim"
  tools_by_category["Monitoring Tools"]="ncdu iftop bmon nethogs"
  tools_by_category["Network Tools"]="net-tools dnsutils nmap netcat traceroute whois sshuttle sshpass sshfs"
  tools_by_category["Text Utilities"]="bat lynx jq tree ripgrep"
  tools_by_category["Security Tools"]="burp-suite sqlmap msfconsole feroxbuster httprobe subjack gau gobuster whatweb nikto dirsearch"
  tools_by_category["Containerization"]="docker kubectl helm"
  tools_by_category["Infrastructure as Code"]="terraform pulumi ansible"
  tools_by_category["Cloud CLIs"]="awscli gcloud azurecli"
  tools_by_category["Programming Tools"]="nodejs python3 jupyter nvm go rust openjdk maven gradle ruby perl php lua scala kotlin dart crystal haskell pip uv"
  
  echo ""
  printf "%-25s %-20s %-15s\n" "CATEGORY" "TOOL" "VERSION"
  printf "%-25s %-20s %-15s\n" "========================" "===================" "=============="
  
  for category in "Debugging Tools" "Monitoring Tools" "Network Tools" "Text Utilities" "Security Tools" "Containerization" "Infrastructure as Code" "Cloud CLIs" "Programming Tools"; do
    local tools="${tools_by_category[$category]}"
    local category_printed=false
    
    for tool in $tools; do
      local version=$(get_tool_version "$tool")
      if [[ "$version" != "Not installed" ]]; then
        if [[ "$category_printed" == false ]]; then
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
  nav_result=$?
  case $nav_result in
    1|2|3|4) return $nav_result;;
    5) list_installed_tools;;  # Refresh the list
  esac
}

# --- Version and Update Helpers ---
version_package() {
  local package="$1"
  if command_exists "$package"; then
    echo -e "${YELLOW}Checking version for '$package'...${RESET}"
    "$package" --version 2>&1 | head -n 1
  else
    echo -e "${RED}Error: '$package' is not installed.${RESET}"
    return 1
  fi
}

update_package() {
  local package="$1"
  if [[ "$(uname -s)" == "Linux" ]] && command_exists apt-get; then
    echo -e "${YELLOW}Attempting to update '$package'...${RESET}"
    sudo apt-get update
    sudo apt-get install --only-upgrade -y "$package"
    echo -e "${GREEN}'$package' updated.${RESET}"
  else
    echo -e "${RED}Error: Update not supported or not Linux (apt-get).${RESET}"
    return 1
  fi
}

# --- Custom Install/Remove for Docker ---
install_docker() {
  echo -e "${YELLOW}Installing Docker...${RESET}"
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  echo -e "${YELLOW}Testing Docker installation...${RESET}"
  sudo docker run hello-world || echo -e "${RED}Docker test failed. Please check installation.${RESET}"
  echo -e "${GREEN}Docker install steps completed.${RESET}"
}

remove_docker() {
  echo -e "${YELLOW}Removing Docker...${RESET}"
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
  sudo apt-get autoremove -y --purge
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd
  sudo rm -f /etc/apt/sources.list.d/docker.list
  echo -e "${GREEN}Docker removed successfully.${RESET}"
}

# --- Custom Install/Remove for Terraform ---
install_terraform() {
  echo -e "${YELLOW}Installing Terraform...${RESET}"
  wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y terraform
  echo -e "${GREEN}Terraform installed successfully.${RESET}"
}

remove_terraform() {
  echo -e "${YELLOW}Removing Terraform...${RESET}"
  sudo apt-get remove -y terraform
  sudo rm -f /etc/apt/sources.list.d/hashicorp.list
  sudo apt-get update
  echo -e "${GREEN}Terraform removed successfully.${RESET}"
}

# --- Custom Install/Remove for UV ---
install_uv() {
  echo -e "${YELLOW}Installing UV (Python package manager)...${RESET}"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source $HOME/.cargo/env
  echo -e "${GREEN}UV installed successfully. Please restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc'.${RESET}"
}

remove_uv() {
  echo -e "${YELLOW}Removing UV...${RESET}"
  rm -rf ~/.cargo/bin/uv
  echo -e "${GREEN}UV removed successfully.${RESET}"
}

install_package() {
  local package="$1"
  echo -e "${YELLOW}Attempting to install '$package'...${RESET}"
  if [[ "$(uname -s)" == "Linux" ]]; then
    if command_exists apt-get; then
      if [[ "$package" == "nodejs" ]]; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
      elif [[ "$package" == "jupyter" ]]; then
        sudo apt-get install -y python3-pip python3-venv
        pip3 install jupyter
      elif [[ "$package" == "pip" ]]; then
        sudo apt-get install -y python3-pip
      elif [[ "$package" == "uv" ]]; then
        install_uv
        return $?
      else
        sudo apt-get update -y
        sudo apt-get install -y "$package"
      fi
    elif command_exists yum; then
      sudo yum install -y "$package"
    elif command_exists dnf; then
      sudo dnf install -y "$package"
    elif command_exists pacman; then
      sudo pacman -S --noconfirm "$package"
    else
      echo -e "${RED}Error: Unsupported package manager. Please install '$package' manually.${RESET}"
      return 1
    fi
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    if command_exists brew; then
      if [[ "$package" == "uv" ]]; then
        brew install uv
      else
        brew install "$package"
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
  if command_exists "$package" || [[ "$package" == "jupyter" && -x "$(command -v jupyter)" ]] || [[ "$package" == "pip" && command_exists "pip3" ]]; then
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
        pip3 uninstall -y jupyter
      elif [[ "$package" == "uv" ]]; then
        remove_uv
        return $?
      else
        sudo apt-get remove -y "$package"
      fi
    elif command_exists yum; then
      sudo yum remove -y "$package"
    elif command_exists dnf; then
      sudo dnf remove -y "$package"
    elif command_exists pacman; then
      sudo pacman -Rns --noconfirm "$package"
    else
      echo -e "${RED}Error: Unsupported package manager. Please remove '$package' manually.${RESET}"
      return 1
    fi
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    if command_exists brew; then
      if [[ "$package" == "uv" ]]; then
        brew uninstall uv
      else
        brew uninstall "$package"
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
      pip3 uninstall -y jupyter
      echo -e "${GREEN}'$package' purged (pip uninstall).${RESET}"
    elif [[ "$package" == "uv" ]]; then
      remove_uv
      echo -e "${GREEN}'$package' purged.${RESET}"
    else
      sudo apt-get purge -y "$package"
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
    read -p "Enter your choice: " action_choice

    case "$action_choice" in
      i)
        if [[ "$tool" == "docker" ]]; then
          install_docker
        elif [[ "$tool" == "terraform" ]]; then
          install_terraform
        elif [[ "$tool" == "uv" ]]; then
          install_uv
        else
          install_package "$tool"
        fi
        
        pause_with_options "action"
        nav_result=$?
        case $nav_result in
          1) continue;;      # Back to tool menu (repeat loop)
          2) return 2;;      # Back to category
          3) return 3;;      # Main menu
          4) continue;;      # Repeat action (repeat loop)
          5) list_installed_tools;;  # List tools
        esac
        ;;
      r)
        if [[ "$tool" == "docker" ]]; then
          remove_docker
        elif [[ "$tool" == "terraform" ]]; then
          remove_terraform
        elif [[ "$tool" == "uv" ]]; then
          remove_uv
        else
          remove_package "$tool"
        fi
        
        pause_with_options "action"
        nav_result=$?
        case $nav_result in
          1) continue;;      # Back to tool menu
          2) return 2;;      # Back to category
          3) return 3;;      # Main menu
          4) continue;;      # Repeat action
          5) list_installed_tools;;  # List tools
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
          nav_result=$?
          case $nav_result in
            1) continue;;      # Back to tool menu
            2) return 2;;      # Back to category
            3) return 3;;      # Main menu
            4) continue;;      # Repeat action
            5) list_installed_tools;;  # List tools
          esac
        else 
          echo "Purge not available for this tool."
          pause_with_options "action"
          nav_result=$?
          case $nav_result in
            1) continue;;      # Back to tool menu
            2) return 2;;      # Back to category
            3) return 3;;      # Main menu
            5) list_installed_tools;;  # List tools
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
        nav_result=$?
        case $nav_result in
          1) continue;;      # Back to tool menu
          2) return 2;;      # Back to category
          3) return 3;;      # Main menu
          4) continue;;      # Repeat action
          5) list_installed_tools;;  # List tools
        esac
        ;;
      v)
        version_package "$tool"
        pause_with_options "action"
        nav_result=$?
        case $nav_result in
          1) continue;;      # Back to tool menu
          2) return 2;;      # Back to category
          3) return 3;;      # Main menu
          4) continue;;      # Repeat action
          5) list_installed_tools;;  # List tools
        esac
        ;;
      u)
        update_package "$tool"
        pause_with_options "action"
        nav_result=$?
        case $nav_result in
          1) continue;;      # Back to tool menu
          2) return 2;;      # Back to category
          3) return 3;;      # Main menu
          4) continue;;      # Repeat action
          5) list_installed_tools;;  # List tools
        esac
        ;;
      b|B) return 1;;        # Back to category
      m|M) return 3;;        # Main menu
      l|L) list_installed_tools;;  # List installed tools
      q|Q) exit 0;;          # Quit
      *) echo "Invalid action.";;
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
        echo "  a) htop (Install/Remove/Purge)"
        echo "  b) strace (Install/Remove/Purge)"
        echo "  c) tcpdump (Install/Remove/Purge)"
        echo "  d) wireshark (Install/Remove)"
        echo "  e) gdb (Install/Remove/Purge)"
        echo "  f) tmux (Install/Remove/Purge)"
        echo "  g) vim (Install/Remove/Purge)"
        echo "  h) neovim (Install/Remove/Purge)"
        ;;
      2)
        echo "  a) ncdu (Install/Remove/Purge)"
        echo "  b) iftop (Install/Remove/Purge)"
        echo "  c) bmon (Install/Remove/Purge)"
        echo "  d) nethogs (Install/Remove/Purge)"
        echo "  e) iperf3 (Install/Remove/Purge)"
        echo "  f) mtr (Install/Remove/Purge)"
        echo "  g) vnstat (Install/Remove/Purge)"
        ;;
      3)
        echo "  a) net-tools (Install/Remove/Purge)"
        echo "  b) dnsutils (Install/Remove/Purge)"
        echo "  c) nmap (Install/Remove/Purge)"
        echo "  d) netcat (Install/Remove/Purge)"
        echo "  e) traceroute (Install/Remove/Purge)"
        echo "  f) whois (Install/Remove/Purge)"
        echo "  g) sshuttle (Install/Remove/Purge)"
        echo "  h) sshpass (Install/Remove/Purge)"
        echo "  i) sshfs (Install/Remove/Purge)"
        ;;
      4)
        echo "  a) bat (Install/Remove/Purge)"
        echo "  b) lynx (Install/Remove/Purge)"
        echo "  c) jq (Install/Remove/Purge)"
        echo "  d) tree (Install/Remove/Purge)"
        echo "  e) ripgrep (Install/Remove/Purge)"
        ;;
      5)
        echo "  a) burp-suite (Install/Remove)"
        echo "  b) sqlmap (Install/Remove)"
        echo "  c) msfconsole (Install/Remove)"
        echo "  d) feroxbuster (Install/Remove)"
        echo "  e) httprobe (Install/Remove)"
        echo "  f) subjack (Install/Remove)"
        echo "  g) gau (Install/Remove)"
        echo "  h) gobuster (Install/Remove)"
        echo "  i) whatweb (Install/Remove)"
        echo "  j) nikto (Install/Remove)"
        echo "  k) dirsearch (Install/Remove)"
        ;;
      6)
        echo "  a) docker (Install/Remove/Purge)"
        echo "  b) kubectl (Install/Remove)"
        echo "  c) helm (Install/Remove)"
        ;;
      7)
        echo "  a) terraform (Install/Remove)"
        echo "  b) pulumi (Install/Remove)"
        echo "  c) ansible (Install/Remove/Purge)"
        ;;
      8)
        echo "  a) awscli (Install/Remove)"
        echo "  b) gcloud (Install/Remove)"
        echo "  c) azurecli (Install/Remove)"
        ;;
      9)
        echo "  a) nodejs (Install/Remove)"
        echo "  b) python3 (Install/Remove/Purge)"
        echo "  c) jupyter (Install/Remove/Purge)"
        echo "  d) nvm (Install/Remove)"
        echo "  e) go (Install/Remove/Purge)"
        echo "  f) rust (Install/Remove)"
        echo "  g) openjdk (Install/Remove/Purge)"
        echo "  h) maven (Install/Remove/Purge)"
        echo "  i) gradle (Install/Remove/Purge)"
        echo "  j) ruby (Install/Remove/Purge)"
        echo "  k) perl (Install/Remove/Purge)"
        echo "  l) php (Install/Remove/Purge)"
        echo "  m) lua (Install/Remove/Purge)"
        echo "  n) scala (Install/Remove/Purge)"
        echo "  o) kotlin (Install/Remove/Purge)"
        echo "  p) dart (Install/Remove/Purge)"
        echo "  q) crystal (Install/Remove/Purge)"
        echo "  r) haskell (Install/Remove/Purge)"
        echo "  s) pip (Install/Remove/Purge)"
        echo "  t) uv (Install/Remove/Purge)"
        ;;
    esac
    
    echo ""
    show_navigation_options "category"
    read -p "Enter option: " tool_choice
    
    case "$tool_choice" in
      b|B) return 1;;  # Back to main menu
      l|L) list_installed_tools;;  # List installed tools
      q|Q) exit 0;;    # Quit
      *)
        # Handle tool selection based on category
        local tool_result=0
        case "$category_num" in
          1)
            case "$tool_choice" in
              a) manage_tool "htop"; tool_result=$?;;
              b) manage_tool "strace"; tool_result=$?;;
              c) manage_tool "tcpdump"; tool_result=$?;;
              d) manage_tool "wireshark" "remove"; tool_result=$?;;
              e) manage_tool "gdb"; tool_result=$?;;
              f) manage_tool "tmux"; tool_result=$?;;
              g) manage_tool "vim"; tool_result=$?;;
              h) manage_tool "neovim"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          2)
            case "$tool_choice" in
              a) manage_tool "ncdu"; tool_result=$?;;
              b) manage_tool "iftop"; tool_result=$?;;
              c) manage_tool "bmon"; tool_result=$?;;
              d) manage_tool "nethogs"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          3)
            case "$tool_choice" in
              a) manage_tool "net-tools"; tool_result=$?;;
              b) manage_tool "dnsutils"; tool_result=$?;;
              c) manage_tool "nmap"; tool_result=$?;;
              d) manage_tool "netcat"; tool_result=$?;;
              e) manage_tool "traceroute"; tool_result=$?;;
              f) manage_tool "whois"; tool_result=$?;;
              g) manage_tool "sshuttle"; tool_result=$?;;
              h) manage_tool "sshpass"; tool_result=$?;;
              i) manage_tool "sshfs"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          4)
            case "$tool_choice" in
              a) manage_tool "bat"; tool_result=$?;;
              b) manage_tool "lynx"; tool_result=$?;;
              c) manage_tool "jq"; tool_result=$?;;
              d) manage_tool "tree"; tool_result=$?;;
              e) manage_tool "ripgrep"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          5)
            case "$tool_choice" in
              a) manage_tool "burp-suite" "remove"; echo "Note: Burp Suite might require manual installation."; tool_result=$?;;
              b) manage_tool "sqlmap" "remove"; tool_result=$?;;
              c) manage_tool "msfconsole" "remove"; tool_result=$?;;
              d) manage_tool "feroxbuster" "remove"; tool_result=$?;;
              e) manage_tool "httprobe" "remove"; tool_result=$?;;
              f) manage_tool "subjack" "remove"; tool_result=$?;;
              g) manage_tool "gau" "remove"; tool_result=$?;;
              h) manage_tool "gobuster" "remove"; tool_result=$?;;
              i) manage_tool "whatweb" "remove"; tool_result=$?;;
              j) manage_tool "nikto" "remove"; tool_result=$?;;
              k) manage_tool "dirsearch" "remove"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          6)
            case "$tool_choice" in
              a) manage_tool "docker"; tool_result=$?;;
              b) manage_tool "kubectl" "remove"; echo "Note: Kubectl might require specific removal steps."; tool_result=$?;;
              c) manage_tool "helm" "remove"; echo "Note: Helm might require specific removal steps."; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          7)
            case "$tool_choice" in
              a) manage_tool "terraform" "remove"; tool_result=$?;;
              b) manage_tool "pulumi" "remove"; tool_result=$?;;
              c) manage_tool "ansible"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          8)
            case "$tool_choice" in
              a) manage_tool "awscli" "remove"; echo "Note: AWS CLI might require pip uninstall."; tool_result=$?;;
              b) manage_tool "gcloud" "remove"; echo "Note: gcloud might have its own uninstaller."; tool_result=$?;;
              c) manage_tool "azurecli" "remove"; echo "Note: Azure CLI might require pip uninstall."; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
          9)
            case "$tool_choice" in
              a) manage_tool "nodejs" "remove"; tool_result=$?;;
              b) manage_tool "python3"; tool_result=$?;;
              c) manage_tool "jupyter"; tool_result=$?;;
              d) manage_tool "nvm" "remove"; echo "Note: nvm might require manual installation."; tool_result=$?;;
              e) manage_tool "go"; tool_result=$?;;
              f) manage_tool "rust" "remove"; echo "Note: Rust might require rustup uninstall."; tool_result=$?;;
              g) manage_tool "openjdk"; tool_result=$?;;
              h) manage_tool "maven"; tool_result=$?;;
              i) manage_tool "gradle"; tool_result=$?;;
              j) manage_tool "ruby"; tool_result=$?;;
              k) manage_tool "perl"; tool_result=$?;;
              l) manage_tool "php"; tool_result=$?;;
              m) manage_tool "lua"; tool_result=$?;;
              n) manage_tool "scala"; tool_result=$?;;
              o) manage_tool "kotlin"; tool_result=$?;;
              p) manage_tool "dart"; tool_result=$?;;
              q) manage_tool "crystal"; tool_result=$?;;
              r) manage_tool "haskell"; tool_result=$?;;
              s) manage_tool "pip"; tool_result=$?;;
              t) manage_tool "uv"; tool_result=$?;;
              *) echo "Invalid option."; continue;;
            esac
            ;;
        esac
        
        # Handle return codes from manage_tool
        case $tool_result in
          1) continue;;      # Stay in category menu
          2) continue;;      # Stay in category menu (came back from tool)
          3) return 3;;      # Go to main menu
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
  echo "  6) Containerization Tools"
  echo "  7) Infrastructure as Code Tools"
  echo "  8) Cloud CLIs"
  echo "  9) Programming Tools"
  echo ""
  show_navigation_options "main"
  read -p "Enter your choice: " category_choice

  case "$category_choice" in
    1) show_category_menu 1 "Debugging Tools";;
    2) show_category_menu 2 "Monitoring Tools";;
    3) show_category_menu 3 "Network Tools";;
    4) show_category_menu 4 "Text Utilities";;
    5) show_category_menu 5 "Security Tools";;
    6) show_category_menu 6 "Containerization Tools";;
    7) show_category_menu 7 "Infrastructure as Code Tools";;
    8) show_category_menu 8 "Cloud CLIs";;
    9) show_category_menu 9 "Programming Tools";;
    l|L) list_installed_tools;;
    q|Q)
      echo "Exiting tool management."
      break;;
    *)
      echo "Invalid choice.";;
  esac
done

echo -e "${GREEN}Exiting tool management.${RESET}"
