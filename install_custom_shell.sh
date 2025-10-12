#!/bin/bash

# Custom Shell Environment Setup Script
# Supports Ubuntu 20.04+, macOS with comprehensive shell and framework options

set -e # Exit script immediately on error

# --- Global Variables ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/shell-backup-$(date +%Y%m%d-%H%M%S)"
SETUP_MODE="new"
PREFERRED_SHELL=""
SHELL_NAME=""
PROMPT_FRAMEWORK=""
THEME_TEMPLATE=""
AVAILABLE_FRAMEWORKS=()
CHECK_MODE="${CHECK_MODE:-}"

# --- Colors for Readability ---
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
BOLD="\e[1m"
RESET="\e[0m"

# --- Helper Functions ---
print_header() {
  echo -e "\n${BOLD}${BLUE}================================================================${RESET}"
  echo -e "${BOLD}${CYAN}  $1${RESET}"
  echo -e "${BOLD}${BLUE}================================================================${RESET}\n"
}

print_step() {
  echo -e "\n${BLUE}==>${RESET} ${CYAN}$1${RESET}"
}

print_success() {
  echo -e "${GREEN}✓${RESET} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${RESET} $1"
}

print_error() {
  echo -e "${RED}✗${RESET} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${RESET} $1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to detect OS and version
detect_os() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "macos"
  elif [[ "$(uname -s)" == "Linux" ]]; then
    if [[ -f /etc/os-release ]]; then
      . /etc/os-release
      if [[ "$ID" == "ubuntu" ]]; then
        # Check Ubuntu version
        version_major=$(echo "$VERSION_ID" | cut -d. -f1)
        version_minor=$(echo "$VERSION_ID" | cut -d. -f2)
        if [[ "$version_major" -ge 20 ]]; then
          echo "ubuntu"
        else
          echo "unsupported_ubuntu"
        fi
      else
        echo "unsupported_linux"
      fi
    else
      echo "unsupported_linux"
    fi
  else
    echo "unsupported"
  fi
}

# Function to detect if running in WSL
detect_wsl() {
  if [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
    return 0  # Running in WSL
  elif [[ -f /proc/sys/kernel/osrelease ]] && grep -qi microsoft /proc/sys/kernel/osrelease; then
    return 0  # Running in WSL
  else
    return 1  # Not running in WSL
  fi
}

# Function to check for existing shell configurations
check_existing_setup() {
  local has_existing=false
  local configs_found=()
  
  print_step "Checking for existing shell configurations..."
  
  # Check for existing config files
  [[ -f ~/.zshrc ]] && configs_found+=(".zshrc") && has_existing=true
  [[ -f ~/.bashrc ]] && configs_found+=(".bashrc") && has_existing=true
  [[ -f ~/.config/fish/config.fish ]] && configs_found+=("fish config") && has_existing=true
  [[ -f ~/.config/nushell/config.nu ]] && configs_found+=("nushell config") && has_existing=true
  [[ -d ~/.oh-my-zsh ]] && configs_found+=("Oh My Zsh") && has_existing=true
  [[ -f ~/.p10k.zsh ]] && configs_found+=("Powerlevel10k config") && has_existing=true
  [[ -f ~/.config/starship.toml ]] && configs_found+=("Starship config") && has_existing=true
  
  if [[ "$has_existing" == true ]]; then
    print_warning "Found existing shell configurations:"
    for config in "${configs_found[@]}"; do
      echo "  • $config"
    done
    echo ""
    echo "Options:"
    echo "  1) Update/modify existing setup (with backup)"
    echo "  2) Clean install (backup existing configs first)"
    echo "  3) Exit without changes"
    echo ""
    read -p "Enter your choice [1-3]: " existing_choice
    
    case "$existing_choice" in
      1)
        SETUP_MODE="update"
        print_success "Will update existing setup with backup"
        ;;
      2)
        SETUP_MODE="clean"
        print_success "Will perform clean install with backup"
        ;;
      3)
        print_info "Exiting without changes"
        exit 0
        ;;
      *)
        print_warning "Invalid choice. Defaulting to update mode"
        SETUP_MODE="update"
        ;;
    esac
  else
    SETUP_MODE="new"
    print_success "No existing configurations found. Proceeding with fresh install"
  fi
}

