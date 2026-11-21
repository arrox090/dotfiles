-- Lock workspaces to monitors
hl.workspace_rule({ workspace = "2", monitor = "DP-3" })
hl.workspace_rule({ workspace = "3", monitor = "DP-3" })
hl.workspace_rule({ workspace = "1", monitor = "DP-2" })

-- Ignore maximize requests from apps
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- When floating, change the opacity of ghostty
hl.window_rule({ match = { class = "^(com.mitchellh.ghostty)$", float = true }, opacity = "0.65 0.65" })

-- Lock programs to workspaces
-- hl.window_rule({ match = { class = "^(helium)$" }, workspace = 1 })
hl.window_rule({ match = { class = "^(obsidian)$" }, workspace = 3 })

-- # lock workspaces to monitors
-- workspace = 2, monitor:DP-3
-- workspace = 3, monitor:DP-3
--
-- workspace = 1, monitor:DP-2
--
--
-- # Ignore maximize requests from apps
-- windowrule = match:class .*, suppress_event maximize
--
-- # when floating, change the opacity of ghostty
-- windowrule = match:class ^(com.mitchellh.ghostty)$, match:float on, opacity 0.65 0.65
--
-- # lock programs to workspaces
-- windowrule = match:class ^(helium)$, workspace 1
-- windowrule = match:class ^(obsidian)$, workspace 3
--
-- # Fix some dragging issues with XWayland
-- # windowrule = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0
