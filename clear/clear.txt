#!/bin/bash

# [!] This script aggressively deletes traces of USB/network activity and clipboard history.
# [!] Use with caution. Designed for educational/forensic testing purposes.

echo "[+] Starting trace cleanup..."

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run as root."
  exit 1
fi

# Clear shell histories
echo "[*] Clearing shell histories..."
history -c 2>/dev/null
rm -f ~/.bash_history 2>/dev/null
rm -f ~/.zsh_history 2>/dev/null
rm -f ~/.bashrc 2>/dev/null
rm -f ~/.zshrc 2>/dev/null

# Clear clipboard managers
echo "[*] Clearing clipboard history..."
killall clipit parcellite diodon klipper xf86-clipboard 2>/dev/null
rm -rf ~/.cache/clipit/ 2>/dev/null
rm -rf ~/.local/share/parcellite/ 2>/dev/null
rm -rf ~/.diodon/ 2>/dev/null
rm -rf ~/.config/xfce4/clipboards/ 2>/dev/null
rm -rf ~/.local/share/kde4/services/klipper/ 2>/dev/null

# Clear systemd journals
echo "[*] Clearing systemd journals..."
journalctl --flush --runtime
journalctl --vacuum-time=1s

# Clear kernel ring buffer
echo "[*] Clearing dmesg logs..."
dmesg --clear

# Clear common system logs
echo "[*] Clearing system logs..."
log_files=(
  /var/log/syslog /var/log/syslog.1 /var/log/syslog.gz
  /var/log/messages /var/log/messages.1 /var/log/messages.gz
  /var/log/kern.log /var/log/kern.log.1 /var/log/kern.log.gz
  /var/log/daemon.log /var/log/daemon.log.1 /var/log/daemon.log.gz
  /var/log/auth.log /var/log/auth.log.1 /var/log/auth.log.gz
)

for log in "${log_files[@]}"; do
  [ -f "$log" ] && truncate -s 0 "$log"
done

# Clear audit logs
echo "[*] Clearing audit logs..."
if [ -f /var/log/audit/audit.log ]; then
  cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/audit.log ]; then
  cat /dev/null > /var/log/audit.log
fi

# Clear Xorg logs
echo "[*] Clearing Xorg logs..."
if [ -f /var/log/Xorg.0.log ]; then
  truncate -s 0 /var/log/Xorg.0.log
fi

# Clear GNOME/KDE/XFCE recent files
echo "[*] Clearing desktop recent activity..."
rm -rf ~/.local/share/recently-used.xbel 2>/dev/null
rm -rf ~/.cache/gnome-shell/recently-used.xbel 2>/dev/null
rm -rf ~/.kde/share/recentdocuments/ 2>/dev/null
rm -rf ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml 2>/dev/null

# Unmount USB drives
echo "[*] Unmounting pendrives..."
for mount_point in $(lsblk -nrpo MOUNTPOINT | grep -v '/'); do
  umount -l "$mount_point" 2>/dev/null
done

# Clear swap
echo "[*] Clearing swap space..."
swapoff -a && swapon -a

# Clear utmp/wtmp/lastlog
echo "[*] Clearing user login logs..."
truncate -s 0 /var/log/utmp
truncate -s 0 /var/log/wtmp
truncate -s 0 /var/log/lastlog

# Clear temporary files
echo "[*] Clearing /tmp and /var/tmp..."
rm -rf /tmp/* 2>/dev/null
rm -rf /var/tmp/* 2>/dev/null

# Clear DNS cache (if applicable)
echo "[*] Clearing DNS cache..."
systemctl stop systemd-resolved 2>/dev/null
rm -rf /var/cache/systemd/resolved* 2>/dev/null
systemctl start systemd-resolved 2>/dev/null

echo "[+] Trace cleanup complete. Reboot recommended."
history -c && history -w
rm -f ~/.bash_history ~/.zsh_history ~/.ksh_history ~/.histfile ~/.python_history 2>/dev/null