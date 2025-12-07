"""
Font management for Powerlevel10k
"""

from pathlib import Path
from urllib.request import urlretrieve
from urllib.error import URLError
from .platform import SystemUtils

class FontManager:
    """Manage font installation for Powerlevel10k"""
    
    def __init__(self, platform_info):
        self.platform = platform_info
        self.font_dir = platform_info['font_dir']
        self.fonts = self._get_p10k_fonts()
    
    def _get_p10k_fonts(self):
        """Get list of recommended Powerlevel10k fonts"""
        base_url = "https://github.com/romkatv/powerlevel10k-media/raw/master"
        return [
            {
                'name': 'MesloLGS NF Regular',
                'url': f'{base_url}/MesloLGS%20NF%20Regular.ttf',
                'filename': 'MesloLGS NF Regular.ttf'
            },
            {
                'name': 'MesloLGS NF Bold',
                'url': f'{base_url}/MesloLGS%20NF%20Bold.ttf',
                'filename': 'MesloLGS NF Bold.ttf'
            },
            {
                'name': 'MesloLGS NF Italic',
                'url': f'{base_url}/MesloLGS%20NF%20Italic.ttf',
                'filename': 'MesloLGS NF Italic.ttf'
            },
            {
                'name': 'MesloLGS NF Bold Italic',
                'url': f'{base_url}/MesloLGS%20NF%20Bold%20Italic.ttf',
                'filename': 'MesloLGS NF Bold Italic.ttf'
            }
        ]
    
    def install_fonts(self):
        """Install all Powerlevel10k fonts"""
        if not self.font_dir:
            return False, "Font directory not supported on this platform"
        
        # Ensure font directory exists
        self.font_dir.mkdir(parents=True, exist_ok=True)
        
        installed_fonts = []
        failed_fonts = []
        existing_fonts = []
        
        for font in self.fonts:
            font_path = self.font_dir / font['filename']
            
            if font_path.exists():
                existing_fonts.append(font['name'])
                continue
            
            try:
                urlretrieve(font['url'], font_path)
                installed_fonts.append(font['name'])
            except URLError as e:
                failed_fonts.append(f"{font['name']}: {e}")
        
        # Refresh font cache if needed
        if installed_fonts and self.platform['needs_font_cache']:
            SystemUtils.run_command(['fc-cache', '-fv'], check=False)
        
        # Prepare result message
        messages = []
        if installed_fonts:
            messages.append(f"Installed: {', '.join(installed_fonts)}")
        if existing_fonts:
            messages.append(f"Already existed: {', '.join(existing_fonts)}")
        if failed_fonts:
            messages.append(f"Failed: {', '.join(failed_fonts)}")
        
        success = len(failed_fonts) == 0
        message = "; ".join(messages) if messages else "No fonts processed"
        
        return success, message
    
    def check_installed_fonts(self):
        """Check which fonts are already installed"""
        if not self.font_dir or not self.font_dir.exists():
            return []
        
        installed = []
        for font in self.fonts:
            font_path = self.font_dir / font['filename']
            if font_path.exists():
                installed.append(font['name'])
        
        return installed
    
    def get_font_instructions(self):
        """Get platform-specific font configuration instructions"""
        if self.platform['type'] == 'wsl2':
            return [
                "For WSL2:",
                "1. Set your terminal font to 'MesloLGS NF'",
                "2. In Windows Terminal: Settings > Profiles > Ubuntu > Appearance > Font face",
                "3. In other terminals: Check font settings"
            ]
        elif self.platform['type'] == 'linux':
            return [
                "For Linux:",
                "1. Set your terminal font to 'MesloLGS NF'",
                "2. Most terminals: Preferences > Font",
                "3. Font cache has been updated automatically"
            ]
        elif self.platform['type'] == 'macos':
            return [
                "For macOS:",
                "1. Set your terminal font to 'MesloLGS NF'",
                "2. Terminal.app: Preferences > Profiles > Font",
                "3. iTerm2: Preferences > Profiles > Text > Font"
            ]
        else:
            return ["Platform-specific instructions not available"]