# Function to install Ansible if needed
ensure_ansible() {
  print_step "Checking for Ansible..."
  
  if command_exists ansible-playbook; then
    local version=$(ansible --version | head -n1 | awk '{print $2}')
    print_success "Ansible $version is already installed"
    return 0
  fi
  
  print_warning "Ansible not found. Installing..."
  
  local os=$(detect_os)
  case "$os" in
    ubuntu)
      print_info "Installing Ansible on Ubuntu..."
      sudo apt-get update -qq
      sudo apt-get install -y software-properties-common
      sudo add-apt-repository --yes --update ppa:ansible/ansible
      sudo apt-get install -y ansible
      ;;
    macos)
      print_info "Installing Ansible on macOS..."
      if command_exists brew; then
        brew install ansible
      else
        print_error "Homebrew not found. Please install Homebrew first:"
        print_info "Visit: https://brew.sh"
        exit 1
      fi
      ;;
    unsupported_ubuntu)
      print_error "Ubuntu version is too old. This script requires Ubuntu 20.04 or newer."
      exit 1
      ;;
    unsupported_linux)
      print_error "This script only supports Ubuntu 20.04+ on Linux."
      exit 1
      ;;
    *)
      print_error "Unsupported operating system."
      exit 1
      ;;
  esac
  
  if command_exists ansible-playbook; then
    print_success "Ansible installed successfully"
  else
    print_error "Failed to install Ansible"
    exit 1
  fi
}

