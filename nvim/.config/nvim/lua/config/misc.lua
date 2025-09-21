local keymap = vim.keymap.set

-- execute files
local function run_file()
	-- Get the path of the current file
	local current_file = vim.fn.expand("%p")

	-- Add a backslash in front of every space
	current_file = current_file:gsub(" ", "\\ ")

	-- Get file extension
	local file_extension = vim.bo.filetype

	-- Get language
	local language_command
	if file_extension == "python" then
		language_command = "python3"
	elseif file_extension == "java" then
		language_command = "runjava"
	elseif file_extension == "lua" then
		language_command = "lua"
	elseif file_extension == "c" then
		language_command = "runc"
	elseif file_extension == "html" then
		language_command = "open"
	end
	-- print(language_command)
	-- print(file_extension)

	-- Execute : commands
	vim.cmd("wa | vsp | term")

	-- Enter command to the terminal
	vim.api.nvim_feedkeys(("i%s %s"):format(language_command, current_file), "t", true)
end

local function run_file_sudo()
	-- Get the path of the current file
	local current_file = vim.fn.expand("%p")

	-- Add a backslash in front of every space
	current_file = current_file:gsub(" ", "\\ ")

	-- Get file extension
	local file_extension = vim.bo.filetype

	-- Get language
	local language_command
	if file_extension == "python" then
		language_command = "python3"
	elseif file_extension == "java" then
		language_command = "runjava"
	elseif file_extension == "lua" then
		language_command = "lua"
	elseif file_extension == "c" then
		language_command = "runc"
	elseif file_extension == "html" then
		language_command = "open"
	end
	-- print(language_command)
	-- print(file_extension)

	-- Execute : commands
	vim.cmd("wa | vsp | term")

	-- Enter command to the terminal
	vim.api.nvim_feedkeys(("isudo %s %s"):format(language_command, current_file), "t", true)
end

keymap("n", "<leader>rf", run_file, { silent = true, desc = "Compile and run current buffer(file)" })
keymap(
	"n",
	"<leader>ra",
	run_file_sudo,
	{ silent = true, desc = "Compile and run current buffer(file) with administrator permissions" }
)

---------------- custom find files telescope ------------------
my_telescope_search = function(builtin_func, opts)
	local actions = require("telescope.actions")
	local builtin = require("telescope.builtin")
	opts = opts or {}
	opts.file_ignore_patterns = { ".git" }

	opts.attach_mappings = function(_, map)
		map({ "n", "i" }, "<C-b>", function(prompt_bufnr) -- <C-b> to toggle modes
			local prompt = require("telescope.actions.state").get_current_line()
			actions.close(prompt_bufnr)
			opts.default_text = prompt
			opts.hidden = not opts.hidden
			opts.no_ignore = not opts.no_ignore
			my_telescope_search(builtin_func, opts)
		end)
		map({ "i" }, "jk", function() -- jk to exit insert mode
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
		end)
		map("n", "q", actions.close)
		return true
	end

	if opts.no_ignore then
		if builtin_func == "find_files" then
			opts.prompt_title = "Find Files <ALL>"
			builtin.find_files(opts)
		else
			opts.prompt_title = "Live Grep <ALL>"
			opts.vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--hidden", -- include hidden files
				"-u", -- include ignored files
			}
			builtin.live_grep(opts)
		end
	else
		opts.vimgrep_arguments = nil
		opts.prompt_title = nil
		if builtin_func == "find_files" then
			builtin.find_files(opts)
		else
			builtin.live_grep(opts)
		end
	end
end
