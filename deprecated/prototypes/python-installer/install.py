#!/usr/bin/env python3
"""
Simple Shell Environment Setup - Python Edition
A simplified, cross-platform shell environment installer

Supports:
- Platforms: WSL2 Ubuntu, Native Linux, macOS
- Shell: Zsh with Oh My Zsh + Powerlevel10k
- Fonts: Recommended P10k fonts
"""

import os
import sys
import shutil
import subprocess
import platform
import json
from pathlib import Path
from datetime import datetime
from urllib.request import urlretrieve
from urllib.error import URLError

# Color constants for output
class Colors:
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    RED = '\033[31m'
    BLUE = '\033[34m'
    CYAN = '\033[36m'
    BOLD = '\033[1m'
    RESET = '\033[0m'

class SimpleShellInstaller:
    def __init__(self):
        self.script_dir = Path(__file__).parent
        self.home_dir = Path.home()
        self.config_dir = self.home_dir / '.config'
        self.backup_dir = self.home_dir / f'.config/shell-backup-{datetime.now().strftime("%Y%m%d-%H%M%S")}'
        self.platform_info = self._detect_platform()
        
    def _detect_platform(self):
        """Detect the current platform and environment"""
        system = platform.system().lower()
        is_wsl = os.path.exists('/proc/version') and 'microsoft' in open('/proc/version').read().lower()
        
        if system == 'linux':
            if is_wsl:
                return {'type': 'wsl2', 'os': 'ubuntu', 'package_manager': 'apt'}
            else:
                # Detect Linux distribution
                if shutil.which('apt'):
                    return {'type': 'linux', 'os': 'ubuntu', 'package_manager': 'apt'}
                elif shutil.which('dnf'):
                    return {'type': 'linux', 'os': 'fedora', 'package_manager': 'dnf'}
                else:
                    return {'type': 'linux', 'os': 'unknown', 'package_manager': 'unknown'}
        elif system == 'darwin':
            return {'type': 'macos', 'os': 'macos', 'package_manager': 'brew'}
        else:
            return {'type': 'unsupported', 'os': system, 'package_manager': 'unknown'}

    def print_header(self, message):
        """Print a formatted header"""
        print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.CYAN}  {message}{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}\n")

    def print_step(self, message):
        """Print a step message"""
        print(f"\n{Colors.BLUE}==> {Colors.CYAN}{message}{Colors.RESET}")

    def print_success(self, message):
        """Print a success message"""
        print(f"{Colors.GREEN}✓{Colors.RESET} {message}")

    def print_warning(self, message):
        """Print a warning message"""
        print(f"{Colors.YELLOW}⚠{Colors.RESET} {message}")

    def print_error(self, message):
        """Print an error message"""
        print(f"{Colors.RED}✗{Colors.RESET} {message}")

    def run_command(self, command, check=True, capture_output=False):
        """Run a shell command with error handling"""
        try:
            if isinstance(command, str):
                result = subprocess.run(command, shell=True, check=check, 
                                      capture_output=capture_output, text=True)
            else:
                result = subprocess.run(command, check=check, 
                                      capture_output=capture_output, text=True)
            return result
        except subprocess.CalledProcessError as e:
            self.print_error(f"Command failed: {command}")
            if capture_output:
                self.print_error(f"Error output: {e.stderr}")
            return None

    def backup_existing_configs(self):
        """Backup existing shell configurations"""
        self.print_step("Backing up existing configurations")
        
        configs_to_backup = [
            ('.zshrc', self.home_dir / '.zshrc'),
            ('.p10k.zsh', self.home_dir / '.p10k.zsh'),
            ('oh-my-zsh', self.home_dir / '.oh-my-zsh'),
        ]
        
        backed_up = []
        for name, path in configs_to_backup:
            if path.exists():
                self.backup_dir.mkdir(parents=True, exist_ok=True)
                if path.is_dir():
                    shutil.copytree(path, self.backup_dir / name, dirs_exist_ok=True)
                else:
                    shutil.copy2(path, self.backup_dir / name)
                backed_up.append(name)
        
        if backed_up:
            self.print_success(f"Backed up: {', '.join(backed_up)}")
            self.print_warning(f"Backup location: {self.backup_dir}")
        else:
            self.print_success("No existing configurations found to backup")

    def install_dependencies(self):
        """Install required system dependencies"""
        self.print_step("Installing system dependencies")
        
        if self.platform_info['package_manager'] == 'apt':
            # Update package list
            self.run_command(['sudo', 'apt', 'update'])
            
            packages = ['zsh', 'curl', 'git', 'fontconfig']
            cmd = ['sudo', 'apt', 'install', '-y'] + packages
            
        elif self.platform_info['package_manager'] == 'brew':
            # Ensure Homebrew is installed
            if not shutil.which('brew'):
                self.print_error("Homebrew not found. Please install it first:")
                self.print_error("https://brew.sh")
                sys.exit(1)
            
            packages = ['zsh', 'git']
            cmd = ['brew', 'install'] + packages
            
        elif self.platform_info['package_manager'] == 'dnf':
            packages = ['zsh', 'curl', 'git', 'fontconfig']
            cmd = ['sudo', 'dnf', 'install', '-y'] + packages
        else:
            self.print_error(f"Unsupported package manager: {self.platform_info['package_manager']}")
            return False
        
        result = self.run_command(cmd)
        if result:
            self.print_success("System dependencies installed")
            return True
        return False

    def install_oh_my_zsh(self):
        """Install Oh My Zsh"""
        self.print_step("Installing Oh My Zsh")
        
        omz_path = self.home_dir / '.oh-my-zsh'
        if omz_path.exists():
            self.print_warning("Oh My Zsh already exists, removing old installation")
            shutil.rmtree(omz_path)
        
        # Download and install Oh My Zsh
        install_script = "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
        result = self.run_command(install_script)
        
        if result and omz_path.exists():
            self.print_success("Oh My Zsh installed successfully")
            return True
        else:
            self.print_error("Failed to install Oh My Zsh")
            return False

    def install_powerlevel10k(self):
        """Install Powerlevel10k theme"""
        self.print_step("Installing Powerlevel10k theme")
        
        p10k_path = self.home_dir / '.oh-my-zsh/custom/themes/powerlevel10k'
        
        if p10k_path.exists():
            self.print_warning("Powerlevel10k already exists, updating...")
            result = self.run_command(['git', '-C', str(p10k_path), 'pull'], check=False)
        else:
            clone_url = "https://github.com/romkatv/powerlevel10k.git"
            result = self.run_command(['git', 'clone', '--depth=1', clone_url, str(p10k_path)])
        
        if result:
            self.print_success("Powerlevel10k installed successfully")
            return True
        else:
            self.print_error("Failed to install Powerlevel10k")
            return False

    def install_p10k_fonts(self):
        """Install recommended Powerlevel10k fonts"""
        self.print_step("Installing Powerlevel10k fonts")
        
        fonts = [
            {
                'name': 'MesloLGS NF Regular',
                'url': 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf',
                'filename': 'MesloLGS NF Regular.ttf'
            },
            {
                'name': 'MesloLGS NF Bold',
                'url': 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf',
                'filename': 'MesloLGS NF Bold.ttf'
            },
            {
                'name': 'MesloLGS NF Italic',
                'url': 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf',
                'filename': 'MesloLGS NF Italic.ttf'
            },
            {
                'name': 'MesloLGS NF Bold Italic',
                'url': 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf',
                'filename': 'MesloLGS NF Bold Italic.ttf'
            }
        ]
        
        # Determine font directory based on platform
        if self.platform_info['type'] in ['linux', 'wsl2']:
            font_dir = self.home_dir / '.local/share/fonts'
        elif self.platform_info['type'] == 'macos':
            font_dir = self.home_dir / 'Library/Fonts'
        else:
            self.print_error("Unsupported platform for font installation")
            return False
        
        font_dir.mkdir(parents=True, exist_ok=True)
        
        installed_fonts = []
        for font in fonts:
            font_path = font_dir / font['filename']
            if not font_path.exists():
                try:
                    self.print_step(f"Downloading {font['name']}")
                    urlretrieve(font['url'], font_path)
                    installed_fonts.append(font['name'])
                except URLError as e:
                    self.print_error(f"Failed to download {font['name']}: {e}")
            else:
                self.print_warning(f"{font['name']} already exists")
        
        if installed_fonts:
            # Refresh font cache on Linux
            if self.platform_info['type'] in ['linux', 'wsl2']:
                self.run_command(['fc-cache', '-fv'], check=False)
            
            self.print_success(f"Installed {len(installed_fonts)} fonts")
            return True
        else:
            self.print_warning("No new fonts were installed")
            return True

    def configure_zsh(self):
        """Configure Zsh with Oh My Zsh and Powerlevel10k"""
        self.print_step("Configuring Zsh")
        
        # Read template or create basic configuration
        zshrc_content = self._get_zshrc_template()
        p10k_content = self._get_p10k_template()
        
        # Write .zshrc
        zshrc_path = self.home_dir / '.zshrc'
        with open(zshrc_path, 'w') as f:
            f.write(zshrc_content)
        
        # Write .p10k.zsh
        p10k_path = self.home_dir / '.p10k.zsh'
        with open(p10k_path, 'w') as f:
            f.write(p10k_content)
        
        self.print_success("Zsh configuration files created")
        return True

    def _get_zshrc_template(self):
        """Get the .zshrc template content"""
        return '''# Simple Shell Environment - Zsh Configuration
# Generated by simple-shell installer

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='vim'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Custom functions
mkcd() { mkdir -p "$1" && cd "$1"; }

# Platform-specific configurations
case "$OSTYPE" in
  linux*)
    # Linux-specific settings
    ;;
  darwin*)
    # macOS-specific settings
    if command -v brew >/dev/null 2>&1; then
      export PATH="/opt/homebrew/bin:$PATH"
    fi
    ;;
  msys*|cygwin*)
    # Windows/WSL-specific settings
    ;;
esac

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
'''

    def _get_p10k_template(self):
        """Get a basic P10k configuration template"""
        return '''# Simple Shell Environment - Powerlevel10k Configuration
# Generated by simple-shell installer

# Temporarily change options
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required
  autoload -Uz is-at-least && is-at-least 5.1 || return

  # Basic configuration
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                     # current directory
    vcs                     # git status
    prompt_char             # prompt symbol
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of the last command
    command_execution_time  # duration of the last command
    background_jobs         # presence of background jobs
    time                    # current time
  )

  # Basic styling
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND=196
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=31
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=39

  # Instant prompt mode
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
}

# Restore previous options
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
'''

    def set_default_shell(self):
        """Set Zsh as the default shell"""
        self.print_step("Setting Zsh as default shell")
        
        current_shell = os.environ.get('SHELL', '')
        zsh_path = shutil.which('zsh')
        
        if not zsh_path:
            self.print_error("Zsh not found in PATH")
            return False
        
        if current_shell == zsh_path:
            self.print_success("Zsh is already the default shell")
            return True
        
        try:
            # Change default shell
            result = self.run_command(['chsh', '-s', zsh_path], check=False)
            if result and result.returncode == 0:
                self.print_success(f"Default shell changed to: {zsh_path}")
                self.print_warning("Please log out and log back in for the change to take effect")
                return True
            else:
                self.print_warning(f"Could not change default shell automatically")
                self.print_warning(f"Please run manually: chsh -s {zsh_path}")
                return True
        except Exception as e:
            self.print_error(f"Error changing default shell: {e}")
            return False

    def install_zsh_plugins(self):
        """Install useful Zsh plugins"""
        self.print_step("Installing Zsh plugins")
        
        plugins = [
            {
                'name': 'zsh-autosuggestions',
                'url': 'https://github.com/zsh-users/zsh-autosuggestions',
                'path': self.home_dir / '.oh-my-zsh/custom/plugins/zsh-autosuggestions'
            },
            {
                'name': 'zsh-syntax-highlighting',
                'url': 'https://github.com/zsh-users/zsh-syntax-highlighting.git',
                'path': self.home_dir / '.oh-my-zsh/custom/plugins/zsh-syntax-highlighting'
            }
        ]
        
        installed = []
        for plugin in plugins:
            if plugin['path'].exists():
                self.print_warning(f"{plugin['name']} already exists, updating...")
                result = self.run_command(['git', '-C', str(plugin['path']), 'pull'], check=False)
            else:
                result = self.run_command(['git', 'clone', plugin['url'], str(plugin['path'])])
            
            if result:
                installed.append(plugin['name'])
        
        if installed:
            self.print_success(f"Installed plugins: {', '.join(installed)}")
        return True

    def show_completion_message(self):
        """Show installation completion message"""
        self.print_header("Installation Complete!")
        
        print(f"{Colors.GREEN}✓ Platform: {self.platform_info['type'].upper()} ({self.platform_info['os']}){Colors.RESET}")
        print(f"{Colors.GREEN}✓ Shell: Zsh with Oh My Zsh{Colors.RESET}")
        print(f"{Colors.GREEN}✓ Theme: Powerlevel10k{Colors.RESET}")
        print(f"{Colors.GREEN}✓ Fonts: MesloLGS NF fonts installed{Colors.RESET}")
        print(f"{Colors.GREEN}✓ Plugins: autosuggestions, syntax-highlighting{Colors.RESET}")
        
        if self.backup_dir.exists():
            print(f"\n{Colors.YELLOW}📁 Backups saved to: {self.backup_dir}{Colors.RESET}")
        
        print(f"\n{Colors.CYAN}🔄 To apply changes:{Colors.RESET}")
        print(f"   exec zsh")
        print(f"\n{Colors.CYAN}🎨 To configure Powerlevel10k:{Colors.RESET}")
        print(f"   p10k configure")
        
        if self.platform_info['type'] == 'wsl2':
            print(f"\n{Colors.YELLOW}📝 WSL2 Note:{Colors.RESET}")
            print(f"   Set your terminal font to 'MesloLGS NF' for best experience")

    def run_installation(self):
        """Run the complete installation process"""
        self.print_header("Simple Shell Environment Installer")
        
        print(f"Platform detected: {Colors.CYAN}{self.platform_info['type'].upper()}{Colors.RESET} "
              f"({self.platform_info['os']})")
        
        if self.platform_info['type'] == 'unsupported':
            self.print_error("Unsupported platform")
            sys.exit(1)
        
        # Check for Python version
        if sys.version_info < (3, 6):
            self.print_error("Python 3.6 or higher required")
            sys.exit(1)
        
        steps = [
            ("Backup existing configurations", self.backup_existing_configs),
            ("Install system dependencies", self.install_dependencies),
            ("Install Oh My Zsh", self.install_oh_my_zsh),
            ("Install Powerlevel10k", self.install_powerlevel10k),
            ("Install Zsh plugins", self.install_zsh_plugins),
            ("Install fonts", self.install_p10k_fonts),
            ("Configure Zsh", self.configure_zsh),
            ("Set default shell", self.set_default_shell),
        ]
        
        for step_name, step_func in steps:
            try:
                if not step_func():
                    self.print_error(f"Failed: {step_name}")
                    response = input(f"\n{Colors.YELLOW}Continue anyway? (y/n): {Colors.RESET}")
                    if response.lower() not in ['y', 'yes']:
                        sys.exit(1)
            except KeyboardInterrupt:
                self.print_error("\nInstallation cancelled by user")
                sys.exit(1)
            except Exception as e:
                self.print_error(f"Unexpected error in {step_name}: {e}")
                response = input(f"\n{Colors.YELLOW}Continue anyway? (y/n): {Colors.RESET}")
                if response.lower() not in ['y', 'yes']:
                    sys.exit(1)
        
        self.show_completion_message()

def main():
    """Main entry point"""
    if len(sys.argv) > 1 and sys.argv[1] in ['-h', '--help']:
        print("""
Simple Shell Environment Installer (Python Edition)

Usage: python3 install.py

This installer will:
- Install Zsh, Oh My Zsh, and Powerlevel10k
- Install recommended MesloLGS NF fonts
- Configure Zsh with useful plugins
- Backup existing configurations
- Set Zsh as default shell

Supported platforms: WSL2 Ubuntu, Native Linux, macOS
        """)
        sys.exit(0)
    
    installer = SimpleShellInstaller()
    installer.run_installation()

if __name__ == "__main__":
    main()