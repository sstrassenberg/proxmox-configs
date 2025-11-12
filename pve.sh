#!/bin/bash
# Script Name: pve.sh
# Purpose: Unified script for PVE package installation, configuration, and personalization.

echo "--- Starting PVE Configuration Setup (Source: https://racz.cz/pex/) ---"

# 1. Install Nala
echo "1/9: Installing Nala for fast package management..."
apt update && apt install nala -y

# 2. Core System Update
echo "2/9: Running core system update and upgrade..."
nala fetch
nala update && nala upgrade -y

# 3. Install Monitoring Tools
echo "3/9: Installing lm-sensors and neofetch..."
nala install lm-sensors neofetch -y

# 4. Configure Sensors (Requires User Input)
echo "4/9: Running sensors-detect (requires you to answer 'yes' to all prompts)..."
sensors-detect

# 5. Add Network Storage (NFS)
echo "5/9: Adding shared NFS backup storage (nfs_backup)..."
pvesm add nfs nfs_backup --server 192.168.1.50 --export /mnt/backups --content backup

# 6. Configuration File Uploads (Fetched from public server)
echo "6/9: Fetching custom .bashrc and Neofetch config from https://racz.cz/pex/..."
mkdir -p /root/.config/neofetch
wget -O /root/.bashrc https://racz.cz/pex/bashrc
wget -O /root/.config/neofetch/config.conf https://racz.cz/pex/config.conf

# 7. Architecture-Specific Fixes (Interactive)
echo "7/9: Checking for AMD architecture fix..."
read -r -p "Is this an AMD (Aspire) machine needing the Load Average fix? (y/N) " response
if [[ "$response" =~ ^([yY])$ ]]; then
    echo "    - Applying AMD Load Average fix to Neofetch config..."
    # Add custom load_average variable before the print_info function
    sed -i '/^print_info() {/i\
load_average=`uptime | awk -F\047load average:\047 \047{print \$2}\047`\n' /root/.config/neofetch/config.conf
    echo "    - NOTE: Verify 'Load Average' is used in config.conf print_info() section."
fi

# 8. Final Check: Temp Sensor
echo "8/9: Final check for temp sensor access (hwmon3 assumed)..."
cat /sys/class/hwmon/hwmon3/temp1_input || echo "    - WARNING: Temp sensor access failed. Check hwmon path!"

# 9. Finalize Shell
echo "9/9: Finalizing shell by sourcing .bashrc..."
source /root/.bashrc

echo "--- SETUP COMPLETE. Run 'neofetch' to test! ---"