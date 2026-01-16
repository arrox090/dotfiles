#!/bin/bash

# exec > /tmp/moonlight_debug.log 2>&1
# echo "Script started at $(date)"
# echo "Hyprland Signature: $HYPRLAND_INSTANCE_SIGNATURE"
# echo "XDG Runtime: $XDG_RUNTIME_DIR"

# --------------- SETUP IN SUNSHINE ----------------
# DO COMMAND: systemd-run --user --unit=moonlight-monitor-switch --collect --service-type=simple /home/arrox090/.local/bin/auto-switch-monitor-moonlight-mac.sh
# UNDO COMMAND: pkill -f auto-switch-monitor-moonlight-mac.sh

# Handle the monitor change event
handle() {
  # $1 comes in as "focusedmon>>MonitorName,WorkspaceId"
  # We strip the "focusedmon>>" part
  event=${1:12}
  
  # Split into Monitor Name and Workspace ID
  monitor_name=$(echo $event | cut -d ',' -f 1)
  
  # 122 key code - f1, 120 key code - f2
  if [[ "$monitor_name" == "DP-2" ]]; then
      # You are on Monitor 1
      # echo "Switched to Secondary Monitor (DP-2)"
      ssh macjan "osascript -e 'tell application \"System Events\" to key code 122 using {control down, option down, shift down}'"
  elif [[ "$monitor_name" == "DP-3" ]]; then
      # You are on Monitor 2
      # echo "Switched to Primary Monitor (DP-3)"
      ssh macjan "osascript -e 'tell application \"System Events\" to key code 120 using {control down, option down, shift down}'"
  fi
}

# Listen to the Hyprland Socket
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
  if [[ "$line" == "focusedmon>>"* ]]; then
    handle "$line"
  fi
done
