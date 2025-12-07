# WSL2 Disk Size Management Guide

## 🚀 Fresh Ubuntu 24.04 Installation with Custom Location

### Step 1: Download the Ubuntu 24.04 Appx Package

**Option A: Microsoft Store**
- Download directly from Microsoft Store

**Option B: PowerShell Download**
```powershell
# Download Ubuntu 24.04 appx package
Invoke-WebRequest -Uri https://aka.ms/wslubuntu2404 -OutFile Ubuntu2404.appx

# Install the appx package
Add-AppxPackage .\Ubuntu2404.appx
```

### Step 2: Install WSL with Custom Disk Location

```powershell
# Initial installation (creates default location)
wsl --install -d Ubuntu-24.04 --root

# Export the fresh installation
wsl --export Ubuntu-24.04 ubuntu2404.tar

# Remove the default installation
wsl --unregister Ubuntu-24.04

# Import to custom location (replace D:\WSL\Ubuntu2404 with your preferred path)
wsl --import Ubuntu-24.04 D:\WSL\Ubuntu2404 ubuntu2404.tar --version 2

# Clean up the temporary export file
Remove-Item ubuntu2404.tar
```

## 📊 Benefits of Custom Location

✅ **Exact disk location control**  
✅ **Easy disk size monitoring**  
✅ **Simple backup process**  
✅ **Easy replication across machines**  
✅ **Better storage management**  

## 🔧 Disk Maintenance

### Regular Cleanup (Inside Ubuntu)
```bash
# Remove unnecessary packages and clean package cache
sudo apt update
sudo apt autoremove -y
sudo apt autoclean
sudo apt clean

# Clear temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clear system logs (optional)
sudo journalctl --vacuum-size=100M
```

### VHDX Compression (PowerShell as Administrator)
```powershell
# Shutdown WSL completely
wsl --shutdown

# Wait a few seconds to ensure complete shutdown
Start-Sleep -Seconds 5

# Optimize/compress the VHDX file (replace path as needed)
Optimize-VHD -Path "D:\WSL\Ubuntu2404\ext4.vhdx" -Mode Full
```

## 💾 Backup Strategy

### Quick Backup
```powershell
# Export current state
wsl --export Ubuntu-24.04 "C:\Backups\ubuntu2404-$(Get-Date -Format 'yyyy-MM-dd').tar"
```

### Restore from Backup
```powershell
# Remove current installation
wsl --unregister Ubuntu-24.04

# Restore from backup
wsl --import Ubuntu-24.04 D:\WSL\Ubuntu2404 "C:\Backups\ubuntu2404-YYYY-MM-DD.tar" --version 2
```

## 📏 Monitoring Disk Usage

### Check VHDX Size (PowerShell)
```powershell
# Get current VHDX file size
Get-ChildItem "D:\WSL\Ubuntu2404\ext4.vhdx" | Select-Object Name, @{Name="Size(GB)"; Expression={[math]::Round($_.Length/1GB, 2)}}
```

### Check Usage Inside Ubuntu
```bash
# Check overall disk usage
df -h /

# Find largest directories
du -sh /* 2>/dev/null | sort -rh | head -10

# Check package cache size
du -sh /var/cache/apt/archives/
```

## ⚠️ Important Notes

- **Always shutdown WSL** before running `Optimize-VHD`
- **Run PowerShell as Administrator** for VHDX operations
- **Regular maintenance** prevents excessive disk growth
- **Test restores** to ensure backup integrity
- **Monitor disk space** on both Windows and WSL sides

## 🔄 Migration to Different Drive

```powershell
# Export current installation
wsl --export Ubuntu-24.04 migration-backup.tar

# Unregister current
wsl --unregister Ubuntu-24.04

# Import to new location
wsl --import Ubuntu-24.04 E:\NewPath\Ubuntu2404 migration-backup.tar --version 2

# Clean up
Remove-Item migration-backup.tar
```

This approach gives you complete control over your WSL2 installation location and size management.
