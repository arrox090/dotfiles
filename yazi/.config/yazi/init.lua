-- Global cache so we only count files ONCE per hover
_G.folder_count_cache = _G.folder_count_cache or {}
_G.last_hovered_url = _G.last_hovered_url or ""

function Linemode:custom()
	-- local perm = self._file.cha:perm() or ""

	local time = math.floor(self._file.cha.mtime or 0)
	local time_str = (time > 0) and os.date("%b %d %H:%M", time) or ""

	local size_str = "-"
	local current_url = tostring(self._file.url)

	-- Safely initialize the cache if it doesn't exist yet
	_G.folder_count_cache = _G.folder_count_cache or {}

	if self._file.cha.is_dir then
		-- Check if we are currently hovering over this exact folder
		local is_hovered = (cx.active.current.hovered and tostring(cx.active.current.hovered.url) == current_url)

		if is_hovered then
			-- If it's a new hover, run the calculation ONCE and cache it
			if _G.last_hovered_url ~= current_url then
				_G.last_hovered_url = current_url
				local handle = io.popen('ls -1A "' .. current_url .. '" 2>/dev/null | wc -l')
				if handle then
					local res = handle:read("*a"):gsub("%s+", "")
					handle:close()
					_G.folder_count_cache[current_url] = (tonumber(res) or 0) .. " items"
				end
			end
		end

		-- Serve the string from the cache (or "-" if it hasn't been hovered yet)
		size_str = _G.folder_count_cache[current_url] or "-"
	else
		-- Standard file size
		local size = self._file:size()
		size_str = size and ya.readable_size(size) or "-"
	end

	-- Create individual colored spans
	-- local perm_span = ui.Span(string.format(" %s ", perm)):fg("magenta")
	-- local sep1 = ui.Span("| "):fg("darkgray") -- First separator
	local size_span = ui.Span(string.format("%9s ", size_str)):fg("green")
	local sep2 = ui.Span("| "):fg("darkgray") -- Second unique separator!
	local time_span = ui.Span(string.format("%s ", time_str)):fg("blue")

	-- Return them combined into a single line
	-- return ui.Line({ perm_span, sep1, size_span, sep2, time_span })
	return ui.Line({ size_span, sep2, time_span })
end
