#!/usr/bin/env python3
"""
Simple Shell Environment Setup - Python Backend for Hybrid Installer
Handles the actual installation logic after shell script handles platform detection
"""

import os
import sys
import argparse
from pathlib import Path

# Add the lib directory to Python path
sys.path.insert(0, str(Path(__file__).parent / 'lib'))

from platform import PlatformDetector, SystemUtils
from shell import ShellManager
from fonts import FontManager
from backup import BackupManager
from templates import Templates
from installer import SimpleShellInstaller

class HybridInstaller(SimpleShellInstaller):
    """Hybrid installer that works with shell script frontend"""
    
    def __init__(self, args=None):
        super().__init__()
        self.args = args or argparse.Namespace()
        
    def run_installation(self):
        """Run the installation with hybrid-specific logic"""
        self.print_header("Python Installer Backend")
        
        print(f"Platform: {self.platform_info['type'].upper()} ({self.platform_info['os']})")
        print(f"Package Manager: {self.platform_info['package_manager']}")
        
        if self.platform_info['type'] == 'unsupported':
            self.print_error("Unsupported platform detected in Python backend")
            sys.exit(1)
        
        # Installation steps with better error handling
        steps = [
            ("Create backup", self.backup_existing_configs),
            ("Install Oh My Zsh", self.install_oh_my_zsh),
            ("Install Powerlevel10k", self.install_powerlevel10k),
            ("Install Zsh plugins", self.install_zsh_plugins),
            ("Install fonts", self.install_p10k_fonts),
            ("Configure shell", self.configure_zsh),
            ("Set default shell", self.set_default_shell),
        ]
        
        successful_steps = []
        failed_steps = []
        
        for step_name, step_func in steps:
            try:
                self.print_step(f"Running: {step_name}")
                if step_func():
                    successful_steps.append(step_name)
                    self.print_success(f"Completed: {step_name}")
                else:
                    failed_steps.append(step_name)
                    self.print_error(f"Failed: {step_name}")
                    
                    if not getattr(self.args, 'continue_on_error', False):
                        response = input(f"\nContinue with remaining steps? (y/n): ")
                        if response.lower() not in ['y', 'yes']:
                            break
            except KeyboardInterrupt:
                self.print_error("\nInstallation cancelled by user")
                sys.exit(1)
            except Exception as e:
                self.print_error(f"Unexpected error in {step_name}: {e}")
                failed_steps.append(step_name)
                
                if not getattr(self.args, 'continue_on_error', False):
                    response = input(f"\nContinue with remaining steps? (y/n): ")
                    if response.lower() not in ['y', 'yes']:
                        break
        
        # Show summary
        self.show_installation_summary(successful_steps, failed_steps)

    def show_installation_summary(self, successful_steps, failed_steps):
        """Show a detailed installation summary"""
        self.print_header("Installation Summary")
        
        if successful_steps:
            self.print_success("Completed steps:")
            for step in successful_steps:
                print(f"  ✓ {step}")
        
        if failed_steps:
            self.print_warning("Failed steps:")
            for step in failed_steps:
                print(f"  ✗ {step}")
            print(f"\n{self.Colors.YELLOW}Some steps failed. You may need to run the installer again or fix issues manually.{self.Colors.RESET}")
        
        if not failed_steps:
            self.show_completion_message()
        
        # Show next steps
        print(f"\n{self.Colors.CYAN}Next Steps:{self.Colors.RESET}")
        print("1. Start a new shell session: exec zsh")
        print("2. Configure Powerlevel10k: p10k configure")
        
        if self.platform_info['type'] == 'wsl2':
            print("3. Set terminal font to 'MesloLGS NF' in Windows Terminal")

def main():
    """Main entry point for hybrid installer"""
    parser = argparse.ArgumentParser(description='Simple Shell Environment - Python Backend')
    parser.add_argument('--continue-on-error', action='store_true', 
                       help='Continue installation even if steps fail')
    parser.add_argument('--docker-mode', action='store_true',
                       help='Run in Docker container mode')
    parser.add_argument('--cloud-mode', action='store_true',
                       help='Run in cloud environment mode')
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Verbose output')
    
    args = parser.parse_args()
    
    # Set environment variables for special modes
    if args.docker_mode:
        os.environ['SIMPLE_SHELL_DOCKER_MODE'] = '1'
    if args.cloud_mode:
        os.environ['SIMPLE_SHELL_CLOUD_MODE'] = '1'
    
    try:
        installer = HybridInstaller(args)
        installer.run_installation()
    except Exception as e:
        print(f"Fatal error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()