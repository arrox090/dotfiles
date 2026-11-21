#!/bin/bash
set -a
source "$HOME/.config/sunshine-mac/secrets.env"
set +a
source "$HOME/.local/lib/sunshine-scripts/notify.sh"

# If the connection was immediately cut (disallowed ip tried to connect), nothing was done so exit
if [[ -f "/tmp/sunshine-last-access" ]]; then
	contents=$(cat /tmp/sunshine-last-access)
	if [[ "$contents" == "failed" ]]; then
		exit 0
	fi
fi

# Enable back physical desk keyboard and mouse
hyprctl eval 'hl.device({ name = "razer-razer-viper-v3-pro", enabled = true })' || {
	notify "Sunshine Mac Undo ERROR" 'Failed to enable razer viper v3 pro mouse!'
}

hyprctl eval 'hl.device({ name = "keyd-virtual-keyboard", enabled = true })' || {
	notify "Sunshine Mac Undo ERROR" 'Failed to enable keyd virtual keyboard!'
}

# Enable back Physical Screens
hyprctl eval 'hl.monitor({ output = "DP-2", disabled = false })' || {
	notify "Sunshine Mac Undo ERROR" "Failed to enable monitor DP-2!"
}

hyprctl eval 'hl.monitor({ output = "DP-3", disabled = false })' || {
	notify "Sunshine Mac Undo ERROR" "Failed to enable monitor DP-3!"
}

# Delete the virtual display created only for this session
hyprctl output remove virtual-display || {
	notify "Sunshine Mac Undo ERROR" "Failed to remove the virtual display!"
}

# Enable Keyd remaps back and reload
sudo mv /etc/keyd/default.conf.disabled /etc/keyd/default.conf || {
	notify "Sunshine Mac Undo ERROR" "Failed to move keyd config back from disabled!"
}
sudo keyd reload || {
	notify "Sunshine Mac Undo ERROR" 'Failed to reload keyd!'
}

# Lock screen
hyprctl dispatch 'hl.dsp.exec_cmd("hyprlock")' || {
	notify "Sunshine Mac Undo ERROR" 'Failed to Lock the screen with hyprlock!'
}