# Function to validate project structure
validate_project_structure() {
  print_step "Validating project structure..."
  
  local required_files=(
    "ansible/custom_dev_env.yml"
    "ansible/inventory/localhost"
  )
  
  local missing_files=()
  
  for file in "${required_files[@]}"; do
    if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
      missing_files+=("$file")
    fi
  done
  
  if [[ ${#missing_files[@]} -gt 0 ]]; then
    print_error "Missing required files:"
    for file in "${missing_files[@]}"; do
      echo "  • $file"
    done
    print_info "Please ensure you're running from the correct directory with all required files."
    exit 1
  fi
  
  print_success "Project structure validated"
}

# Function to create backup of existing configurations
create_backup() {
  if [[ "$SETUP_MODE" == "new" ]]; then
    return 0
  fi
  
  print_step "Creating backup of existing configurations..."
  
  mkdir -p "$BACKUP_DIR"
  local backed_up=()
  
  # Backup shell configs
  [[ -f ~/.bashrc ]] && cp ~/.bashrc "$BACKUP_DIR/" && backed_up+=(".bashrc")
  [[ -f ~/.zshrc ]] && cp ~/.zshrc "$BACKUP_DIR/" && backed_up+=(".zshrc")
  [[ -f ~/.config/fish/config.fish ]] && cp ~/.config/fish/config.fish "$BACKUP_DIR/" && backed_up+=("fish/config.fish")
  [[ -f ~/.config/nushell/config.nu ]] && cp ~/.config/nushell/config.nu "$BACKUP_DIR/" && backed_up+=("nushell/config.nu")
  
  # Backup framework configs
  [[ -f ~/.p10k.zsh ]] && cp ~/.p10k.zsh "$BACKUP_DIR/" && backed_up+=(".p10k.zsh")
  [[ -f ~/.config/starship.toml ]] && cp ~/.config/starship.toml "$BACKUP_DIR/" && backed_up+=("starship.toml")
  
  # Backup Oh My Zsh if doing clean install
  if [[ "$SETUP_MODE" == "clean" ]] && [[ -d ~/.oh-my-zsh ]]; then
    cp -r ~/.oh-my-zsh "$BACKUP_DIR/" && backed_up+=("oh-my-zsh/")
  fi
  
  if [[ ${#backed_up[@]} -gt 0 ]]; then
    print_success "Backup created at: $BACKUP_DIR"
    print_info "Backed up files:"
    for file in "${backed_up[@]}"; do
      echo "  • $file"
    done
  else
    print_info "No files to backup"
    rmdir "$BACKUP_DIR" 2>/dev/null || true
  fi
}

# Function to validate shell paths
validate_shell_path() {
  local shell_path="$1"
  local shell_name="$2"
  
  # For Nushell, check multiple possible locations
  if [[ "$shell_name" == "Nushell" ]]; then
    local possible_paths=("/usr/local/bin/nu" "/usr/bin/nu" "$HOME/.cargo/bin/nu")
    for path in "${possible_paths[@]}"; do
      if [[ -x "$path" ]] || [[ "$CHECK_MODE" == "--check" ]]; then
        PREFERRED_SHELL="$path"
        return 0
      fi
    done
    # Will be installed by Ansible, so use default path
    PREFERRED_SHELL="/usr/local/bin/nu"
    return 0
  fi
  
  # For other shells, validate or use standard paths
  case "$shell_name" in
    "Bash")
      PREFERRED_SHELL="/bin/bash"
      ;;
    "Zsh")
      if command_exists zsh; then
        PREFERRED_SHELL="$(which zsh)"
      else
        PREFERRED_SHELL="/usr/bin/zsh"
      fi
      ;;
    "Fish")
      if command_exists fish; then
        PREFERRED_SHELL="$(which fish)"
      else
        PREFERRED_SHELL="/usr/bin/fish"
      fi
      ;;
  esac
  
  return 0
}

# Function to select shell
select_shell() {
  print_header "Shell Selection"
  
  local os=$(detect_os)
  local default_choice=""
  
  # Set OS-specific defaults
  case "$os" in
    ubuntu)
      default_choice="1"  # Bash for Ubuntu
      ;;
    macos)
      default_choice="2"  # Zsh for macOS
      ;;
    *)
      default_choice="2"  # Default to Zsh for others
      ;;
  esac
  
  echo "Choose your preferred shell:"
  echo ""
  
  if [[ "$default_choice" == "1" ]]; then
    print_info "Bash (Default for Ubuntu)"
    echo -e "  ${BOLD}1) Bash${RESET} ${GREEN}(Default for Ubuntu)${RESET}"
  else
    echo -e "  ${BOLD}1) Bash${RESET}"
  fi
  echo "     • Default shell on most systems"
  echo "     • Reliable and well-documented"
  echo "     • Great for scripting and automation"
  echo "     • Works with Starship prompt"
  echo ""
  
  if [[ "$default_choice" == "2" ]]; then
    print_info "Zsh (Default for macOS, works well on Linux too and with P10k)"
    echo -e "  ${BOLD}2) Zsh${RESET} ${GREEN}(Default for macOS)${RESET}"
  else
    print_info "Zsh (Recommended for Feature-Rich Experience)"
    echo -e "  ${BOLD}2) Zsh${RESET}"
  fi
  echo "     • Feature-rich with excellent tab completion"
  echo "     • Compatible with Bash scripts"
  echo "     • Extensive customization options"
  echo "     • Works with Oh My Zsh, Powerlevel10k, Starship, and more"
  echo ""

  print_info "Fish (Recommended for User-Friendliness)"
  echo -e "  ${BOLD}3) Fish${RESET}"
  echo "     • User-friendly with smart autosuggestions"
  echo "     • Syntax highlighting out of the box"
  echo "     • Web-based configuration"
  echo "     • Modern and intuitive design"
  echo ""

  print_info "Nushell (Recommended for Data Manipulation)"
  echo -e "  ${BOLD}4) Nushell${RESET}"
  echo "     • Modern shell with structured data support"
  echo "     • Built-in commands for data manipulation"
  echo "     • Cross-platform consistency"
  echo "     • Perfect for data analysis and DevOps"
  echo ""
  
  read -p "Enter your choice [1-4] (default: $default_choice): " shell_choice
  
  # Use default if no choice entered
  if [[ -z "$shell_choice" ]]; then
    shell_choice="$default_choice"
  fi
  
  case "$shell_choice" in
    1)
      SHELL_NAME="Bash"
      AVAILABLE_FRAMEWORKS=("starship")
      ;;
    2)
      SHELL_NAME="Zsh"
      AVAILABLE_FRAMEWORKS=("oh-my-zsh" "oh-my-posh" "starship" "spaceship" "zim" "prezto")
      ;;
    3)
      SHELL_NAME="Fish"
      AVAILABLE_FRAMEWORKS=("starship" "oh-my-posh")
      ;;
    4)
      SHELL_NAME="Nushell"
      AVAILABLE_FRAMEWORKS=("starship" "oh-my-posh")
      ;;
    *)
      print_warning "Invalid choice. Using OS default."
      if [[ "$default_choice" == "1" ]]; then
        SHELL_NAME="Bash"
        AVAILABLE_FRAMEWORKS=("starship")
      else
        SHELL_NAME="Zsh"
        AVAILABLE_FRAMEWORKS=("oh-my-zsh" "oh-my-posh" "starship" "spaceship" "zim" "prezto")
      fi
      ;;
  esac
  
  validate_shell_path "$PREFERRED_SHELL" "$SHELL_NAME"
  print_success "Selected: $SHELL_NAME ($PREFERRED_SHELL)"
}

