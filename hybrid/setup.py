#!/usr/bin/env python3
"""
Simple Shell Environment Setup - Python Backend
Handles the actual installation logic with advanced error handling
"""

import os
import sys
import json
import argparse
from pathlib import Path

# Add the lib directory to Python path
sys.path.insert(0, str(Path(__file__).parent / 'lib'))

from installer import SimpleShellInstaller

def load_config(config_file: str) -> dict:
    """Load configuration from JSON file"""
    try:
        with open(config_file, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Failed to load config: {e}")
        sys.exit(1)

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description='Simple Shell Environment Installer - Python Backend')
    parser.add_argument('config', help='Configuration file path')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    # Load configuration
    config = load_config(args.config)
    
    # Validate required fields
    required_fields = ['shell', 'framework', 'prompt']
    for field in required_fields:
        if field not in config:
            print(f"Missing required field in config: {field}")
            sys.exit(1)
    
    # Create installer and run setup
    installer = SimpleShellInstaller()
    
    try:
        success = installer.setup_shell_environment(config)
        
        if success:
            print("\n🎉 Installation completed successfully!")
            sys.exit(0)
        else:
            print("\n❌ Installation failed.")
            sys.exit(1)
    
    except KeyboardInterrupt:
        print("\n⚠ Installation interrupted by user.")
        sys.exit(1)
    except Exception as e:
        if args.verbose:
            import traceback
            traceback.print_exc()
        else:
            print(f"\n❌ Installation failed: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()