"""
Main installer class with shared functionality
"""

import os
import sys
import shutil
import subprocess
import platform
from pathlib import Path
from datetime import datetime
from urllib.request import urlretrieve
from urllib.error import URLError

from .platform import PlatformDetector, SystemUtils
from .shell import ShellManager
from .fonts import FontManager
from .backup import BackupManager
from .templates import Templates

class SimpleShellInstaller:
    """Main installer class with all functionality"""
    
    class Colors:
        GREEN = '\033[32m'
        YELLOW = '\033[33m'
        RED = '\033[31m'
        BLUE = '\033[34m'
        CYAN = '\033[36m'
        BOLD = '\033[1m'
        RESET = '\033[0m'
    
    def __init__(self):
        self.script_dir = Path(__file__).parent.parent
        self.home_dir = Path.home()
        self.config_dir = self.home_dir / '.config'
        
        # Initialize components
        self.platform_detector = PlatformDetector()
        self.platform_info = self.platform_detector.info
        self.shell_manager = ShellManager(self.home_dir)
        self.font_manager = FontManager(self.platform_info)
        self.backup_manager = BackupManager(self.home_dir)
        
    def print_header(self, message):
        """Print a formatted header"""
        print(f"\n{self.Colors.BOLD}{self.Colors.BLUE}{'='*60}{self.Colors.RESET}")
        print(f"{self.Colors.BOLD}{self.Colors.CYAN}  {message}{self.Colors.RESET}")
        print(f"{self.Colors.BOLD}{self.Colors.BLUE}{'='*60}{self.Colors.RESET}\n")

    def print_step(self, message):
        """Print a step message"""
        print(f"\n{self.Colors.BLUE}==> {self.Colors.CYAN}{message}{self.Colors.RESET}")

    def print_success(self, message):
        """Print a success message"""
        print(f"{self.Colors.GREEN}✓{self.Colors.RESET} {message}")

    def print_warning(self, message):
        """Print a warning message"""
        print(f"{self.Colors.YELLOW}⚠{self.Colors.RESET} {message}")

    def print_error(self, message):
        """Print an error message"""
        print(f"{self.Colors.RED}✗{self.Colors.RESET} {message}")
    
    def backup_existing_configs(self):
        """Backup existing shell configurations"""
        self.print_step("Backing up existing configurations")
        
        result = self.backup_manager.create_backup()
        
        if result['backed_up']:
            self.print_success(f"Backed up: {', '.join(result['backed_up'])}")
            if result['backup_dir']:
                self.print_warning(f"Backup location: {result['backup_dir']}")
        else:
            self.print_success("No existing configurations found to backup")
        
        if result['errors']:
            for error in result['errors']:
                self.print_warning(f"Backup warning: {error}")
        
        return result['success']
    
    def install_dependencies(self):
        """Install required system dependencies"""
        self.print_step("Installing system dependencies")
        
        # Update package lists
        update_cmd = self.platform_detector.get_update_command()
        if update_cmd:
            SystemUtils.run_command(update_cmd)
        
        # Install packages
        packages = self.platform_detector.get_required_packages()
        install_cmd = self.platform_detector.get_install_command(packages)
        
        if not install_cmd:
            self.print_error(f"Unsupported package manager: {self.platform_info['package_manager']}")
            return False
        
        # Special handling for Homebrew
        if self.platform_detector.needs_homebrew_check():
            if not SystemUtils.command_exists('brew'):
                self.print_error("Homebrew not found. Please install it first:")
                self.print_error("https://brew.sh")
                return False
        
        result = SystemUtils.run_command(install_cmd)
        if result:
            self.print_success("System dependencies installed")
            return True
        return False
    
    def install_oh_my_zsh(self):
        """Install Oh My Zsh"""
        self.print_step("Installing Oh My Zsh")
        success, message = self.shell_manager.install_oh_my_zsh()
        if success:
            self.print_success(message)
        else:
            self.print_error(message)
        return success
    
    def install_powerlevel10k(self):
        """Install Powerlevel10k theme"""
        self.print_step("Installing Powerlevel10k theme")
        success, message = self.shell_manager.install_powerlevel10k()
        if success:
            self.print_success(message)
        else:
            self.print_error(message)
        return success
    
    def install_zsh_plugins(self):
        """Install useful Zsh plugins"""
        self.print_step("Installing Zsh plugins")
        success, message = self.shell_manager.install_zsh_plugins()
        if success:
            self.print_success(message)
        else:
            self.print_error(message)
        return success
    
    def install_p10k_fonts(self):
        """Install recommended Powerlevel10k fonts"""
        self.print_step("Installing Powerlevel10k fonts")
        success, message = self.font_manager.install_fonts()
        if success:
            self.print_success(message)
        else:
            self.print_error(message)
        return success
    
    def configure_zsh(self):
        """Configure Zsh with templates"""
        self.print_step("Configuring Zsh")
        
        zshrc_template = Templates.get_zshrc()
        p10k_template = Templates.get_p10k_config()
        
        success1, msg1 = self.shell_manager.create_zshrc(zshrc_template)
        success2, msg2 = self.shell_manager.create_p10k_config(p10k_template)
        
        if success1 and success2:
            self.print_success("Zsh configuration files created")
            return True
        else:
            if not success1:
                self.print_error(msg1)
            if not success2:
                self.print_error(msg2)
            return False
    
    def set_default_shell(self):
        """Set Zsh as the default shell"""
        self.print_step("Setting Zsh as default shell")
        success, message = self.shell_manager.set_default_shell()
        
        if success:
            self.print_success(message)
            if "manually" in message:
                self.print_warning("Manual shell change required")
        else:
            self.print_error(message)
        
        return success
    
    def show_completion_message(self):
        """Show installation completion message"""
        self.print_header("Installation Complete!")
        
        print(f"{self.Colors.GREEN}✓ Platform: {self.platform_info['type'].upper()} ({self.platform_info['os']}){self.Colors.RESET}")
        print(f"{self.Colors.GREEN}✓ Shell: Zsh with Oh My Zsh{self.Colors.RESET}")
        print(f"{self.Colors.GREEN}✓ Theme: Powerlevel10k{self.Colors.RESET}")
        print(f"{self.Colors.GREEN}✓ Fonts: MesloLGS NF fonts installed{self.Colors.RESET}")
        print(f"{self.Colors.GREEN}✓ Plugins: autosuggestions, syntax-highlighting{self.Colors.RESET}")
        
        if self.backup_manager.backup_dir.exists():
            print(f"\n{self.Colors.YELLOW}📁 Backups saved to: {self.backup_manager.backup_dir}{self.Colors.RESET}")
        
        print(f"\n{self.Colors.CYAN}🔄 To apply changes:{self.Colors.RESET}")
        print(f"   exec zsh")
        print(f"\n{self.Colors.CYAN}🎨 To configure Powerlevel10k:{self.Colors.RESET}")
        print(f"   p10k configure")
        
        # Show platform-specific font instructions
        font_instructions = self.font_manager.get_font_instructions()
        if font_instructions:
            print(f"\n{self.Colors.CYAN}🔤 Font Configuration:{self.Colors.RESET}")
            for instruction in font_instructions:
                print(f"   {instruction}")
    
    def run_installation(self):
        """Run the complete installation process - to be overridden by subclasses"""
        raise NotImplementedError("Subclasses must implement run_installation")