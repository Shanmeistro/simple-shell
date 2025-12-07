#!/usr/bin/env python3
"""
Main Shell Environment Installer
Orchestrates the entire installation process
"""

import sys
from pathlib import Path
from typing import Dict, List, Optional
from .platform import PlatformDetector, SystemUtils
from .shell import ShellManager
from .fonts import FontManager
from .backup import BackupManager
from .templates import ConfigTemplates

class Colors:
    """ANSI color codes for terminal output"""
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    RED = '\033[31m'
    BLUE = '\033[34m'
    CYAN = '\033[36m'
    BOLD = '\033[1m'
    RESET = '\033[0m'

class SimpleShellInstaller:
    """Main installer class for shell environment setup"""
    
    def __init__(self):
        # Initialize components
        self.platform_detector = PlatformDetector()
        self.platform_info = self.platform_detector.get_info()
        
        if not self.platform_detector.is_supported():
            self.print_error(f"Unsupported platform: {self.platform_info['type']}")
            sys.exit(1)
        
        self.system = SystemUtils(self.platform_info)
        self.backup = BackupManager()
        self.shell_manager = ShellManager(self.system, self.backup)
        self.font_manager = FontManager(self.system)
        self.templates = ConfigTemplates()
        
        self.home = Path.home()
    
    def print_header(self, text: str):
        """Print formatted header"""
        print(f"\n{Colors.BOLD}{Colors.BLUE}======================================{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.CYAN}  {text}{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.BLUE}======================================{Colors.RESET}\n")
    
    def print_success(self, text: str):
        """Print success message"""
        print(f"{Colors.GREEN}✓ {text}{Colors.RESET}")
    
    def print_error(self, text: str):
        """Print error message"""
        print(f"{Colors.RED}✗ {text}{Colors.RESET}")
    
    def print_info(self, text: str):
        """Print info message"""
        print(f"{Colors.BLUE}ℹ {text}{Colors.RESET}")
    
    def print_warning(self, text: str):
        """Print warning message"""
        print(f"{Colors.YELLOW}⚠ {text}{Colors.RESET}")
    
    def setup_shell_environment(self, config: Dict) -> bool:
        """Main setup method based on user configuration"""
        self.print_header("Shell Environment Setup")
        
        print(f"Platform: {self.platform_info['type'].upper()} ({self.platform_info['os']})")
        print(f"Package Manager: {self.platform_info['package_manager']}")
        print(f"Target Shell: {config.get('shell', 'bash')}")
        print(f"Framework: {config.get('framework', 'none')}")
        print(f"Prompt: {config.get('prompt', 'default')}")
        print()
        
        try:
            # Step 1: Backup existing configurations
            if config.get('backup', True):
                self.backup_existing_configs(config['shell'])
            
            # Step 2: Install shell and prerequisites
            self.install_shell_prerequisites(config['shell'])
            
            # Step 3: Install framework if requested
            if config.get('framework') and config['framework'] != 'none':
                self.install_framework(config['shell'], config['framework'])
            
            # Step 4: Install prompt if requested
            if config.get('prompt') and config['prompt'] != 'default':
                self.install_prompt(config['prompt'])
            
            # Step 5: Install fonts
            if config.get('install_fonts', True):
                self.install_fonts(config.get('prompt', 'basic'))
            
            # Step 6: Generate and write configuration files
            self.create_shell_configuration(config)
            
            # Step 7: Set as default shell if requested
            if config.get('set_default', True):
                self.shell_manager.set_default_shell(config['shell'])
            
            self.print_header("Installation Complete!")
            self.print_installation_summary(config)
            return True
            
        except Exception as e:
            self.print_error(f"Installation failed: {e}")
            return False
    
    def backup_existing_configs(self, shell_type: str):
        """Backup existing shell configurations"""
        self.print_header("Creating Backup")
        backup_dir = self.backup.backup_shell_configs(shell_type)
        if backup_dir:
            self.print_success(f"Backup created: {backup_dir}")
    
    def install_shell_prerequisites(self, shell_type: str):
        """Install shell and basic prerequisites"""
        self.print_header(f"Installing {shell_type.title()} Prerequisites")
        
        if self.shell_manager.install_shell_prerequisites(shell_type):
            self.print_success(f"{shell_type.title()} and prerequisites installed")
        else:
            raise Exception(f"Failed to install {shell_type} prerequisites")
    
    def install_framework(self, shell_type: str, framework: str):
        """Install shell framework"""
        self.print_header(f"Installing {framework.title()} Framework")
        
        success = False
        
        if shell_type == 'zsh':
            if framework == 'oh-my-zsh':
                success = self.shell_manager.install_oh_my_zsh()
                if success:
                    success = self.shell_manager.install_zsh_plugins()
        
        elif shell_type == 'bash':
            if framework == 'bash-it':
                success = self.shell_manager.install_bash_it()
        
        if success:
            self.print_success(f"{framework.title()} framework installed")
        else:
            self.print_warning(f"Framework installation had issues, continuing...")
    
    def install_prompt(self, prompt_type: str):
        """Install prompt system"""
        self.print_header(f"Installing {prompt_type.title()} Prompt")
        
        success = False
        
        if prompt_type == 'powerlevel10k':
            success = self.shell_manager.install_powerlevel10k()
        elif prompt_type == 'starship':
            success = self.shell_manager.install_starship()
        elif prompt_type == 'oh-my-posh':
            success = self.shell_manager.install_oh_my_posh()
        
        if success:
            self.print_success(f"{prompt_type.title()} prompt installed")
        else:
            self.print_warning(f"Prompt installation had issues, continuing...")
    
    def install_fonts(self, prompt_type: str):
        """Install appropriate fonts"""
        self.print_header("Installing Fonts")
        
        success = False
        
        if prompt_type == 'powerlevel10k':
            success = self.font_manager.install_meslo_fonts()
        elif prompt_type in ['starship', 'oh-my-posh']:
            success = self.font_manager.install_nerd_fonts(['FiraCode', 'JetBrainsMono'])
        else:
            # Install basic Nerd Fonts for general use
            success = self.font_manager.install_nerd_fonts(['Hack'])
        
        if success:
            self.print_success("Fonts installed")
            if self.platform_info['type'] == 'wsl2':
                self.print_info("Set your Windows Terminal font to a Nerd Font for best experience")
        else:
            self.print_warning("Font installation had issues, continuing...")
    
    def create_shell_configuration(self, config: Dict):
        """Create shell configuration files"""
        self.print_header("Creating Configuration")
        
        shell_type = config['shell']
        framework = config.get('framework', 'none')
        prompt = config.get('prompt', 'default')
        
        if shell_type == 'zsh':
            # Create .zshrc
            zshrc_content = self.templates.get_zsh_config(framework)
            if self.templates.write_config(self.home / '.zshrc', zshrc_content):
                self.print_success("Created .zshrc configuration")
            
            # Create .p10k.zsh if using powerlevel10k
            if prompt == 'powerlevel10k':
                p10k_content = self.templates.get_p10k_config()
                if self.templates.write_config(self.home / '.p10k.zsh', p10k_content):
                    self.print_success("Created .p10k.zsh configuration")
        
        elif shell_type == 'bash':
            # Create .bashrc
            bashrc_content = self.templates.get_bash_config(framework if framework != 'none' else prompt)
            if self.templates.write_config(self.home / '.bashrc', bashrc_content):
                self.print_success("Created .bashrc configuration")
        
        # Create starship config if using starship
        if prompt == 'starship':
            starship_content = self.templates.get_starship_config()
            config_dir = self.home / '.config'
            if self.templates.write_config(config_dir / 'starship.toml', starship_content):
                self.print_success("Created starship configuration")
    
    def print_installation_summary(self, config: Dict):
        """Print installation summary and next steps"""
        shell_type = config['shell']
        framework = config.get('framework', 'none')
        prompt = config.get('prompt', 'default')
        
        print(f"🎉 Your {shell_type.title()} environment is ready!")
        print()
        
        print("Installed components:")
        print(f"  • Shell: {shell_type.title()}")
        if framework != 'none':
            print(f"  • Framework: {framework.title()}")
        if prompt != 'default':
            print(f"  • Prompt: {prompt.title()}")
        print(f"  • Fonts: Nerd Fonts installed")
        print()
        
        print("Next steps:")
        print(f"1. Restart your terminal or run: exec {shell_type}")
        
        if self.platform_info['type'] == 'wsl2':
            print("2. Set your Windows Terminal font to a Nerd Font")
            print("3. Restart Windows Terminal for best experience")
        else:
            print("2. Configure your terminal to use a Nerd Font")
        
        if prompt == 'powerlevel10k':
            print("3. (Optional) Customize Powerlevel10k: p10k configure")
        elif prompt == 'starship':
            print("3. (Optional) Customize Starship: edit ~/.config/starship.toml")
        elif prompt == 'oh-my-posh':
            print("3. (Optional) Try different Oh My Posh themes in ~/.config/oh-my-posh/themes/")
        
        print()
        print("📚 Useful commands:")
        if shell_type == 'zsh' and framework == 'oh-my-zsh':
            print("  • Update Oh My Zsh: omz update")
            print("  • List plugins: omz plugin list")
        if shell_type == 'bash' and framework == 'bash-it':
            print("  • Bash-it help: bash-it help")
            print("  • Show themes: bash-it show themes")
        
        if self.platform_info['type'] == 'wsl2':
            print("  • Get WSL IP: wsl-ip")
            print("  • Open Windows Explorer: open .")
            print("  • Launch VS Code: code .")