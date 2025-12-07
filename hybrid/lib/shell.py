#!/usr/bin/env python3
"""
Shell Management and Configuration
Handles shell installation, configuration, and framework management
"""

import os
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from .platform import SystemUtils
from .backup import BackupManager

class ShellManager:
    """Manages shell installation and configuration"""
    
    def __init__(self, system_utils: SystemUtils, backup_manager: BackupManager):
        self.system = system_utils
        self.backup = backup_manager
        self.home = Path.home()
        
    def install_shell_prerequisites(self, shell_type: str) -> bool:
        """Install required packages for shell setup"""
        base_packages = ['git', 'curl', 'wget', 'fontconfig', 'unzip']
        
        if shell_type == 'zsh':
            packages = base_packages + ['zsh']
        elif shell_type == 'bash':
            packages = base_packages + ['bash', 'bash-completion']
        else:
            packages = base_packages
        
        return self.system.install_packages(packages)
    
    def install_oh_my_zsh(self) -> bool:
        """Install Oh My Zsh framework"""
        if (self.home / '.oh-my-zsh').exists():
            print("Oh My Zsh already installed")
            return True
        
        try:
            # Install Oh My Zsh non-interactively
            env = os.environ.copy()
            env.update({'RUNZSH': 'no', 'CHSH': 'no'})
            
            self.system.run_command([
                'sh', '-c', 
                'curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh'
            ], shell=True)
            
            return True
        except Exception as e:
            print(f"Failed to install Oh My Zsh: {e}")
            return False
    
    def install_oh_my_posh(self) -> bool:
        """Install Oh My Posh framework"""
        try:
            # Install Oh My Posh
            if not self.system.command_exists('oh-my-posh'):
                # Install using the official script
                self.system.run_command([
                    'curl', '-s', 'https://ohmyposh.dev/install.sh', '|', 'bash', '-s'
                ], shell=True)
                
                # Add to PATH if not already there
                local_bin = self.home / '.local' / 'bin'
                if local_bin.exists() and not str(local_bin) in os.environ.get('PATH', ''):
                    print(f"Added {local_bin} to PATH")
            
            # Download 1_shell theme
            themes_dir = self.home / '.config' / 'oh-my-posh' / 'themes'
            themes_dir.mkdir(parents=True, exist_ok=True)
            
            theme_file = themes_dir / '1_shell.omp.json'
            if not theme_file.exists():
                self.system.run_command([
                    'curl', '-fsSL', 
                    'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json',
                    '-o', str(theme_file)
                ])
            
            return True
        except Exception as e:
            print(f"Failed to install Oh My Posh: {e}")
            return False
    
    def install_starship(self) -> bool:
        """Install Starship prompt"""
        if self.system.command_exists('starship'):
            print("Starship already installed")
            return True
        
        try:
            self.system.run_command([
                'curl', '-sS', 'https://starship.rs/install.sh', '|', 'sh', '-s', '--', '-y'
            ], shell=True)
            return True
        except Exception as e:
            print(f"Failed to install Starship: {e}")
            return False
    
    def install_bash_it(self) -> bool:
        """Install Bash-it framework"""
        bash_it_dir = self.home / '.bash_it'
        
        if bash_it_dir.exists():
            print("Bash-it already installed")
            return True
        
        try:
            self.system.run_command([
                'git', 'clone', '--depth=1', 
                'https://github.com/Bash-it/bash-it.git', 
                str(bash_it_dir)
            ])
            
            # Install silently
            self.system.run_command([
                str(bash_it_dir / 'install.sh'), '--silent'
            ])
            
            return True
        except Exception as e:
            print(f"Failed to install Bash-it: {e}")
            return False
    
    def install_zsh_plugins(self) -> bool:
        """Install useful Zsh plugins"""
        plugins_dir = self.home / '.oh-my-zsh' / 'custom' / 'plugins'
        
        plugins = {
            'zsh-autosuggestions': 'https://github.com/zsh-users/zsh-autosuggestions',
            'zsh-syntax-highlighting': 'https://github.com/zsh-users/zsh-syntax-highlighting.git'
        }
        
        try:
            for plugin, repo in plugins.items():
                plugin_dir = plugins_dir / plugin
                if not plugin_dir.exists():
                    self.system.run_command([
                        'git', 'clone', repo, str(plugin_dir)
                    ])
            return True
        except Exception as e:
            print(f"Failed to install Zsh plugins: {e}")
            return False
    
    def install_powerlevel10k(self) -> bool:
        """Install Powerlevel10k theme for Zsh"""
        theme_dir = self.home / '.oh-my-zsh' / 'custom' / 'themes' / 'powerlevel10k'
        
        if theme_dir.exists():
            print("Powerlevel10k already installed, updating...")
            try:
                self.system.run_command(['git', '-C', str(theme_dir), 'pull'])
            except:
                pass
            return True
        
        try:
            self.system.run_command([
                'git', 'clone', '--depth=1',
                'https://github.com/romkatv/powerlevel10k.git',
                str(theme_dir)
            ])
            return True
        except Exception as e:
            print(f"Failed to install Powerlevel10k: {e}")
            return False
    
    def set_default_shell(self, shell_name: str) -> bool:
        """Set shell as default"""
        shell_path = self.system.get_shell_path(shell_name)
        if not shell_path:
            print(f"Shell {shell_name} not found")
            return False
        
        current_shell = os.environ.get('SHELL', '')
        if current_shell == shell_path:
            print(f"{shell_name} is already the default shell")
            return True
        
        try:
            self.system.run_command(['chsh', '-s', shell_path])
            print(f"Default shell changed to {shell_name}")
            print("Please restart your terminal for the change to take effect")
            return True
        except Exception:
            print(f"Could not change default shell automatically")
            print(f"Please run manually: chsh -s {shell_path}")
            return False
    
    def get_available_shells(self) -> List[str]:
        """Get list of available shells"""
        shells = []
        common_shells = ['bash', 'zsh', 'fish', 'sh']
        
        for shell in common_shells:
            if self.system.command_exists(shell):
                shells.append(shell)
        
        return shells
    
    def detect_current_shell(self) -> str:
        """Detect currently running shell"""
        shell = os.environ.get('SHELL', '/bin/bash')
        return Path(shell).name