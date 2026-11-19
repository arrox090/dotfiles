local terminal = "ghostty"
local browser = "helium-browser"
local menu = "nc -U /run/user/1000/walker/walker.sock"
local mainMod = "SUPER"

-- Standard Binds
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("hyprctl dispatch fullscreen 1"))

hl.bind(mainMod .. " + G", hl.dsp.exec_cmd(browser .. " https://github.com/arrox090?tab=repositories"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("~/test.sh"))

-- Lock screen
hl.bind(mainMod .. " + SHIFT + CTRL + L", hl.dsp.exec_cmd("hyprlock"))

-- Volume
hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%+"))
hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-"))

-- Music control
hl.bind(mainMod .. " + CTRL + N", hl.dsp.exec_cmd("playerctl next"))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("playerctl previous"))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.exec_cmd("playerctl -p spotifyd play-pause"))

-- Applications
hl.bind(mainMod .. " + CTRL + J", hl.dsp.exec_cmd(terminal .. " -e ~/.local/bin/spoti"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("walker --provider obsidiannotes"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("rofi-rbw"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal .. " -e ~/.cargo/bin/tgt"))

-- Keyboard layout
hl.bind(mainMod .. " + SHIFT + CTRL + ALT + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- Screenshots (Using Lua [[ ]] block strings to safely handle complex bash quotes/escapes)
hl.bind("ALT + SHIFT + 3", hl.dsp.exec_cmd([[grim ~/Pictures/screenshots/$(date +%Y%m%d-%H%M%S).png]]))
hl.bind("ALT + SHIFT + CTRL + 3", hl.dsp.exec_cmd([[grim - | wl-copy]]))
hl.bind("ALT + SHIFT + 4", hl.dsp.exec_cmd([[grim -g "$(slurp)" ~/Pictures/screenshots/$(date +%Y%m%d-%H%M%S).png]]))
hl.bind("ALT + SHIFT + CTRL + 4", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))

-- Move focus (Using native dispatchers)
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))

