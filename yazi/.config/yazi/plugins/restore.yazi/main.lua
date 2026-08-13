local get_state = ya.sync(function()
	local h = cx.active.current.hovered
	if not h then
		return nil
	end
	return {
		url = tostring(h.url),
		filename = h.name,
		is_trash = tostring(cx.active.current.cwd):match("%.Trash$") ~= nil,
	}
end)
return {
	entry = function()
		local state = get_state()
		if not state then
			return
		end
		if not state.is_trash then
			ya.notify({ title = "Restore", content = "You are not in the Trash.", timeout = 3, level = "warn" })
			return
		end
		local handle = io.popen("uname -s")
		local os_name = handle and handle:read("*a"):gsub("%s+", "") or ""
		if handle then
			handle:close()
		end
		if os_name ~= "Darwin" then
			ya.notify({
				title = "Restore",
				content = "Put Back is only supported on macOS.",
				timeout = 3,
				level = "warn",
			})
			return
		end
		local confirmed = ya.confirm({
			pos = { "center", w = 60, h = 18 },
			title = "Restore 1 selected file?",
			body = state.url,
		})
		if confirmed then
			local safe_name = state.filename:gsub('"', '\\"')
			local path_file = "/tmp/yazi_restore_path.txt"
			local status_file = "/tmp/yazi_restore_status.txt"
			os.remove(path_file)
			os.remove(status_file)
			-- Checks if "Put Back" is enabled before clicking; captures the path of the newly opened destination window
			local script_content = string.format(
				[[
                set destPath to ""
                set statusResult to "ok"
                tell application "Finder"
                    set initialWindows to name of windows
                    activate
                    open trash
                    select (file "%s" of trash)
                end tell
                tell application "System Events"
                    tell process "Finder"
                        set pbItem to menu item "Put Back" of menu "File" of menu bar 1
                        if enabled of pbItem then
                            click pbItem
                        else
                            set statusResult to "disabled"
                        end if
                    end tell
                end tell
                do shell script "echo " & quoted form of statusResult & " > " & quoted form of "%s"
                if statusResult is "ok" then
                    delay 0.8
                    tell application "Finder"
                        try
                            close window "Trash"
                        end try
                        set currentWindows to windows
                        repeat with w in currentWindows
                            if (name of w) is not in initialWindows then
                                try
                                    set destPath to POSIX path of (target of w as alias)
                                    close w
                                    exit repeat
                                end try
                            end if
                        end repeat
                    end tell
                    if destPath is not "" then
                        do shell script "echo " & quoted form of destPath & " > " & quoted form of "%s"
                    end if
                else
                    tell application "Finder"
                        try
                            close window "Trash"
                        end try
                    end tell
                end if
            ]],
				safe_name,
				status_file,
				path_file
			)
			local script_file = io.open("/tmp/yazi_restore.scpt", "w")
			if script_file then
				script_file:write(script_content)
				script_file:close()
				os.execute("osascript /tmp/yazi_restore.scpt")

				local status = "ok"
				local sf = io.open(status_file, "r")
				if sf then
					status = sf:read("*a"):gsub("%s+", "")
					sf:close()
				end

				if status == "disabled" then
					ya.notify({
						title = "Restore",
						content = "Put Back is disabled for this item (original location no longer exists).",
						timeout = 3,
						level = "warn",
					})
					return
				end

				-- Read the path captured from the window and jump Yazi there, highlighting the file
				local f = io.open(path_file, "r")
				if f then
					local dest_folder = f:read("*a"):gsub("%s+", "")
					f:close()
					if dest_folder ~= "" then
						ya.emit("reveal", { dest_folder .. "/" .. state.filename })
						ya.notify({
							title = "Restore",
							content = "File restored and focused!",
							timeout = 3,
							level = "info",
						})
					end
				end
			end
		end
	end,
}