# Function to select framework/prompt
select_framework() {
  print_header "Framework & Prompt Selection"
  
  echo -e "Available frameworks for $SHELL_NAME:"
  echo ""
  
  local framework_descriptions=(
    "oh-my-zsh:Oh My Zsh with Powerlevel10k:Feature-rich Zsh framework with beautiful prompts:Highly customizable, large community, many plugins"
    "oh-my-posh:Oh My Posh:Cross-shell prompt engine:Modern themes, works across shells, JSON configuration"
    "starship:Starship:Fast, cross-shell prompt:Minimal setup, blazing fast, language-aware"
    "spaceship:Spaceship ZSH:Minimalistic Zsh prompt:Clean design, Git integration, customizable sections"
    "zim:Zim:Modular Zsh framework:Fast startup, modular design, easy to configure"
    "prezto:Prezto:Zsh configuration framework:Sane defaults, extensive modules, well-documented"
  )
  
  local counter=1
  local valid_frameworks=()
  
  for framework in "${AVAILABLE_FRAMEWORKS[@]}"; do
    for desc in "${framework_descriptions[@]}"; do
      IFS=':' read -r fw_name fw_title fw_desc fw_features <<< "$desc"
      if [[ "$fw_name" == "$framework" ]]; then
        printf "\n"
        echo -e "  ${BOLD}$counter) $fw_title${RESET}"
        echo -e "     • $fw_desc"
        echo -e "     • $fw_features"
        echo ""
        valid_frameworks+=("$framework")
        ((counter++))
        break
      fi
    done
  done
  
  read -p "Enter your choice [1-${#valid_frameworks[@]}]: " framework_choice
  
  if [[ "$framework_choice" -ge 1 && "$framework_choice" -le "${#valid_frameworks[@]}" ]]; then
    PROMPT_FRAMEWORK="${valid_frameworks[$((framework_choice-1))]}"
  else
    print_warning "Invalid choice. Defaulting to starship"
    PROMPT_FRAMEWORK="starship"
  fi
  
  # Set theme selection based on framework
  case "$PROMPT_FRAMEWORK" in
    "oh-my-zsh")
      PROMPT_FRAMEWORK="p10k"  # Internal framework name
      select_p10k_template
      ;;
    "starship")
      select_starship_template
      ;;
    *)
      print_info "Selected framework: $PROMPT_FRAMEWORK"
      THEME_TEMPLATE=""
      ;;
  esac
  
  print_success "Framework: $PROMPT_FRAMEWORK"
}

