-- Intelligent path completion engine with context detection, non-destructive matching, and rich file previews.

local cmp = require("cmp")
local M = {}

local source = {}

function source:is_available()
	return true
end

function source:get_debug_name()
	return "smart_path"
end

function source:get_trigger_characters()
	return { "/", ".", "~" }
end

function source:get_keyword_pattern()
	return [=[[^\/\\:\*\?<>'"|[:blank:]]*]=]
end

-- Checks if Tree-sitter AST places cursor inside an import, include, or require statement
local function is_treesitter_path_context()
	local ok, node = pcall(vim.treesitter.get_node)
	if not ok or not node then
		return false
	end

	local curr = node
	while curr do
		local t = curr:type()
		if t:match("import") or t:match("include") or t:match("require") then
			return true
		end
		curr = curr:parent()
	end
	return false
end

-- Checks if text before quote is a known path-accepting function or variable
local function is_path_context_before_quote(line_before_quote)
	local low = line_before_quote:lower()
	-- Common path functions (allowing optional whitespace or f/r/b string prefixes)
	if
		low:match("[%w_]*open%s*%([%sfrb]*$")
		or low:match("[%w_]*path%s*%([%sfrb]*$")
		or low:match("[%w_]*read[%w_]*%s*%([%sfrb]*$")
		or low:match("[%w_]*load[%w_]*%s*%([%sfrb]*$")
		or low:match("[%w_]*save[%w_]*%s*%([%sfrb]*$")
		or low:match("[%w_]*render[%w_]*%s*%([%sfrb]*$")
		or low:match("[%w_]*include[%w_]*%s*%([%sfrb]*$")
		or low:match("require%s*%([%sfrb]*$")
		or low:match("import%s*%([%sfrb]*$")
	then
		return true
	end

	-- Common path variable assignments
	if
		low:match("[%w_]*file[%w_]*%s*=%s*[%sfrb]*$")
		or low:match("[%w_]*path[%w_]*%s*=%s*[%sfrb]*$")
		or low:match("[%w_]*dir[%w_]*%s*=%s*[%sfrb]*$")
		or low:match("[%w_]*template[%w_]*%s*=%s*[%sfrb]*$")
		or low:match("[%w_]*image[%w_]*%s*=%s*[%sfrb]*$")
	then
		return true
	end

	return is_treesitter_path_context()
end

-- Decides whether to strip './' based on the prefix preceding it
local function should_strip_dot_slash(prefix_before_dot_slash)
	-- 1. Inside quotes: " or '
	if prefix_before_dot_slash:match("[\"']$") then
		return true
	end
	-- 2. After equals sign: DB_PATH=./ or DB_PATH = ./
	if prefix_before_dot_slash:match("=%s*$") then
		return true
	end
	-- 3. After colon: build:./ or build: ./
	if prefix_before_dot_slash:match(":%s*$") then
		return true
	end
	-- 4. After YAML list item: -./ or - ./
	if prefix_before_dot_slash:match("^%s*%-%s*$") or prefix_before_dot_slash:match("%s+%-%s*$") then
		return true
	end
	-- Preserves './' in shell commands (e.g. 'cat ./run.sh', './script.sh')
	return false
end

-- Resolves the target directory relative to current buffer or project root
local function resolve_directory(raw_dir)
	local full_dir
	if raw_dir:sub(1, 2) == "~/" then
		full_dir = vim.uv.os_homedir() .. "/" .. raw_dir:sub(3)
	elseif raw_dir:sub(1, 1) == "/" then
		full_dir = raw_dir
	else
		local buf_name = vim.api.nvim_buf_get_name(0)
		local base_dir = (buf_name ~= "" and vim.fs.dirname(buf_name)) or vim.uv.cwd()
		full_dir = base_dir .. "/" .. raw_dir
		if not vim.uv.fs_stat(full_dir) and buf_name ~= "" then
			local cwd_dir = vim.uv.cwd() .. "/" .. raw_dir
			if vim.uv.fs_stat(cwd_dir) then
				full_dir = cwd_dir
			end
		end
	end
	return vim.fs.normalize(full_dir)
end

function source:complete(params, callback)
	local before = params.context.cursor_before_line
	local raw_dir, file_prefix

	-- 1. Explicit path trigger containing '/' (e.g. '/', '/etc/', './foo', 'Downloads/photos/', '~/')
	local path_match = before:match("([~./]?[%w_%-%.~/]*/[%w_%-%.]*)$")
	if path_match then
		raw_dir, file_prefix = path_match:match("^(.-/)([^/]*)$")
	else
		-- 2. Context triggers without '/' yet:
		local line_before_quote, quote_char, inside_quote = before:match("^(.-)([\"'])([^\"']*)$")

		if quote_char and is_path_context_before_quote(line_before_quote) then
			raw_dir = "./"
			file_prefix = inside_quote
		elseif before:match("%.%.$") then
			raw_dir = "./"
			file_prefix = before:match("(%.+)$")
		else
			-- Only trigger bare key: or key= in config files (docker-compose, .env, yaml, toml):
			local ft = vim.bo.filetype
			local fname = vim.fn.expand("%:t")
			local is_config = (
				ft == "yaml"
				or ft == "dockerfile"
				or ft == "toml"
				or fname:match("^%.env")
				or fname:match("docker%-compose")
			)

			if is_config then
				local after_eq = before:match("=%s*([^%s\"']*)$")
				local after_colon = before:match(":%s*([^%s\"']*)$")
				local after_hyphen = before:match("%-%s*([^%s\"']*)$")
				local bare_val = after_eq or after_colon or after_hyphen
				if bare_val and #bare_val > 0 then
					raw_dir = "./"
					file_prefix = bare_val
				else
					return callback({ items = {}, isIncomplete = false })
				end
			else
				-- Do not trigger on colons/equals in programming languages (e.g. xxx: dow, x = y, a - b)
				return callback({ items = {}, isIncomplete = false })
			end
		end
	end

	raw_dir = raw_dir or "./"
	file_prefix = file_prefix or ""

	local target_dir = resolve_directory(raw_dir)

	local handle = vim.uv.fs_scandir(target_dir)
	if not handle then
		return callback({ items = {}, isIncomplete = false })
	end

	local show_hidden = file_prefix:sub(1, 1) == "."
	local items = {}

	-- Determine if './' was explicitly typed and should be stripped on confirm
	local check_pos = #before - #file_prefix
	local has_dot_slash = (check_pos >= 2 and before:sub(check_pos - 1, check_pos) == "./")
	local strip_dot_slash = false
	if has_dot_slash then
		local prefix_before = before:sub(1, check_pos - 2)
		strip_dot_slash = should_strip_dot_slash(prefix_before)
	end

	local cursor_row = params.context.cursor.row - 1
	local cursor_col = params.context.cursor.col - 1
	local word_start = cursor_col - #file_prefix

	while true do
		local name, fs_type = vim.uv.fs_scandir_next(handle)
		if not name then
			break
		end

		if show_hidden or name:sub(1, 1) ~= "." then
			local full_item_path = (target_dir == "/" and "/" .. name) or (target_dir .. "/" .. name)
			local is_dir = (fs_type == "directory")

			-- Follow symlinks to detect directories (e.g. /etc, /tmp on macOS)
			if fs_type == "link" then
				local stat = vim.uv.fs_stat(full_item_path)
				if stat and stat.type == "directory" then
					is_dir = true
				end
			end

			local label = name .. (is_dir and "/" or "")
			local item = {
				label = label,
				kind = is_dir and cmp.lsp.CompletionItemKind.Folder or cmp.lsp.CompletionItemKind.File,
				data = {
					path = full_item_path,
					is_dir = is_dir,
				},
				-- Main textEdit replaces ONLY the word being typed (e.g. 'p' -> 'photos/').
				-- This ensures cmp's fuzzy matcher always matches against the typed letter!
				textEdit = {
					range = {
						start = { line = cursor_row, character = word_start },
						["end"] = { line = cursor_row, character = cursor_col },
					},
					newText = label,
				},
			}

			-- Atomically delete './' on confirm via additionalTextEdits:
			if strip_dot_slash and has_dot_slash then
				item.additionalTextEdits = {
					{
						range = {
							start = { line = cursor_row, character = word_start - 2 },
							["end"] = { line = cursor_row, character = word_start },
						},
						newText = "",
					},
				}
			end

			table.insert(items, item)
		end
	end

	-- Invalidate cache on backspace so returning to empty quotes closes menu:
	callback({ items = items, isIncomplete = true })
end

-- Dynamic Markdown file content & folder preview in CMP documentation popup
function source:resolve(item, callback)
	local data = item.data
	if not data or not data.path then
		return callback(item)
	end

	local stat = vim.uv.fs_stat(data.path)
	if not stat then
		return callback(item)
	end

	-- Directory Preview: List first 10 items
	if data.is_dir or stat.type == "directory" then
		local entries = {}
		local handle = vim.uv.fs_scandir(data.path)
		if handle then
			local count = 0
			while count < 10 do
				local name, t = vim.uv.fs_scandir_next(handle)
				if not name then
					break
				end
				count = count + 1
				local icon = (t == "directory") and "📁 " or "📄 "
				table.insert(entries, "• " .. icon .. "`" .. name .. "`")
			end
		end
		local body = (#entries > 0 and table.concat(entries, "\n")) or "_Empty directory_"
		item.documentation = {
			kind = "markdown",
			value = string.format("### 📁 `%s`\n\n**Contents:**\n%s", item.label, body),
		}
		return callback(item)
	end

	local size_str = stat.size > 1048576 and string.format("%.1f MB", stat.size / 1048576)
		or string.format("%.1f KB", stat.size / 1024)

	-- Read first 2KB for dynamic content inspection:
	local fd = vim.uv.fs_open(data.path, "r", 438)
	if not fd then
		item.documentation = {
			kind = "markdown",
			value = string.format("### 📄 `%s` (%s)", item.label, size_str),
		}
		return callback(item)
	end

	local buffer = vim.uv.fs_read(fd, 2048, 0)
	vim.uv.fs_close(fd)

	if not buffer or #buffer == 0 then
		item.documentation = {
			kind = "markdown",
			value = string.format("### 📄 `%s` (%s)\n\n_Empty file_", item.label, size_str),
		}
		return callback(item)
	end

	-- 1. Dynamic Binary Detection:
	if buffer:find("%z") then
		vim.system({ "file", "-b", data.path }, { text = true }, function(obj)
			local file_type = (obj.code == 0 and obj.stdout and vim.trim(obj.stdout)) or "Binary data"
			item.documentation = {
				kind = "markdown",
				value = string.format(
					"### 📦 `%s`\n\n- **Size:** %s\n- **Type:** %s",
					item.label,
					size_str,
					file_type
				),
			}
			callback(item)
		end)
		return
	end

	-- 2. Dynamic Text File Preview:
	local lines = vim.split(buffer, "\n", { plain = true })
	local preview_lines = {}
	for i = 1, math.min(#lines, 15) do
		table.insert(preview_lines, lines[i])
	end
	if #lines > 15 then
		table.insert(preview_lines, "... [more lines]")
	end

	-- Detect language: 1) extension, 2) special filenames, 3) shebang on first line
	local ext = (data.path:match("%.([%w_]+)$") or ""):lower()
	if ext == "yml" then
		ext = "yaml"
	end

	if ext == "" then
		local basename = (data.path:match("([^/]+)$") or ""):lower()
		if basename == "dockerfile" then
			ext = "dockerfile"
		elseif basename == "makefile" then
			ext = "makefile"
		else
			local shebang = (lines[1] or ""):match("^#!.*/bin/env%s+([%w_]+)")
				or (lines[1] or ""):match("^#!.*/bin/([%w_]+)")
			if shebang then
				ext = shebang
			end
		end
	end

	item.documentation = {
		kind = "markdown",
		value = string.format(
			"### 📄 `%s` (%s)\n```%s\n%s\n```",
			item.label,
			size_str,
			ext,
			table.concat(preview_lines, "\n")
		),
	}
	callback(item)
end

function M.setup(cmp_instance)
	local cmp_engine = cmp_instance or require("cmp")
	cmp_engine.register_source("smart_path", source)
end

M.is_path_context = is_path_context_before_quote
return M
