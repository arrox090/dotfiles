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
		language_command = "python3 "
	elseif file_extension == "java" then
		language_command = "runjava "
	elseif file_extension == "lua" then
		language_command = "lua "
	elseif file_extension == "c" then
		language_command = "runc "
	elseif file_extension == "cpp" then
		language_command = "runcpp "
	elseif file_extension == "html" then
		language_command = "open "
	elseif file_extension == "sh" then
		language_command = "./"
	end
	-- print(language_command)
	-- print(file_extension)

	-- Execute : commands
	vim.cmd("wa | vsp | term")

	-- Enter command to the terminal
	vim.api.nvim_feedkeys(("i%s%s"):format(language_command, current_file), "t", true)
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
	if file_extension == "python " then
		language_command = "python3 "
	elseif file_extension == "java" then
		language_command = "runjava "
	elseif file_extension == "lua" then
		language_command = "lua "
	elseif file_extension == "c" then
		language_command = "runc "
	elseif file_extension == "html" then
		language_command = "open "
	elseif file_extension == "sh" then
		language_command = "./"
	end
	-- print(language_command)
	-- print(file_extension)

	-- Execute : commands
	vim.cmd("wa | vsp | term")

	-- Enter command to the terminal
	vim.api.nvim_feedkeys(("isudo %s%s"):format(language_command, current_file), "t", true)
end

keymap("n", "<leader>rf", run_file, { silent = true, desc = "Compile and run current buffer(file)" })
keymap(
	"n",
	"<leader>ra",
	run_file_sudo,
	{ silent = true, desc = "Compile and run current buffer(file) with administrator permissions" }
)

-- Global Auto-Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		-- The 'bufnr' ensures it only formats the file you are actively saving
		vim.lsp.buf.format({ async = false, bufnr = args.buf })
	end,
})