# Function to select Starship template
select_starship_template() {
  local templates_dir="$SCRIPT_DIR/starship_templates"
  
  if [[ ! -d "$templates_dir" ]]; then
    print_warning "Starship templates directory not found. Using default configuration."
    THEME_TEMPLATE=""
    return
  fi
  
  echo ""
  echo "Available Starship themes:"
  local template_files=($(find "$templates_dir" -name "*.toml" -exec basename {} .toml \; 2>/dev/null | sort))
  
  if [[ ${#template_files[@]} -eq 0 ]]; then
    print_warning "No Starship templates found. Using default configuration."
    THEME_TEMPLATE=""
    return
  fi
  
  echo "  0) Default Starship configuration"
  for i in "${!template_files[@]}"; do
    echo "  $((i+1))) ${template_files[i]}"
  done
  
  read -p "Enter choice [0-${#template_files[@]}]: " template_choice
  
  if [[ "$template_choice" -gt 0 && "$template_choice" -le "${#template_files[@]}" ]]; then
    THEME_TEMPLATE="${template_files[$((template_choice-1))]}"
    print_success "Selected theme: $THEME_TEMPLATE"
  else
    print_info "Using default Starship configuration"
    THEME_TEMPLATE=""
  fi
}

# Function to select Powerlevel10k template
select_p10k_template() {
  local templates_dir="$SCRIPT_DIR/p10k_templates"
  
  if [[ ! -d "$templates_dir" ]]; then
    print_warning "Powerlevel10k templates directory not found. Will use p10k configure wizard."
    THEME_TEMPLATE=""
    return
  fi
  
  echo ""
  echo "Available Powerlevel10k themes:"
  local template_files=($(find "$templates_dir" -name "p10k-*.zsh" -exec basename {} .zsh \; 2>/dev/null | sort))
  
  if [[ ${#template_files[@]} -eq 0 ]]; then
    print_warning "No Powerlevel10k templates found. Will use p10k configure wizard."
    THEME_TEMPLATE=""
    return
  fi
  
  echo "  0) Run p10k configure wizard (interactive setup)"
  for i in "${!template_files[@]}"; do
    local template_name="${template_files[i]#p10k-}"
    echo "  $((i+1))) ${template_name}"
  done
  
  read -p "Enter choice [0-${#template_files[@]}]: " template_choice
  
  if [[ "$template_choice" -gt 0 && "$template_choice" -le "${#template_files[@]}" ]]; then
    THEME_TEMPLATE="${template_files[$((template_choice-1))]}"
    print_success "Selected theme: $THEME_TEMPLATE"
  else
    print_info "Will run p10k configure wizard after installation"
    THEME_TEMPLATE=""
  fi
}

# Function to recommend fonts
recommend_fonts() {
  print_header "Font Recommendations"
  
  local recommended_fonts=()
  
  case "$PROMPT_FRAMEWORK" in
    "p10k")
      recommended_fonts=("MesloLGS" "Hack" "FiraCode" "CascadiaCode")
      print_info "For Powerlevel10k, these fonts work excellently:"
      ;;
    "starship")
      recommended_fonts=("JetBrainsMono" "FiraCode" "CascadiaCode" "Hack")
      print_info "For Starship, these fonts provide great symbol support:"
      ;;
    *)
      recommended_fonts=("JetBrainsMono" "FiraCode" "CascadiaCode")
      print_info "For $PROMPT_FRAMEWORK, these fonts are recommended:"
      ;;
  esac
  
  for font in "${recommended_fonts[@]}"; do
    echo "  • $font Nerd Font"
  done
  
  echo ""
  
  # Check if running in WSL and show appropriate message
  if detect_wsl; then
    print_warning "WSL Detected: You're running in Windows Subsystem for Linux"
    print_info "For best results, install fonts on Windows (not in WSL):"
    echo "  1. Download Nerd Fonts from: https://www.nerdfonts.com/"
    echo "  2. Install fonts in Windows (double-click .ttf files)"
    echo "  3. Configure your Windows Terminal to use the installed font"
    echo "  4. The fonts will then work properly in your WSL terminal"
    echo ""
  fi
  
  print_info "Note: Font installation can be done separately using the manage_fonts.sh script"
  print_info "Optional tools can be configured using the manage_optional_tools.sh script"
}

# Function to check and prompt for sudo access
ensure_sudo_access() {
  print_step "Checking sudo access..."
  
  # Skip sudo check in check mode
  if [[ -n "$CHECK_MODE" ]]; then
    print_info "Skipping sudo check in CHECK MODE"
    return 0
  fi
  
  # Check if we're already root
  if [[ $EUID -eq 0 ]]; then
    print_success "Running as root"
    return 0
  fi
  
  # Check if sudo is available without password
  if sudo -n true 2>/dev/null; then
    print_success "Passwordless sudo access confirmed"
    return 0
  fi
  
  # Prompt for sudo password and cache it
  print_info "This script requires sudo access to install packages and configure the system."
  print_info "You will be prompted for your password once."
  
  if sudo -v; then
    print_success "Sudo access confirmed"
    
    # Keep sudo session alive during the script execution
    {
      while true; do
        sleep 30
        sudo -n true 2>/dev/null || break
      done
    } &
    SUDO_KEEPALIVE_PID=$!
    
    # Cleanup function to kill the keepalive process
    trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT
    
    return 0
  else
    print_error "Failed to obtain sudo access. This script requires administrative privileges."
    exit 1
  fi
}

# Function to build and run Ansible command
run_ansible_playbook() {
  print_header "Installing Shell Environment"
  
  # Convert shell name to lowercase for Ansible variables
  local shell_name_lower=$(echo "$SHELL_NAME" | tr '[:upper:]' '[:lower:]')
  
  # Build extra vars as JSON for better handling
  local extra_vars_json="{
    \"preferred_shell\": \"${PREFERRED_SHELL}\",
    \"shell_name\": \"${shell_name_lower}\",
    \"prompt_framework\": \"${PROMPT_FRAMEWORK}\",
    \"setup_mode\": \"${SETUP_MODE}\",
    \"install_${shell_name_lower}\": true"
  
  # Add theme template if selected
  if [[ -n "$THEME_TEMPLATE" ]]; then
    if [[ "$PROMPT_FRAMEWORK" == "p10k" ]]; then
      extra_vars_json+=", \"p10k_template\": \"${THEME_TEMPLATE}\""
    elif [[ "$PROMPT_FRAMEWORK" == "starship" ]]; then
      extra_vars_json+=", \"starship_template\": \"${THEME_TEMPLATE}\""
    fi
  fi
  
  # Add backup directory if created
  if [[ -d "$BACKUP_DIR" ]]; then
    extra_vars_json+=", \"backup_dir\": \"${BACKUP_DIR}\""
  fi
  
  extra_vars_json+="}"
  
  print_info "Configuration summary:"
  print_info "  Shell: $SHELL_NAME ($PREFERRED_SHELL)"
  print_info "  Framework: $PROMPT_FRAMEWORK"
  if [[ -n "$THEME_TEMPLATE" ]]; then
    print_info "  Theme: $THEME_TEMPLATE"
  fi
  print_info "  Setup mode: $SETUP_MODE"
  if [[ -d "$BACKUP_DIR" ]]; then
    print_info "  Backup: $BACKUP_DIR"
  fi
  
  # Refresh sudo timestamp before running Ansible
  if [[ $EUID -ne 0 ]] && [[ -z "$CHECK_MODE" ]]; then
    sudo -v
  fi
  
  # Build Ansible command
  local ansible_cmd="ansible-playbook"
  ansible_cmd+=" -i $SCRIPT_DIR/ansible/inventory/localhost"
  ansible_cmd+=" $SCRIPT_DIR/ansible/custom_dev_env.yml"
  ansible_cmd+=" --extra-vars '$extra_vars_json'"
  
  # Add check mode if specified
  if [[ -n "$CHECK_MODE" ]]; then
    ansible_cmd+=" $CHECK_MODE"
  fi
  
  # Add become flags for sudo - use cached credentials
  if [[ $EUID -ne 0 ]] && [[ -z "$CHECK_MODE" ]]; then
    ansible_cmd+=" --become --become-method=sudo --become-user=root"
    # Don't ask for password since we already cached it
    export ANSIBLE_BECOME_PASS=""
  fi
  
  print_info "Executing Ansible playbook..."
  if [[ -n "$CHECK_MODE" ]]; then
    print_info "Running in CHECK MODE - no changes will be made"
  fi
  
  # Set environment variables for Ansible
  export ANSIBLE_HOST_KEY_CHECKING=False
  export ANSIBLE_STDOUT_CALLBACK=yaml
  
  if eval "$ansible_cmd"; then
    print_success "Ansible playbook completed successfully!"
    return 0
  else
    print_error "Ansible playbook failed. Please check the output above."
    print_info "Backup location (if created): $BACKUP_DIR"
    return 1
  fi
}

# Function to show post-installation instructions
show_completion_message() {
  print_header "Installation Complete!"
  
  print_success "Your $SHELL_NAME environment with $PROMPT_FRAMEWORK has been set up!"
  
  echo ""
  echo "Next steps:"
  echo ""
  
  case "$SHELL_NAME" in
    "Bash")
      echo -e "  1. Restart your terminal or run: ${CYAN}source ~/.bashrc${RESET}"
      ;;
    "Zsh")
      echo -e "  1. Restart your terminal or run: ${CYAN}exec zsh${RESET}"
      if [[ "$PREFERRED_SHELL" != "$(echo $SHELL)" ]]; then
        echo -e "  2. Set Zsh as default: ${CYAN}chsh -s /usr/bin/zsh${RESET}"
      fi
      ;;
    "Fish")
      echo -e "  1. Restart your terminal or run: ${CYAN}exec fish${RESET}"
      if [[ "$PREFERRED_SHELL" != "$(echo $SHELL)" ]]; then
        echo -e "  2. Set Fish as default: ${CYAN}chsh -s /usr/bin/fish${RESET}"
      fi
      ;;
    "Nushell")
      echo -e "  1. Start Nushell: ${CYAN}nu${RESET}"
      echo -e "  2. Consider adding nu to your PATH if not already done"
      ;;
  esac
  
  if [[ "$PROMPT_FRAMEWORK" == "p10k" ]] && [[ -z "$THEME_TEMPLATE" ]]; then
  print_info "Since no Powerlevel10k theme was selected, you can run the configuration wizard:"
    echo -e "  3. Configure Powerlevel10k: ${CYAN}p10k configure${RESET}"
  fi
  
  echo ""
  print_info "Additional configurations available:"
  echo -e "  • Fonts: Run ${CYAN}./manage_fonts.sh${RESET} to install Nerd Fonts"
  echo -e "  • Tools: Run ${CYAN}./manage_optional_tools.sh${RESET} to add development tools"
  echo -e "  • Themes: Check the template directories for more customization options"

  echo ""
  print_success "Enjoy your new shell environment! 🚀"
}

