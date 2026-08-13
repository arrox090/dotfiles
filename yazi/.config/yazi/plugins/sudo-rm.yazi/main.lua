local get_files = ya.sync(function()
	local files = {}

	for k, v in pairs(cx.active.selected) do
		local url = type(k) == "number" and v or k
		table.insert(files, tostring(url))
	end

	if #files == 0 and cx.active.current.hovered then
		table.insert(files, tostring(cx.active.current.hovered.url))
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

		local title = string.format("Remove %d file%s with sudo?", count, count == 1 and "" or "s")

		-- Define the box width so we can match our text padding to it
		local box_width = 60
		local inner_width = box_width - 2 -- Account for the left and right border walls

		local body_lines = {}
		for i, path in ipairs(files) do
			if i > 10 then
				local more_text = string.format("...and %d more", count - 10)
				-- Pad the "and more" text to force left alignment
				table.insert(body_lines, string.format("%-" .. inner_width .. "s", more_text))
				break
			end

			-- Pad the file path with spaces to force left alignment
			table.insert(body_lines, string.format("%-" .. inner_width .. "s", path))
		end

		local confirmed = ya.confirm({
			pos = { "center", w = box_width, h = 18 },
			title = title,
			body = table.concat(body_lines, "\n"),
		})

		if confirmed then
			ya.emit("shell", { 'sudo rm -rf "$@"', block = true })
		end
	end,
}
