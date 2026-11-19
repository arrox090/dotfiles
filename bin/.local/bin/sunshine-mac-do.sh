#!/bin/bash
set -a
source "$HOME/.config/sunshine-mac/secrets.env"
set +a
source "$HOME/.local/lib/sunshine-scripts/notify.sh"

#TODO: update so that hyprland doesnt use || as it sometimes exits with 0 just check if the out is 0 and add logging for all files
# ------------------- LOGGING -------------------
LOG_DIR="$HOME/.local/state/sunshine-scripts"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/mac.log"
# if gets over 1mb rotate to .old (so max 2 files one old one new both max 1mb)
[ -f "$LOG" ] && [ "$(stat -c%s "$LOG")" -gt 1000000 ] && mv "$LOG" "$LOG.old"
# Everything that echos goes to that log file
exec >>"$LOG" 2>&1
echo "=== $(date '+%F %T') $(basename "$0") start ==="

# ------------------- CLIENT AUTHORIZATION -------------------
# Check if disallowed IP, if so then disconnect the client
DISALLOWED_IP="192.168.10.41" # android TV

client_ip=$(ss -Hnt '( sport = :47984 or sport = :47989 or sport = :48010 )' | awk '{print $5}' | sed -E 's/.*:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/' | head -n1 | cut -d":" -f1)
# echo $client_ip >/tmp/sunshine-client
if [ "$client_ip" == "$DISALLOWED_IP" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Unauthorized connection attempt from: $client_ip" >>/tmp/sunshine-unauthorized.log
  curl -s -k -X POST -u "${SUNSHINE_USER}:${SUNSHINE_PASS}" "https://localhost:47990/api/apps/close"
  echo "failed" >/tmp/sunshine-last-access
  exit 1
fi

# ------------------- SET UP EVERYTHING -------------------
# Unlock screen
pkill -USR1 hyprlock

# Disable physical desk keyboard and mouse
hyprctl eval 'hl.device({ name = "razer-razer-viper-v3-pro", enabled = false })' || {
  notify "Sunshine Mac Do ERROR" 'Failed to disable razer viper v3 pro mouse!'
}

hyprctl eval 'hl.device({ name = "keyd-virtual-keyboard", enabled = false })' || {
  notify "Sunshine Mac Do ERROR" 'Failed to disable keyd virtual keyboard!'
}

# Create virtual display and change its resolution
hyprctl output create headless virtual-display || {
  notify "Sunshine Mac Do ERROR" 'Failed to create a virtual display!'
  exit 1
}
hyprctl eval 'hl.monitor({ output = "virtual-display", mode = "1920x1080@60", position = "auto", scale = 1.0 })' || {
  notify "Sunshine Mac Do ERROR" 'Failed to change resolution of the virtual display!'
}

# PERHAPS CAN ONLY DISABLE ONE MONITOR cause other one doesnt come back? check
# hyprctl dispatch 'hl.dsp.dpms({ action = "disable", monitor = "DP-2" })'
# hyprctl dispatch 'hl.dsp.dpms({ action = "disable", monitor = "DP-3" })'

# Disable Physical Screens
hyprctl eval 'hl.monitor({ output = "DP-3", disabled = true })' || {
  notify "Sunshine Mac Do ERROR" 'Failed to disable monitor DP-3!'
}
hyprctl eval 'hl.monitor({ output = "DP-2", disabled = true })' || {
  notify "Sunshine Mac Do ERROR" 'Failed to disable monitor DP-2!'
}

# Disable Keyd remaps and reload
sudo mv /etc/keyd/default.conf /etc/keyd/default.conf.disabled || {
  notify "Sunshine Mac Do ERROR" 'Failed to move keyd config to disabled!'
}
sudo keyd reload || {
  notify "Sunshine Mac Do ERROR" 'Failed to reload keyd!'
}
echo "succeded" >/tmp/sunshine-last-access

# --------------- SETUP IN SUNSHINE ----------------
# DO COMMAND: systemd-run --user --unit=mac-do --collect --service-type=simple /home/arrox090/.local/bin/sunshine-mac-do.sh
