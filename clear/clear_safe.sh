#!/bin/bash

echo "[+] Starting EXTENDED SAFE trace cleanup..."

# Root check
if [ "$EUID" -ne 0 ]; then
  echo "[-] Please run as root."
  exit 1
fi

### --- CLIPBOARD HISTORY ---
echo "[*] Clearing clipboard managers..."
killall clipit parcellite diodon klipper xf86-clipboard 2>/dev/null
rm -rf ~/.cache/clipit/
rm -rf ~/.local/share/parcellite/
rm -rf ~/.diodon/
rm -rf ~/.config/xfce4/clipboards/
rm -rf ~/.local/share/kde4/services/klipper/

### --- DMESG / USB INFO ---
echo "[*] Clearing kernel ring buffer (dmesg)..."
dmesg --clear

echo "[*] Clearing USB traces from udev logs..."
rm -f /run/udev/data/*usb* 2>/dev/null

### --- UNMOUNT USB DRIVES SAFELY ---
echo "[*] Unmounting USB drives..."
for dev in $(lsblk -o NAME,MOUNTPOINT | grep '/media/' | awk '{print $1}'); do
  umount -l "/dev/$dev" 2>/dev/null
done

### --- RECENT FILE ACTIVITY ---
echo "[*] Clearing desktop recent file entries..."
rm -f ~/.local/share/recently-used.xbel
rm -rf ~/.kde/share/recentdocuments/
rm -f ~/.config/gtk-3.0/bookmarks

### --- BROWSER HISTORY ---
echo "[*] Clearing browser history (Firefox, Chromium/Chrome)..."

# Firefox
find ~/.mozilla/firefox -type f \( -name "*.sqlite" -o -name "places.sqlite" \) -exec rm -f {} \; 2>/dev/null
rm -rf ~/.cache/mozilla/firefox/*

# Chromium or Google Chrome
rm -rf ~/.config/chromium/Default/{History,Cookies,Cache,VisitedLinks,Top Sites} 2>/dev/null
rm -rf ~/.cache/chromium/Default/* 2>/dev/null
rm -rf ~/.config/google-chrome/Default/{History,Cookies,Cache,VisitedLinks,Top Sites} 2>/dev/null
rm -rf ~/.cache/google-chrome/Default/* 2>/dev/null

### --- NETWORK INFO ---
echo "[*] Clearing NetworkManager and DHCP traces..."
rm -f /var/lib/NetworkManager/*lease*
rm -f /var/log/NetworkManager/* 2>/dev/null
rm -f /var/lib/dhcp/*

### --- SAFE LOG CLEANING (/var/log) ---
echo "[*] Cleaning safe /var/log entries..."
safe_logs=(
  /var/log/Xorg.0.log
  /var/log/Xorg.1.log
  /var/log/usb.log
  /var/log/pm-suspend.log
  /var/log/wpa_supplicant.log
  /var/log/lightdm/lightdm.log
  /var/log/lightdm/x-0.log
  /var/log/gdm3/*  # if gdm is in use
)

for log in "${safe_logs[@]}"; do
  [ -f "$log" ] && truncate -s 0 "$log" 2>/dev/null
  [ -d "$log" ] && find "$log" -type f -exec truncate -s 0 {} \; 2>/dev/null
done

echo "[+] Trace cleanup complete. GUI should remain stable."
