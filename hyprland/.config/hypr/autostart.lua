local terminal = "ghostty"
local browser = "helium-browser"
local menu = "nc -U /run/user/1000/walker/walker.sock"

-- Open terminal at start and open a tmux session with tmuxifier
hl.on("hyprland.start", function()
	-- hl.dispatch(hl.dsp.exec_cmd("~/.config/hypr/launch_browser.sh helium-browser", { workspace = "1" }))
	hl.dispatch(hl.dsp.exec_cmd("[workspace 1 silent] ~/.config/hypr/launch_browser.sh helium-browser"))
	hl.dispatch(hl.dsp.exec_cmd("[workspace 2 silent] ghostty -e ~/.tmuxifier/bin/tmuxifier load-session arch-setup"))
	-- hl.dispatch(hl.dsp.focus({ workspace = 2 }))

	hl.exec_cmd("waybar")
	hl.exec_cmd("hyprpaper")
	-- hl.exec_cmd("walker --gapplication-service & elephant")
	hl.exec_cmd("walker --gapplication-service")
	hl.exec_cmd("mako")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1")
	-- hl.exec_cmd("hypridle")
	--
	-- hl.exec_cmd("sleep 1.5 && hyprctl dispatch workspace 2 && hyprctl dispatch focuswindow ghostty")
	hl.exec_cmd("sleep 2")
	hl.dispatch(hl.dsp.focus({ workspace = 2 }))
	hl.dispatch(hl.dsp.focus({ window = "class:com.mitchellh.ghostty" }))
	-- hl.exec_cmd("sleep 2 && hyprlock")
	hl.exec_cmd("hyprlock")
end)

-- # Set programs that you use
-- $terminal = ghostty
-- $browser = helium-browser
-- $menu = nc -U /run/user/1000/walker/walker.sock
-- # $menu = anyrun
-- # $fileManager = dolphin
--
--
-- # Open terminal at start and open a tmux session with tmuxifier
-- exec-once = [workspace 2] $terminal -e ~/.tmuxifier/bin/tmuxifier load-session arch-setup
-- # Open browser on secondary monitor
-- exec-once = [workspace 1 silent] ~/.config/hypr/launch_browser.sh $browser
-- # exec-once = nm-applet &
-- exec-once = waybar & hyprpaper
-- # exec-once = anyrun daemon & ~/.local/bin/file-search-daemon
-- exec-once = walker --gapplication-service & elephant
-- exec-once = mako
-- exec-once = systemctl --user start hyprpolkitagent
-- exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
-- exec-once = hypridle
-- # Lock the screen at start as we are autologging (launch after other apps as there are issues if we lock first)
-- exec-once = sleep 2 && hyprlock