# Main execution flow
main() {
  print_header "Custom Shell Environment Setup"
  
  # Validate OS support
  local os=$(detect_os)
  case "$os" in
    ubuntu|macos)
      print_success "Detected supported OS: $os"
      ;;
    unsupported_ubuntu)
      print_error "Ubuntu version too old. This script requires Ubuntu 20.04 or newer."
      exit 1
      ;;
    *)
      print_error "Unsupported OS. This script supports Ubuntu 20.04+ and macOS only."
      exit 1
      ;;
  esac
  
  # Validate project structure
  validate_project_structure
  
  # Main workflow - simplified to focus only on shell setup
  check_existing_setup
  create_backup
  ensure_sudo_access
  ensure_ansible
  select_shell
  select_framework
  recommend_fonts
  
  if run_ansible_playbook; then
    show_completion_message
  else
    print_error "Installation failed. Please check the errors above and try again."
    if [[ -d "$BACKUP_DIR" ]]; then
      print_info "Your original configurations are backed up at: $BACKUP_DIR"
    fi
    exit 1
  fi
}

# Handle script arguments
case "${1:-}" in
  --help|-h)
    echo "Custom Shell Environment Setup"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h     Show this help message"
    echo "  --check        Run in check mode (show what would be done)"
    echo ""
    echo "Supported:"
    echo "  • Ubuntu 20.04+"
    echo "  • macOS"
    echo ""
    echo "Shells: Bash, Zsh, Fish, Nushell"
    echo "Frameworks: Oh My Zsh, Oh My Posh, Starship, Spaceship, Zim, Prezto"
    exit 0
    ;;
  --check)
    CHECK_MODE="--check"
    print_info "Running in CHECK MODE - no changes will be made"
    ;;
esac

# Run main function
main "$@"