-- Move window
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("hyprctl dispatch movewindow u"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.exec_cmd("hyprctl dispatch movewindow d"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("hyprctl dispatch movewindow l"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprctl dispatch movewindow r"))

-- Simulate mouse click script
hl.bind("ALT + SHIFT + T", hl.dsp.exec_cmd("~/.local/bin/move-center-and-click"))

-- Workspaces 1-9
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. tostring(i), hl.dsp.focus({ workspace = tostring(i) }))
	hl.bind(mainMod .. " + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Workspace 0 (10)
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

-- Special workspace
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("hyprctl dispatch togglespecialworkspace magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ repeating = true, locked = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true, locked = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-----------------------------------------------------
-- TV STREAM LOCKDOWN SUBMAP
-----------------------------------------------------
-- hl.define_submap("tv_lockdown", function()
-- 	-- The Panic Button: ONLY works when the tv_lockdown submap is active
-- 	hl.bind("CTRL + ALT + SHIFT + Escape", hl.dsp.exec_cmd("/home/arrox090/.local/bin/sunshine-strumyk-undo.sh"))
-- end)
hl.define_submap("tv_lockdown", function()
	-- 1. The Panic Button: Escapes the stream and triggers UNDO script
	hl.bind("CTRL + ALT + SHIFT + Escape", hl.dsp.exec_cmd("/home/arrox090/.local/bin/sunshine-strumyk-undo.sh"))

	-- 2. The Kiosk Blackhole: Swallow all Ctrl + Letter combinations
	local keys = {
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
		"u",
		"v",
		"w",
		"x",
		"y",
		"z",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		"0",
	}
	for _, char in ipairs(keys) do
		hl.bind("CTRL + " .. char, hl.dsp.exec_cmd("true"))
		hl.bind("CTRL + SHIFT + " .. char, hl.dsp.exec_cmd("true"))
	end

	-- 3. Swallow other dangerous browser escape hatches
	hl.bind("CTRL + Tab", hl.dsp.exec_cmd("true"))
	hl.bind("CTRL + SHIFT + Tab", hl.dsp.exec_cmd("true"))
end)
-----------------------------------------------------

-- # Set programs that you use
-- $terminal = ghostty
-- $browser = helium-browser
-- $menu = nc -U /run/user/1000/walker/walker.sock
-- # $menu = anyrun
-- # $fileManager = dolphin
--
-- # See https://wiki.hypr.land/Configuring/Keywords/
-- $mainMod = SUPER # Sets "Windows" key as main modifier
--
-- # Example binds, see https://wiki.hypr.land/Configuring/Binds/ for more
-- bind = $mainMod, RETURN, exec, $terminal
-- bind = $mainMod, W, killactive,
-- # bind = $mainMod, M, exit,
-- # bind = $mainMod, E, exec, $fileManager
-- bind = $mainMod, B, exec, $browser
-- # bind = $mainMod, V, togglefloating,
-- bind = $mainMod, SPACE, exec, $menu
-- # bind = $mainMod, P, pseudo, # dwindle
-- # bind = $mainMod SHIFT, T, layoutmsg, togglesplit, # dwindle
-- bind = $mainMod SHIFT, F, fullscreen, 1
--
-- bind = $mainMod, G, exec, $browser https://github.com/arrox090?tab=repositories
-- bind = $mainMod, E, exec, ~/test.sh
--
-- # Lock the screen
-- bind = $mainMod SHIFT CTRL, L, exec, hyprlock
--
-- # Change volume with mainMod + plus/minus by 5%
-- bind = $mainMod, equal, exec, wpctl set-volume @DEFAULT_SINK@ 5%+
-- bind = $mainMod, minus, exec, wpctl set-volume @DEFAULT_SINK@ 5%-
--
-- # pause music / play next / previous
-- bind = $mainMod CTRL, N, exec, playerctl next
-- bind = $mainMod CTRL, P, exec, playerctl previous
-- bind = $mainMod CTRL, K, exec, playerctl -p spotifyd play-pause
--
-- # Open spotify tui in a terminal window
-- bind = $mainMod CTRL, J, exec, $terminal -e ~/.local/bin/spoti
--
-- # Open provider for opening and managing obsidian notes
-- bind = $mainMod, O, exec, walker --provider obsidiannotes
--
-- # rofi-rbw (copy/type bitwarden passwords/usernames)
-- bind = $mainMod, P, exec, rofi-rbw
--
-- # tgt (telegram tui)
-- bind = $mainMod, T, exec, $terminal -e ~/.cargo/bin/tgt
--
-- # Hard to hit change layout keybind
-- bind = $mainMod SHIFT CTRL ALT, SPACE, exec, hyprctl switchxkblayout all next
--
-- # 1. Full screen screenshot saved to directory
-- bind = ALT SHIFT, 3, exec, grim ~/Pictures/screenshots/$(date +%Y%m%d-%H%M%S).png
-- # 2. Full screen screenshot to clipboard
-- bind = ALT SHIFT CTRL, 3, exec, grim - | wl-copy
-- # 3. Select area and save to directory
-- bind = ALT SHIFT, 4, exec, grim -g "$(slurp)" ~/Pictures/screenshots/$(date +%Y%m%d-%H%M%S).png
-- # 4. Select area and copy to clipboard
-- bind = ALT SHIFT CTRL, 4, exec, grim -g "$(slurp)" - | wl-copy
--
-- # Move focus with mainMod + vim keys
-- bind = $mainMod, K, movefocus, u
-- bind = $mainMod, J, movefocus, d
-- bind = $mainMod, H, movefocus, l
-- bind = $mainMod, L, movefocus, r
--
-- # Move panes up/down/left/right with mainMod + shift + vim keys TODO:
-- bind = $mainMod SHIFT, K, movewindow, u
-- bind = $mainMod SHIFT, J, movewindow, d
-- bind = $mainMod SHIFT, H, movewindow, l
-- bind = $mainMod SHIFT, L, movewindow, r
--
-- # Simulate mouse click (useful if you cant click the chat in gemini and to scroll without reaching out for the mouse)
-- bind = ALT SHIFT, T, exec, ~/.local/bin/move-center-and-click
--
-- # Switch workspaces with mainMod + [0-9]
-- bind = $mainMod, 1, workspace, 1
-- bind = $mainMod, 2, workspace, 2
-- bind = $mainMod, 3, workspace, 3
-- bind = $mainMod, 4, workspace, 4
-- bind = $mainMod, 5, workspace, 5
-- bind = $mainMod, 6, workspace, 6
-- bind = $mainMod, 7, workspace, 7
-- bind = $mainMod, 8, workspace, 8
-- bind = $mainMod, 9, workspace, 9
-- bind = $mainMod, 0, workspace, 10
--
-- # Move active window to a workspace with mainMod + SHIFT + [0-9]
-- bind = $mainMod SHIFT, 1, movetoworkspace, 1
-- bind = $mainMod SHIFT, 2, movetoworkspace, 2
-- bind = $mainMod SHIFT, 3, movetoworkspace, 3
-- bind = $mainMod SHIFT, 4, movetoworkspace, 4
-- bind = $mainMod SHIFT, 5, movetoworkspace, 5
-- bind = $mainMod SHIFT, 6, movetoworkspace, 6
-- bind = $mainMod SHIFT, 7, movetoworkspace, 7
-- bind = $mainMod SHIFT, 8, movetoworkspace, 8
-- bind = $mainMod SHIFT, 9, movetoworkspace, 9
-- bind = $mainMod SHIFT, 0, movetoworkspace, 10
--
-- # Example special workspace (scratchpad)
-- bind = $mainMod, S, togglespecialworkspace, magic
-- bind = $mainMod SHIFT, S, movetoworkspace, special:magic
--
-- # Scroll through existing workspaces with mainMod + scroll
-- bind = $mainMod, mouse_down, workspace, e+1
-- bind = $mainMod, mouse_up, workspace, e-1
--
-- # Move/resize windows with mainMod + LMB/RMB and dragging
-- bindm = $mainMod, mouse:272, movewindow
-- bindm = $mainMod, mouse:273, resizewindow
--
-- # Laptop multimedia keys for volume and LCD brightness
-- bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
-- bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
-- bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
-- bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
-- bindel = ,XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+
-- bindel = ,XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-
--
-- # Requires playerctl
-- bindl = , XF86AudioNext, exec, playerctl next
-- bindl = , XF86AudioPause, exec, playerctl play-pause
-- bindl = , XF86AudioPlay, exec, playerctl play-pause
-- bindl = , XF86AudioPrev, exec, playerctl previous
