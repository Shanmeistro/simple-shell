#!/usr/bin/env python3
"""
Font Management
Handles installation and management of fonts for shell themes
"""

import os
import subprocess
from pathlib import Path
from urllib.request import urlretrieve
from urllib.error import URLError
from typing import List, Dict
from .platform import SystemUtils

class FontManager:
    """Manages font installation for shell themes"""
    
    def __init__(self, system_utils: SystemUtils):
        self.system = system_utils
        self.home = Path.home()
        self.font_dir = self.home / '.local' / 'share' / 'fonts'
        self.font_dir.mkdir(parents=True, exist_ok=True)
    
    def install_nerd_fonts(self, font_families: List[str] = None) -> bool:
        """Install Nerd Fonts for better symbol support"""
        if font_families is None:
            font_families = ['FiraCode', 'JetBrainsMono', 'Hack']
        
        base_url = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download'
        
        try:
            for font_family in font_families:
                font_file = f'{font_family}.zip'
                font_url = f'{base_url}/{font_file}'
                
                print(f"📥 Downloading {font_family} Nerd Font...")
                
                # Download font zip
                temp_zip = f'/tmp/{font_file}'
                urlretrieve(font_url, temp_zip)
                
                # Extract to fonts directory
                self.system.run_command(['unzip', '-o', temp_zip, '-d', str(self.font_dir)])
                
                # Clean up
                os.remove(temp_zip)
                
                print(f"✅ Installed {font_family} Nerd Font")
            
            # Refresh font cache
            self.refresh_font_cache()
            return True
            
        except Exception as e:
            print(f"❌ Failed to install Nerd Fonts: {e}")
            return False
    
    def install_meslo_fonts(self) -> bool:
        """Install MesloLGS NF fonts (optimized for Powerlevel10k)"""
        fonts = {
            'MesloLGS NF Regular.ttf': 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf',
            'MesloLGS NF Bold.ttf': 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf',
            'MesloLGS NF Italic.ttf': 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf',
            'MesloLGS NF Bold Italic.ttf': 'https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf'
        }
        
        try:
            print("📥 Installing MesloLGS NF fonts...")
            
            for font_name, font_url in fonts.items():
                font_path = self.font_dir / font_name
                if not font_path.exists():
                    print(f"  Downloading: {font_name}")
                    urlretrieve(font_url, font_path)
            
            self.refresh_font_cache()
            print("✅ MesloLGS NF fonts installed")
            return True
            
        except Exception as e:
            print(f"❌ Failed to install MesloLGS fonts: {e}")
            return False
    
    def refresh_font_cache(self) -> bool:
        """Refresh system font cache"""
        try:
            print("🔄 Refreshing font cache...")
            self.system.run_command(['fc-cache', '-fv'], capture_output=True)
            return True
        except Exception as e:
            print(f"⚠️  Could not refresh font cache: {e}")
            return False
    
    def list_installed_fonts(self) -> List[str]:
        """List currently installed fonts"""
        try:
            result = self.system.run_command(['fc-list', ':', 'family'], capture_output=True)
            fonts = [line.strip() for line in result.stdout.split('\n') if line.strip()]
            return sorted(set(fonts))
        except Exception:
            return []
    
    def check_font_support(self, font_name: str) -> bool:
        """Check if a specific font is installed"""
        try:
            result = self.system.run_command(['fc-list', '|', 'grep', '-i', font_name], 
                                           capture_output=True, shell=True)
            return len(result.stdout.strip()) > 0
        except Exception:
            return False
    
    def get_font_recommendations(self, framework: str) -> Dict[str, List[str]]:
        """Get font recommendations for different frameworks"""
        recommendations = {
            'powerlevel10k': {
                'required': ['MesloLGS NF'],
                'alternatives': ['FiraCode Nerd Font', 'JetBrains Mono Nerd Font']
            },
            'starship': {
                'required': ['Nerd Font'],
                'alternatives': ['FiraCode Nerd Font', 'JetBrains Mono Nerd Font', 'Hack Nerd Font']
            },
            'oh-my-posh': {
                'required': ['Nerd Font'],
                'alternatives': ['FiraCode Nerd Font', 'JetBrains Mono Nerd Font', 'Cascadia Code Nerd Font']
            },
            'bash-it': {
                'required': [],
                'alternatives': ['Any monospace font']
            }
        }
        
        return recommendations.get(framework, {
            'required': [],
            'alternatives': ['Any monospace font']
        })
    
    def install_recommended_fonts(self, framework: str) -> bool:
        """Install recommended fonts for a specific framework"""
        if framework == 'powerlevel10k':
            return self.install_meslo_fonts()
        elif framework in ['starship', 'oh-my-posh']:
            return self.install_nerd_fonts(['FiraCode', 'JetBrainsMono'])
        else:
            # Install basic Nerd Fonts for general use
            return self.install_nerd_fonts(['Hack'])