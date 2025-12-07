"""
Backup management for existing configurations
"""

import shutil
from pathlib import Path
from datetime import datetime
from .platform import SystemUtils

class BackupManager:
    """Manage backup and restore operations for shell configurations"""
    
    def __init__(self, home_dir=None):
        self.home_dir = Path(home_dir) if home_dir else Path.home()
        self.backup_dir = self.home_dir / f'.config/shell-backup-{datetime.now().strftime("%Y%m%d-%H%M%S")}'
        
    def create_backup(self, force=False):
        """Create backup of existing shell configurations"""
        configs_to_backup = [
            ('.zshrc', self.home_dir / '.zshrc'),
            ('.bashrc', self.home_dir / '.bashrc'),
            ('.p10k.zsh', self.home_dir / '.p10k.zsh'),
            ('oh-my-zsh', self.home_dir / '.oh-my-zsh'),
            ('fish-config', self.home_dir / '.config/fish'),
            ('nushell-config', self.home_dir / '.config/nushell'),
            ('starship.toml', self.home_dir / '.config/starship.toml'),
        ]
        
        backed_up = []
        errors = []
        
        for name, path in configs_to_backup:
            if path.exists():
                try:
                    # Create backup directory if it doesn't exist
                    self.backup_dir.mkdir(parents=True, exist_ok=True)
                    
                    backup_path = self.backup_dir / name
                    
                    if path.is_dir():
                        shutil.copytree(path, backup_path, dirs_exist_ok=True)
                    else:
                        shutil.copy2(path, backup_path)
                    
                    backed_up.append(name)
                    
                except Exception as e:
                    errors.append(f"{name}: {e}")
        
        return {
            'success': len(errors) == 0,
            'backed_up': backed_up,
            'errors': errors,
            'backup_dir': str(self.backup_dir) if backed_up else None
        }
    
    def list_backups(self):
        """List all available backups"""
        backup_parent = self.home_dir / '.config'
        
        if not backup_parent.exists():
            return []
        
        backups = []
        for item in backup_parent.iterdir():
            if item.is_dir() and item.name.startswith('shell-backup-'):
                # Extract timestamp from backup name
                timestamp_str = item.name.replace('shell-backup-', '')
                try:
                    timestamp = datetime.strptime(timestamp_str, '%Y%m%d-%H%M%S')
                    backups.append({
                        'path': item,
                        'timestamp': timestamp,
                        'name': item.name,
                        'files': list(item.iterdir())
                    })
                except ValueError:
                    # Skip malformed backup directories
                    continue
        
        # Sort by timestamp, newest first
        backups.sort(key=lambda x: x['timestamp'], reverse=True)
        return backups
    
    def restore_backup(self, backup_path, selective=False, items=None):
        """Restore from a backup"""
        backup_path = Path(backup_path)
        
        if not backup_path.exists() or not backup_path.is_dir():
            return {'success': False, 'error': 'Backup directory not found'}
        
        restored = []
        errors = []
        
        # Define restoration mappings
        restore_mappings = {
            '.zshrc': self.home_dir / '.zshrc',
            '.bashrc': self.home_dir / '.bashrc', 
            '.p10k.zsh': self.home_dir / '.p10k.zsh',
            'oh-my-zsh': self.home_dir / '.oh-my-zsh',
            'fish-config': self.home_dir / '.config/fish',
            'nushell-config': self.home_dir / '.config/nushell',
            'starship.toml': self.home_dir / '.config/starship.toml',
        }
        
        # If selective restore, filter items
        if selective and items:
            restore_mappings = {k: v for k, v in restore_mappings.items() if k in items}
        
        for backup_name, target_path in restore_mappings.items():
            source_path = backup_path / backup_name
            
            if not source_path.exists():
                continue
            
            try:
                # Remove existing target if it exists
                if target_path.exists():
                    if target_path.is_dir():
                        shutil.rmtree(target_path)
                    else:
                        target_path.unlink()
                
                # Ensure parent directory exists
                target_path.parent.mkdir(parents=True, exist_ok=True)
                
                # Restore from backup
                if source_path.is_dir():
                    shutil.copytree(source_path, target_path)
                else:
                    shutil.copy2(source_path, target_path)
                
                restored.append(backup_name)
                
            except Exception as e:
                errors.append(f"{backup_name}: {e}")
        
        return {
            'success': len(errors) == 0,
            'restored': restored,
            'errors': errors
        }
    
    def clean_old_backups(self, keep_count=5):
        """Clean old backups, keeping only the specified number"""
        backups = self.list_backups()
        
        if len(backups) <= keep_count:
            return {'cleaned': 0, 'errors': []}
        
        to_remove = backups[keep_count:]
        removed = 0
        errors = []
        
        for backup in to_remove:
            try:
                shutil.rmtree(backup['path'])
                removed += 1
            except Exception as e:
                errors.append(f"{backup['name']}: {e}")
        
        return {'cleaned': removed, 'errors': errors}
    
    def get_backup_info(self, backup_path):
        """Get detailed information about a backup"""
        backup_path = Path(backup_path)
        
        if not backup_path.exists():
            return None
        
        info = {
            'path': str(backup_path),
            'name': backup_path.name,
            'timestamp': None,
            'size': 0,
            'files': []
        }
        
        # Extract timestamp
        timestamp_str = backup_path.name.replace('shell-backup-', '')
        try:
            info['timestamp'] = datetime.strptime(timestamp_str, '%Y%m%d-%H%M%S')
        except ValueError:
            pass
        
        # Calculate size and list files
        for item in backup_path.rglob('*'):
            if item.is_file():
                try:
                    info['size'] += item.stat().st_size
                    # Store relative path from backup root
                    rel_path = item.relative_to(backup_path)
                    info['files'].append(str(rel_path))
                except OSError:
                    pass
        
        return info

class ConfigValidator:
    """Validate shell configurations for safety"""
    
    @staticmethod
    def validate_zshrc(zshrc_path):
        """Validate .zshrc file for common issues"""
        issues = []
        
        if not Path(zshrc_path).exists():
            return ['File does not exist']
        
        try:
            with open(zshrc_path, 'r') as f:
                content = f.read()
            
            # Check for potential issues
            if 'rm -rf /' in content:
                issues.append('Dangerous rm command found')
            
            if 'source /dev/null' in content:
                issues.append('Suspicious source command found')
            
            # Check for Oh My Zsh configuration
            if 'ZSH=' not in content and '.oh-my-zsh' in content:
                issues.append('Oh My Zsh referenced but ZSH variable not set')
            
            # Check for theme configuration
            if 'ZSH_THEME=' not in content and '.oh-my-zsh' in content:
                issues.append('Oh My Zsh installed but no theme configured')
            
        except Exception as e:
            issues.append(f'Failed to read file: {e}')
        
        return issues
    
    @staticmethod
    def validate_p10k_config(p10k_path):
        """Validate .p10k.zsh file"""
        issues = []
        
        if not Path(p10k_path).exists():
            return ['File does not exist']
        
        try:
            with open(p10k_path, 'r') as f:
                content = f.read()
            
            # Check for required P10k components
            if 'POWERLEVEL9K_' not in content:
                issues.append('No Powerlevel10k configuration found')
            
            if 'typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS' not in content:
                issues.append('Left prompt elements not configured')
            
        except Exception as e:
            issues.append(f'Failed to read file: {e}')
        
        return issues