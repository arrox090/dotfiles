Name = "obsidiannotesOLD"
NamePretty = "Obsidian Notes Old"
Icon = "applications-other"
Cache = false
Action = "obsidian-cli open '%VALUE%' && hyprctl dispatch focuswindow class:obsidian"
HideFromProviderlist = true
Description = "Manage obsidian notes"
SearchName = true

function GetEntries(query)
	local entries = {}
	local notes_dir = os.getenv("HOME") .. "/notes"
	local trash_dir = notes_dir .. "/.trash"
	local prefix = ""

	if query then
		prefix = query:sub(1, 1)
	end

	if prefix == "-" then
		local handle = io.popen("find '" .. trash_dir .. "' -type f -name '*.md' 2>/dev/null")
		if handle then
			for line in handle:lines() do
				local local_path = line:gsub(trash_dir .. "/", "")
				local filename = local_path:match("([^/]+)$")
				local dir = local_path:match("(.+)/") or ""
				if filename then
					table.insert(entries, {
						Text = "-" .. filename,
						Subtext = dir,
						Value = local_path,
						Actions = {
							restore = "mkdir -p '"
								.. notes_dir
								.. "/"
								.. dir
								.. "' && mv '"
								.. line
								.. "' '"
								.. notes_dir
								.. "/"
								.. local_path
								.. "' &&  find '"
								.. trash_dir
								.. "' -type d -empty -delete",
							delete = "rm '" .. line .. "' && find '" .. trash_dir .. "' -type d -empty -delete",
						},
						Preview = line,
						PreviewType = "file",
						-- Icon = line,
					})
				end
			end
			handle:close()
		end
	elseif prefix == "+" then
		local note_name
		if query:sub(2) ~= "" then
			note_name = query:sub(2)
		else
			note_name = "Untitled"
		end
		if note_name:match("/$") then
			note_name = note_name .. "Untitled"
		end

		table.insert(entries, {
			Text = note_name:gsub("^/+", "") .. ".md",
			Subtext = "+create note '" .. note_name .. "'",
			Actions = {
				create = "lua:CreateNote",
			},
		})
	else
		local handle = io.popen("find '" .. notes_dir .. "' -not -path '*/.*' -type f -name '*.md' 2>/dev/null")
		if handle then
			for line in handle:lines() do
				local local_path = line:gsub(notes_dir .. "/", "")
				local filename = local_path:match("([^/]+)$")
				local dir = local_path:match("(.+)/") or ""
				if filename then
					table.insert(entries, {
						Text = filename,
						Subtext = dir,
						Value = local_path,
						Actions = {
							open = "obsidian-cli open '"
								.. local_path
								.. "' && hyprctl dispatch focuswindow class:obsidian",
							delete = "mkdir -p '"
								.. trash_dir
								.. "/"
								.. dir
								.. "' && mv '"
								.. line
								.. "' '"
								.. trash_dir
								.. "/"
								.. local_path
								.. "' &&  find '"
								.. notes_dir
								.. "' -not -path '*/.*' -type d -empty -delete",
							rename = "",
						},
						Preview = line,
						PreviewType = "file",
						-- Icon = line,
					})
				end
			end
			handle:close()
		end
	end

	return entries
end

function CreateNote(value, args, query)
	local note_name = query:gsub("^/+", ""):sub(2)
	os.execute("obsidian-cli create '" .. note_name .. "' --open")
	os.execute("hyprctl dispatch focuswindow class:obsidian")
end
