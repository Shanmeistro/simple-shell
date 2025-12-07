"""
Shell configuration and management
"""

import os
import shutil
from pathlib import Path
from .platform import SystemUtils

class ShellManager:
    """Manage shell installation and configuration"""
    
    def __init__(self, home_dir=None):
        self.home_dir = Path(home_dir) if home_dir else Path.home()
        self.omz_path = self.home_dir / '.oh-my-zsh'
        self.p10k_path = self.omz_path / 'custom/themes/powerlevel10k'
    
    def install_oh_my_zsh(self):
        """Install Oh My Zsh"""
        if self.omz_path.exists():
            return True, "Oh My Zsh already exists"
        
        # Download and install Oh My Zsh
        install_script = (
            "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" "
            "\"\" --unattended"
        )
        
        result = SystemUtils.run_command(install_script)
        if result and self.omz_path.exists():
            return True, "Oh My Zsh installed successfully"
        else:
            return False, "Failed to install Oh My Zsh"
    
    def install_powerlevel10k(self):
        """Install Powerlevel10k theme"""
        if self.p10k_path.exists():
            # Update existing installation
            result = SystemUtils.run_command(['git', '-C', str(self.p10k_path), 'pull'], check=False)
            if result:
                return True, "Powerlevel10k updated"
            else:
                return False, "Failed to update Powerlevel10k"
        else:
            # Fresh installation
            clone_url = "https://github.com/romkatv/powerlevel10k.git"
            result = SystemUtils.run_command([
                'git', 'clone', '--depth=1', clone_url, str(self.p10k_path)
            ])
            if result:
                return True, "Powerlevel10k installed successfully"
            else:
                return False, "Failed to install Powerlevel10k"
    
    def install_zsh_plugins(self):
        """Install useful Zsh plugins"""
        plugins = [
            {
                'name': 'zsh-autosuggestions',
                'url': 'https://github.com/zsh-users/zsh-autosuggestions',
                'path': self.omz_path / 'custom/plugins/zsh-autosuggestions'
            },
            {
                'name': 'zsh-syntax-highlighting',
                'url': 'https://github.com/zsh-users/zsh-syntax-highlighting.git',
                'path': self.omz_path / 'custom/plugins/zsh-syntax-highlighting'
            }
        ]
        
        results = []
        for plugin in plugins:
            if plugin['path'].exists():
                result = SystemUtils.run_command(['git', '-C', str(plugin['path']), 'pull'], check=False)
                status = "updated" if result else "update failed"
            else:
                result = SystemUtils.run_command(['git', 'clone', plugin['url'], str(plugin['path'])])
                status = "installed" if result else "install failed"
            
            results.append(f"{plugin['name']}: {status}")
        
        return True, "; ".join(results)
    
    def create_zshrc(self, template_content):
        """Create .zshrc file"""
        zshrc_path = self.home_dir / '.zshrc'
        try:
            with open(zshrc_path, 'w') as f:
                f.write(template_content)
            return True, f"Created {zshrc_path}"
        except Exception as e:
            return False, f"Failed to create .zshrc: {e}"
    
    def create_p10k_config(self, template_content):
        """Create .p10k.zsh file"""
        p10k_config_path = self.home_dir / '.p10k.zsh'
        try:
            with open(p10k_config_path, 'w') as f:
                f.write(template_content)
            return True, f"Created {p10k_config_path}"
        except Exception as e:
            return False, f"Failed to create .p10k.zsh: {e}"
    
    def set_default_shell(self):
        """Set Zsh as the default shell"""
        current_shell = os.environ.get('SHELL', '')
        zsh_path = shutil.which('zsh')
        
        if not zsh_path:
            return False, "Zsh not found in PATH"
        
        if current_shell == zsh_path:
            return True, "Zsh is already the default shell"
        
        try:
            result = SystemUtils.run_command(['chsh', '-s', zsh_path], check=False)
            if result and result.returncode == 0:
                return True, f"Default shell changed to: {zsh_path}"
            else:
                return True, f"Please run manually: chsh -s {zsh_path}"
        except Exception as e:
            return False, f"Error changing default shell: {e}"
    
    def get_existing_configs(self):
        """Get list of existing shell configurations"""
        configs = {
            '.zshrc': self.home_dir / '.zshrc',
            '.p10k.zsh': self.home_dir / '.p10k.zsh',
            'oh-my-zsh': self.omz_path,
        }
        
        existing = {}
        for name, path in configs.items():
            existing[name] = path.exists()
        
        return existing