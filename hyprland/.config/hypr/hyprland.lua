local colors = require("mocha")

-- Source other config files
require("autostart")
require("keybinds")
require("windowrules-workspaces")

-- Monitors
hl.monitor({ output = "DP-2", mode = "2560x1440@165", position = "0x0", scale = 1.25 })
hl.monitor({ output = "DP-3", mode = "3840x2160@60", position = "auto", scale = 1.5 })

-- Environment Variables
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Configuration
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,
		border_size = 2,
		-- Lua requires bracket syntax for keys that contain periods
		["col.active_border"] = colors.blue,
		["col.inactive_border"] = colors.surface0,
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 10,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			-- Hardcoded to avoid rgba(rgb(hex)) nesting conflict from the theme file
			color = "rgba(1e1e2eee)",
		},
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
	animations = {
		enabled = true,
		bezier = {
			{ "easeOutQuint", "0.23, 1, 0.32, 1" },
			{ "easeInOutCubic", "0.65, 0.05, 0.36, 1" },
			{ "linear", "0, 0, 1, 1" },
			{ "almostLinear", "0.5, 0.5, 0.75, 1" },
			{ "quick", "0.15, 0, 0.1, 1" },
		},
		animation = {
			{ "global", "1, 10, default" },
			{ "border", "1, 5.39, easeOutQuint" },
			{ "windows", "1, 4.79, easeOutQuint" },
			{ "windowsIn", "1, 4.1, easeOutQuint, popin 87%" },
			{ "windowsOut", "1, 1.49, linear, popin 87%" },
			{ "fadeIn", "1, 1.73, almostLinear" },
			{ "fadeOut", "1, 1.46, almostLinear" },
			{ "fade", "1, 3.03, quick" },
			{ "layers", "1, 3.81, easeOutQuint" },
			{ "layersIn", "1, 4, easeOutQuint, fade" },
			{ "layersOut", "1, 1.5, linear, fade" },
			{ "fadeLayersIn", "1, 1.79, almostLinear" },
			{ "fadeLayersOut", "1, 1.39, almostLinear" },
			{ "workspaces", "1, 1.94, almostLinear, fade" },
			{ "workspacesIn", "1, 1.21, almostLinear, fade" },
			{ "workspacesOut", "1, 1.94, almostLinear, fade" },
			{ "zoomFactor", "1, 7, quick" },
		},
	},
	dwindle = { preserve_split = true },
	master = { new_status = "master" },
	misc = {
		focus_on_activate = true,
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
	input = {
		kb_layout = "us,pl",
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = { natural_scroll = false },
	},
})

-- Gestures and Devices (Converted to proper Lua dictionaries)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

