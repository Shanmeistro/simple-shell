#!/usr/bin/env python3
"""
Platform Detection and System Utilities
Handles cross-platform compatibility and system detection
"""

import os
import sys
import platform
import subprocess
from pathlib import Path
from typing import Dict, Optional, List

class PlatformDetector:
    """Detects platform, distribution, and system capabilities"""
    
    def __init__(self):
        self.info = self._detect_platform()
        
    def _detect_platform(self) -> Dict[str, str]:
        """Detect current platform and return standardized info"""
        system = platform.system().lower()
        is_wsl = self._is_wsl()
        
        if system == 'linux':
            if is_wsl:
                return {
                    'type': 'wsl2',
                    'os': self._detect_linux_distro(),
                    'package_manager': self._detect_package_manager(),
                    'shell': os.environ.get('SHELL', '/bin/bash')
                }
            else:
                return {
                    'type': 'linux',
                    'os': self._detect_linux_distro(),
                    'package_manager': self._detect_package_manager(),
                    'shell': os.environ.get('SHELL', '/bin/bash')
                }
        elif system == 'darwin':
            return {
                'type': 'macos',
                'os': 'macos',
                'package_manager': 'brew',
                'shell': os.environ.get('SHELL', '/bin/bash')
            }
        else:
            return {
                'type': 'unsupported',
                'os': system,
                'package_manager': 'unknown',
                'shell': 'unknown'
            }
    
    def _is_wsl(self) -> bool:
        """Check if running in WSL"""
        try:
            with open('/proc/version', 'r') as f:
                return 'microsoft' in f.read().lower()
        except (FileNotFoundError, PermissionError):
            return False
    
    def _detect_linux_distro(self) -> str:
        """Detect Linux distribution"""
        try:
            # Try /etc/os-release first
            if os.path.exists('/etc/os-release'):
                with open('/etc/os-release', 'r') as f:
                    for line in f:
                        if line.startswith('ID='):
                            return line.split('=')[1].strip().strip('"')
            
            # Fallback to lsb_release
            result = subprocess.run(['lsb_release', '-si'], 
                                   capture_output=True, text=True)
            if result.returncode == 0:
                return result.stdout.strip().lower()
        except Exception:
            pass
        
        return 'unknown'
    
    def _detect_package_manager(self) -> str:
        """Detect available package manager"""
        managers = {
            'apt': '/usr/bin/apt',
            'yum': '/usr/bin/yum',
            'dnf': '/usr/bin/dnf',
            'pacman': '/usr/bin/pacman',
            'zypper': '/usr/bin/zypper'
        }
        
        for manager, path in managers.items():
            if os.path.exists(path):
                return manager
        
        return 'unknown'
    
    def is_supported(self) -> bool:
        """Check if platform is supported"""
        return self.info['type'] in ['wsl2', 'linux', 'macos']
    
    def get_info(self) -> Dict[str, str]:
        """Get platform information"""
        return self.info.copy()

class SystemUtils:
    """System utilities for package management and system operations"""
    
    def __init__(self, platform_info: Dict[str, str]):
        self.platform_info = platform_info
        self.package_manager = platform_info.get('package_manager')
    
    def run_command(self, command: List[str], check: bool = True, 
                   capture_output: bool = False, shell: bool = False) -> subprocess.CompletedProcess:
        """Run system command with proper error handling"""
        try:
            if shell:
                command = ' '.join(command)
            
            result = subprocess.run(
                command,
                shell=shell,
                check=check,
                capture_output=capture_output,
                text=True
            )
            return result
        except subprocess.CalledProcessError as e:
            raise SystemError(f"Command failed: {' '.join(command) if isinstance(command, list) else command}\nError: {e}")
        except FileNotFoundError:
            raise SystemError(f"Command not found: {command[0] if isinstance(command, list) else command.split()[0]}")
    
    def install_packages(self, packages: List[str]) -> bool:
        """Install system packages using appropriate package manager"""
        if not packages:
            return True
        
        try:
            if self.package_manager == 'apt':
                self.run_command(['sudo', 'apt', 'update'])
                self.run_command(['sudo', 'apt', 'install', '-y'] + packages)
            elif self.package_manager == 'brew':
                self.run_command(['brew', 'install'] + packages)
            elif self.package_manager in ['yum', 'dnf']:
                self.run_command(['sudo', self.package_manager, 'install', '-y'] + packages)
            elif self.package_manager == 'pacman':
                self.run_command(['sudo', 'pacman', '-S', '--noconfirm'] + packages)
            else:
                raise SystemError(f"Unsupported package manager: {self.package_manager}")
            
            return True
        except SystemError:
            return False
    
    def command_exists(self, command: str) -> bool:
        """Check if command exists in system PATH"""
        try:
            result = self.run_command(['which', command], capture_output=True)
            return result.returncode == 0
        except SystemError:
            return False
    
    def get_shell_path(self, shell_name: str) -> Optional[str]:
        """Get full path to shell executable"""
        try:
            result = self.run_command(['which', shell_name], capture_output=True)
            if result.returncode == 0:
                return result.stdout.strip()
        except SystemError:
            pass
        return None
    
    def create_backup_dir(self, base_name: str) -> Path:
        """Create timestamped backup directory"""
        from datetime import datetime
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        backup_dir = Path.home() / '.config' / f'{base_name}-backup-{timestamp}'
        backup_dir.mkdir(parents=True, exist_ok=True)
        return backup_dir