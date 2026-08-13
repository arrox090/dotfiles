local M = {}

local function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

-- Get the files that need to be compressed and infer a default archive name
local get_compression_target = ya.sync(function()
	local tab = cx.active
	local default_name
	local paths = {}
	if #tab.selected == 0 then
		if tab.current.hovered then
			local name = tab.current.hovered.name
			default_name = name
			table.insert(paths, name)
		else
			return
		end
	else
		default_name = tab.current.cwd.name
		for _, url in pairs(tab.selected) do
			table.insert(paths, tostring(url))
		end
		-- The compression targets are aquired, now unselect them
		ya.emit("escape", {})
	end
	return paths, default_name
end)

local function invoke_compress_command(paths, name)
	local cmd_output, err_code = Command("7zz"):arg("a"):arg(name):arg(paths):stderr(Command.PIPED):output()

	if err_code ~= nil then
		ya.notify({
			title = "Failed to run 7zz command",
			content = "Status: " .. err_code,
			timeout = 5.0,
			level = "error",
		})
	elseif not cmd_output.status.success then
		ya.notify({
			title = "Compression failed: status code " .. tostring(cmd_output.status.code),
			content = cmd_output.stderr,
			timeout = 5.0,
			level = "error",
		})
	else
		ya.notify({
			title = "Compress",
			content = "Successfully created " .. name,
			timeout = 3.0,
			level = "info",
		})
	end
end

function M:entry(job)
	local default_fmt = job.args[1]
	if default_fmt == nil then
		default_fmt = "zip"
	end

	ya.emit("escape", { visual = true })

	-- Get the files that need to be compressed and infer a default archive name
	local paths, default_name = get_compression_target()

	-- Get archive name from user
	local output_name, name_event = ya.input({
		title = "Create archive:",
		value = default_name .. "." .. default_fmt,
		pos = { "top-center", y = 3, w = 40 },
	})
	if name_event ~= 1 then
		return
	end

	-- Get confirmation if file exists
	if file_exists(output_name) then
		local confirm, confirm_event = ya.input({
			title = "Overwrite " .. output_name .. "? (y/N)",
			pos = { "top-center", y = 3, w = 40 },
		})
		if not (confirm_event == 1 and confirm:lower() == "y") then
			return
		end
	end

	invoke_compress_command(paths, output_name)
end

return M