-- source = ~/.config/hypr/mocha.conf
-- source = ~/.config/hypr/keybinds.conf
-- source = ~/.config/hypr/windowrules-workspaces.conf
-- source = ~/.config/hypr/autostart.conf
--
--
-- ################
-- ### MONITORS ###
-- ################
--
-- # See https://wiki.hypr.land/Configuring/Monitors/
-- monitor = DP-3,3840x2160@60,auto,1.5
-- monitor = DP-2,2560x1440@165,0x0,1.25
--
--
-- #############################
-- ### ENVIRONMENT VARIABLES ###
-- #############################
--
-- # See https://wiki.hypr.land/Configuring/Environment-variables/
--
-- # For Nvidia
-- env = LIBVA_DRIVER_NAME,nvidia
-- env = __GLX_VENDOR_LIBRARY_NAME,nvidia
--
-- # Rest
-- env = XCURSOR_SIZE,24
-- env = HYPRCURSOR_SIZE,24
--
-- # env = ELECTRON_OZONE_PLATFORM_HINT,auto
--
--
-- ###################
-- ### PERMISSIONS ###
-- ###################
--
-- # See https://wiki.hypr.land/Configuring/Permissions/
-- # Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- # for security reasons
--
-- # ecosystem {
-- #   enforce_permissions = 1
-- # }
--
-- # permission = /usr/(bin|local/bin)/grim, screencopy, allow
-- # permission = /usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow
-- # permission = /usr/(bin|local/bin)/hyprpm, plugin, allow
--
--
-- #####################
-- ### LOOK AND FEEL ###
-- #####################
--
-- # Refer to https://wiki.hypr.land/Configuring/Variables/
--
-- # https://wiki.hypr.land/Configuring/Variables/#general
-- general {
--     gaps_in = 5
--     gaps_out = 20
--
--     border_size = 2
--
--     # https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
--     col.active_border = $blue
--     col.inactive_border = $surface0
--
--     # Set to true enable resizing windows by clicking and dragging on borders and gaps
--     resize_on_border = false
--
--     # Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
--     allow_tearing = false
--
--     layout = dwindle
-- }
--
-- # https://wiki.hypr.land/Configuring/Variables/#decoration
-- decoration {
--     rounding = 10
--     rounding_power = 2
--
--     # Change transparency of focused and unfocused windows
--     active_opacity = 1.0
--     inactive_opacity = 1.0
--
--     shadow {
--         enabled = true
--         range = 4
--         render_power = 3
--         color = rgba($baseAlphaee)
--     }
--
--     # https://wiki.hypr.land/Configuring/Variables/#blur
--     blur {
--         enabled = true
--         size = 3
--         passes = 1
--
--         vibrancy = 0.1696
--     }
-- }
--
-- # https://wiki.hypr.land/Configuring/Variables/#animations
-- animations {
--     enabled = yes, please :)
--
--     # Default curves, see https://wiki.hypr.land/Configuring/Animations/#curves
--     #        NAME,           X0,   Y0,   X1,   Y1
--     bezier = easeOutQuint,   0.23, 1,    0.32, 1
--     bezier = easeInOutCubic, 0.65, 0.05, 0.36, 1
--     bezier = linear,         0,    0,    1,    1
--     bezier = almostLinear,   0.5,  0.5,  0.75, 1
--     bezier = quick,          0.15, 0,    0.1,  1
--
--     # Default animations, see https://wiki.hypr.land/Configuring/Animations/
--     #           NAME,          ONOFF, SPEED, CURVE,        [STYLE]
--     animation = global,        1,     10,    default
--     animation = border,        1,     5.39,  easeOutQuint
--     animation = windows,       1,     4.79,  easeOutQuint
--     animation = windowsIn,     1,     4.1,   easeOutQuint, popin 87%
--     animation = windowsOut,    1,     1.49,  linear,       popin 87%
--     animation = fadeIn,        1,     1.73,  almostLinear
--     animation = fadeOut,       1,     1.46,  almostLinear
--     animation = fade,          1,     3.03,  quick
--     animation = layers,        1,     3.81,  easeOutQuint
--     animation = layersIn,      1,     4,     easeOutQuint, fade
--     animation = layersOut,     1,     1.5,   linear,       fade
--     animation = fadeLayersIn,  1,     1.79,  almostLinear
--     animation = fadeLayersOut, 1,     1.39,  almostLinear
--     animation = workspaces,    1,     1.94,  almostLinear, fade
--     animation = workspacesIn,  1,     1.21,  almostLinear, fade
--     animation = workspacesOut, 1,     1.94,  almostLinear, fade
--     animation = zoomFactor,    1,     7,     quick
-- }
--
-- # Ref https://wiki.hypr.land/Configuring/Workspace-Rules/
-- # "Smart gaps" / "No gaps when only"
-- # uncomment all if you wish to use that.
-- # workspace = w[tv1], gapsout:0, gapsin:0
-- # workspace = f[1], gapsout:0, gapsin:0
-- # windowrule = bordersize 0, floating:0, onworkspace:w[tv1]
-- # windowrule = rounding 0, floating:0, onworkspace:w[tv1]
-- # windowrule = bordersize 0, floating:0, onworkspace:f[1]
-- # windowrule = rounding 0, floating:0, onworkspace:f[1]
--
-- # See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more
-- dwindle {
--     preserve_split = true # You probably want this
-- }
--
-- # See https://wiki.hypr.land/Configuring/Master-Layout/ for more
-- master {
--     new_status = master
-- }
--
-- # https://wiki.hypr.land/Configuring/Variables/#misc
-- misc {
--     focus_on_activate = true
--     force_default_wallpaper = 0 # Set to 0 or 1 to disable the anime mascot wallpapers
--     disable_hyprland_logo = true # If true disables the random hyprland logo / anime girl background. :(
-- }
--
--
-- #############
-- ### INPUT ###
-- #############
--
-- # https://wiki.hypr.land/Configuring/Variables/#input
-- input {
--     kb_layout = us,pl
--     kb_variant =
--     kb_model =
--     kb_options =
--     kb_rules =
--
--     follow_mouse = 1
--
--     sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
--
--     touchpad {
--         natural_scroll = false
--     }
-- }
--
-- # See https://wiki.hypr.land/Configuring/Gestures
-- gesture = 3, horizontal, workspace
--
-- # Example per-device config
-- # See https://wiki.hypr.land/Configuring/Keywords/#per-device-input-configs for more
-- device {
--     name = epic-mouse-v1
--     sensitivity = -0.5
-- }
--
