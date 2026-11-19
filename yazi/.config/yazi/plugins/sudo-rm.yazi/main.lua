local get_files = ya.sync(function()
	local files = {}

	for _, f in pairs(cx.active.selected) do
		files[#files + 1] = tostring(f.url)
	end

	if #files == 0 and cx.active.current.hovered then
		files[1] = tostring(cx.active.current.hovered.url)
	end

	return files
end)

return {
	entry = function()
		local files = get_files()
		local count = #files

		if count == 0 then
			return
		end

		local box_width = 60
		local inner_width = box_width - 2

		local body_lines = {}

		for i, path in ipairs(files) do
			if i > 10 then
				table.insert(
					body_lines,
					string.format("%-" .. inner_width .. "s", "...and " .. (count - 10) .. " more")
				)
				break
			end

			table.insert(body_lines, string.format("%-" .. inner_width .. "s", path))
		end

		local confirmed = ya.confirm({
			pos = { "center", w = box_width, h = 18 },
			title = string.format("Remove %d file%s with sudo?", count, count == 1 and "" or "s"),
			body = table.concat(body_lines, "\n"),
		})

		if confirmed then
			local args = {}

			for _, path in ipairs(files) do
				table.insert(args, "'" .. path:gsub("'", "'\\''") .. "'")
			end

			local command = "sudo rm -rf -- " .. table.concat(args, " ")

			ya.emit("shell", {
				command,
				block = true,
			})
		end
	end,
}
