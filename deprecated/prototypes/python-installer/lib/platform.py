"""
Platform detection and system utilities
"""

import os
import platform
import shutil
import subprocess
from pathlib import Path

class PlatformDetector:
    """Detect platform and provide platform-specific configurations"""
    
    def __init__(self):
        self.info = self._detect_platform()
    
    def _detect_platform(self):
        """Detect the current platform and environment"""
        system = platform.system().lower()
        is_wsl = os.path.exists('/proc/version') and 'microsoft' in open('/proc/version').read().lower()
        
        if system == 'linux':
            if is_wsl:
                return {
                    'type': 'wsl2',
                    'os': 'ubuntu',
                    'package_manager': 'apt',
                    'font_dir': Path.home() / '.local/share/fonts',
                    'supports_chsh': True,
                    'needs_font_cache': True
                }
            else:
                # Detect Linux distribution
                if shutil.which('apt'):
                    return {
                        'type': 'linux',
                        'os': 'ubuntu',
                        'package_manager': 'apt',
                        'font_dir': Path.home() / '.local/share/fonts',
                        'supports_chsh': True,
                        'needs_font_cache': True
                    }
                elif shutil.which('dnf'):
                    return {
                        'type': 'linux',
                        'os': 'fedora',
                        'package_manager': 'dnf',
                        'font_dir': Path.home() / '.local/share/fonts',
                        'supports_chsh': True,
                        'needs_font_cache': True
                    }
                else:
                    return {
                        'type': 'linux',
                        'os': 'unknown',
                        'package_manager': 'unknown',
                        'font_dir': Path.home() / '.local/share/fonts',
                        'supports_chsh': True,
                        'needs_font_cache': True
                    }
        elif system == 'darwin':
            return {
                'type': 'macos',
                'os': 'macos',
                'package_manager': 'brew',
                'font_dir': Path.home() / 'Library/Fonts',
                'supports_chsh': True,
                'needs_font_cache': False
            }
        else:
            return {
                'type': 'unsupported',
                'os': system,
                'package_manager': 'unknown',
                'font_dir': None,
                'supports_chsh': False,
                'needs_font_cache': False
            }
    
    def get_required_packages(self):
        """Get platform-specific required packages"""
        if self.info['package_manager'] == 'apt':
            return ['zsh', 'curl', 'git', 'fontconfig']
        elif self.info['package_manager'] == 'brew':
            return ['zsh', 'git']
        elif self.info['package_manager'] == 'dnf':
            return ['zsh', 'curl', 'git', 'fontconfig']
        else:
            return []
    
    def get_install_command(self, packages):
        """Get the command to install packages"""
        if self.info['package_manager'] == 'apt':
            return ['sudo', 'apt', 'install', '-y'] + packages
        elif self.info['package_manager'] == 'brew':
            return ['brew', 'install'] + packages
        elif self.info['package_manager'] == 'dnf':
            return ['sudo', 'dnf', 'install', '-y'] + packages
        else:
            return None
    
    def get_update_command(self):
        """Get the command to update package lists"""
        if self.info['package_manager'] == 'apt':
            return ['sudo', 'apt', 'update']
        elif self.info['package_manager'] == 'brew':
            return ['brew', 'update']
        elif self.info['package_manager'] == 'dnf':
            return ['sudo', 'dnf', 'check-update']
        else:
            return None
    
    def is_supported(self):
        """Check if the current platform is supported"""
        return self.info['type'] != 'unsupported'
    
    def needs_homebrew_check(self):
        """Check if Homebrew verification is needed"""
        return self.info['package_manager'] == 'brew'
    
    def get_shell_path(self):
        """Get the path to zsh"""
        return shutil.which('zsh')

class SystemUtils:
    """System utility functions"""
    
    @staticmethod
    def run_command(command, check=True, capture_output=False):
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
            if capture_output:
                print(f"Command failed: {command}")
                print(f"Error output: {e.stderr}")
            return None
    
    @staticmethod
    def command_exists(command):
        """Check if a command exists in PATH"""
        return shutil.which(command) is not None
    
    @staticmethod
    def create_directory(path, mode=0o755):
        """Create directory with proper permissions"""
        Path(path).mkdir(parents=True, exist_ok=True, mode=mode)
    
    @staticmethod
    def backup_file(source, backup_dir):
        """Backup a file or directory"""
        source_path = Path(source)
        backup_path = Path(backup_dir)
        
        if not source_path.exists():
            return False
        
        backup_path.mkdir(parents=True, exist_ok=True)
        
        if source_path.is_dir():
            shutil.copytree(source_path, backup_path / source_path.name, dirs_exist_ok=True)
        else:
            shutil.copy2(source_path, backup_path / source_path.name)
        
        return True