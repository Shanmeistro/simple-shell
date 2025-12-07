#!/usr/bin/env python3
"""
Backup Management
Handles backup and restoration of shell configurations
"""

import os
import shutil
from pathlib import Path
from typing import List, Dict
from datetime import datetime

class BackupManager:
    """Manages backup and restoration of shell configurations"""
    
    def __init__(self):
        self.home = Path.home()
        self.config_dir = self.home / '.config'
        self.backup_timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    
    def create_backup(self, files_to_backup: List[str], backup_name: str = 'shell') -> Path:
        """Create backup of specified files"""
        backup_dir = self.config_dir / f'{backup_name}-backup-{self.backup_timestamp}'
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        backed_up = []
        
        for file_path in files_to_backup:
            source = self.home / file_path.lstrip('~/')
            
            if source.exists():
                if source.is_file():
                    shutil.copy2(source, backup_dir / source.name)
                    backed_up.append(source.name)
                elif source.is_dir():
                    shutil.copytree(source, backup_dir / source.name, dirs_exist_ok=True)
                    backed_up.append(f"{source.name}/")
        
        if backed_up:
            # Create backup manifest
            manifest = backup_dir / 'backup_manifest.txt'
            with manifest.open('w') as f:
                f.write(f"Backup created: {datetime.now()}\n")
                f.write(f"Files backed up:\n")
                for item in backed_up:
                    f.write(f"  - {item}\n")
            
            print(f"✅ Backup created: {backup_dir}")
            print(f"📁 Backed up: {', '.join(backed_up)}")
        else:
            # Remove empty backup directory
            backup_dir.rmdir()
            print("ℹ️  No existing configurations found to backup")
        
        return backup_dir if backed_up else None
    
    def backup_shell_configs(self, shell_type: str) -> Path:
        """Backup shell-specific configurations"""
        configs = {
            'zsh': ['.zshrc', '.zsh_history', '.oh-my-zsh', '.p10k.zsh'],
            'bash': ['.bashrc', '.bash_profile', '.bash_history', '.bash_it', '.bash_aliases'],
            'general': ['.profile', '.inputrc']
        }
        
        files_to_backup = configs.get(shell_type, []) + configs['general']
        return self.create_backup(files_to_backup, f'{shell_type}-shell')
    
    def list_backups(self, backup_type: str = None) -> List[Path]:
        """List available backups"""
        if not self.config_dir.exists():
            return []
        
        pattern = f'{backup_type}-backup-*' if backup_type else '*-backup-*'
        backups = sorted(self.config_dir.glob(pattern), reverse=True)
        return backups
    
    def restore_backup(self, backup_dir: Path) -> bool:
        """Restore from backup directory"""
        if not backup_dir.exists():
            print(f"❌ Backup directory not found: {backup_dir}")
            return False
        
        try:
            # Read manifest if available
            manifest = backup_dir / 'backup_manifest.txt'
            if manifest.exists():
                print(f"📋 Restoring from backup: {backup_dir.name}")
                with manifest.open('r') as f:
                    print(f.read())
            
            # Restore files
            restored = []
            for item in backup_dir.iterdir():
                if item.name == 'backup_manifest.txt':
                    continue
                
                target = self.home / item.name
                
                # Create backup of current file before restoring
                if target.exists():
                    current_backup = self.home / f'{item.name}.pre-restore'
                    if target.is_file():
                        shutil.copy2(target, current_backup)
                    else:
                        shutil.copytree(target, current_backup, dirs_exist_ok=True)
                
                # Restore file/directory
                if item.is_file():
                    shutil.copy2(item, target)
                else:
                    if target.exists():
                        shutil.rmtree(target)
                    shutil.copytree(item, target)
                
                restored.append(item.name)
            
            if restored:
                print(f"✅ Restored: {', '.join(restored)}")
                return True
            else:
                print("⚠️  No files found to restore")
                return False
        
        except Exception as e:
            print(f"❌ Restore failed: {e}")
            return False