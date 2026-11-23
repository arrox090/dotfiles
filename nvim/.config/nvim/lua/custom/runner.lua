local keymap = vim.keymap.set

local runners = {
	python = "python3",
	lua = "lua",
	sh = "bash",
	java = "runjava",
	c = "runc",
	cpp = "runcpp",
	html = "open",
	cs = "dotnet run",
}

-- Session cache for the last executed command and mode
local last_run_cmd = nil
local last_run_mode = "split"

-- Helper to climb upwards and find a project root, stopping strictly before $HOME
local function find_project_root(markers)
	local current_dir = vim.fn.expand("%:p:h")

	-- If the file is not inside $HOME (e.g. /usr, /etc, /tmp), don't search:
	if not vim.startswith(current_dir, vim.env.HOME) then
		return nil
	end

	local match = vim.fs.find(markers, {
		upward = true,
		stop = vim.env.HOME,
		path = vim.fn.expand("%:p:h"),
	})[1]

	return match and vim.fs.dirname(match)
end

-- Helper to execute in Tmux (or fallback split) with specific mode
local function execute_cmd(cmd, mode)
	mode = mode or "split"
	vim.cmd("silent wa") -- Save all buffers before running

	if vim.env.TMUX then
		-- Open or create the runner split
		vim.fn.VimuxOpenRunner()

		if mode == "interactive" then
			-- Focus the runner pane and zoom it fullscreen
			vim.fn.VimuxZoomRunner()
		elseif mode == "headless" then
			-- Ensure Neovim pane remains zoomed fullscreen in the background
			local is_zoomed = vim.fn.system("tmux display-message -p '#{window_zoomed_flag}'"):gsub("%s+", "")
			if is_zoomed == "0" then
				vim.fn.system("tmux resize-pane -Z")
			end
		elseif mode == "split" then
			-- Un-zoom so the split runner pane below is visible
			local is_zoomed = vim.fn.system("tmux display-message -p '#{window_zoomed_flag}'"):gsub("%s+", "")
			if is_zoomed == "1" then
				vim.fn.system("tmux resize-pane -Z")
			end
		end
		-- Run the command
		vim.fn.VimuxRunCommand(cmd)
	else
		vim.cmd("botright 15split | term " .. cmd)
	end
end

-- Helper to build the command for the current active buffer
local function build_current_file_cmd()
	local filetype = vim.bo.filetype
	local cmd_prefix = runners[filetype]

	if not cmd_prefix then
		vim.notify("No runner configured for filetype: " .. filetype, vim.log.levels.WARN)
		return nil
	end

	-- For C#: cd into project directory if found else use current dir and run dotnet run
	if filetype == "cs" then
		local root = find_project_root(function(name)
			return name:match("%.csproj$") or name:match("%.sln$")
		end) or vim.fn.expand("%:p:h")

		return "cd " .. vim.fn.fnameescape(root) .. " && dotnet run"
	end

	local current_file = vim.fn.expand("%:p")

	-- For Python: find .venv or venv upwards, activate it and run from project root:
	if filetype == "python" then
		local root = find_project_root({ ".venv", "venv" })

		if root then
			local venv_dir = vim.uv.fs_stat(root .. "/.venv/bin/activate") and ".venv" or "venv"
			local activate_rel = venv_dir .. "/bin/activate"

			if vim.uv.fs_stat(root .. "/" .. activate_rel) then
				local rel_file = current_file:sub(#root + 2)
				return "cd "
					.. vim.fn.fnameescape(root)
					.. " && source "
					.. activate_rel
					.. " && python3 "
					.. vim.fn.fnameescape(rel_file)
			end
		end
	end

	local file_dir = vim.fn.expand("%:p:h")
	local file_name = vim.fn.expand("%:t")

	return "cd " .. vim.fn.fnameescape(file_dir) .. " && " .. cmd_prefix .. " " .. vim.fn.fnameescape(file_name)
end

-- Run in split mode (<leader>rf) -> Un-zooms editor, split visible below
local function run_split()
	local cmd = build_current_file_cmd()
	if cmd then
		last_run_cmd = cmd
		last_run_mode = "split"
		execute_cmd(cmd, "split")
	end
end

-- Run in interactive mode (<leader>ri) -> Focuses runner and zooms it fullscreen
local function run_interactive()
	local cmd = build_current_file_cmd()
	if cmd then
		last_run_cmd = cmd
		last_run_mode = "interactive"
		execute_cmd(cmd, "interactive")
	end
end

-- Run in headless mode (<leader>rh) -> Runs in background, Neovim stays zoomed
local function run_headless()
	local cmd = build_current_file_cmd()
	if cmd then
		last_run_cmd = cmd
		last_run_mode = "headless"
		execute_cmd(cmd, "headless")
	end
end

-- Run Last (<leader>rl) -> PyCharm style: runs last target with remembered mode
local function run_last()
	if not last_run_cmd then
		last_run_cmd = build_current_file_cmd()
	end

	if last_run_cmd then
		execute_cmd(last_run_cmd, last_run_mode)
	end
end

-- Sudo Run (Shell scripts only: <leader>rs)
local function run_file_sudo()
	local filetype = vim.bo.filetype
	if filetype ~= "sh" then
		vim.notify("sudo run is only configured for shell scripts (.sh)", vim.log.levels.WARN)
		return
	end

	local current_file = vim.fn.expand("%:p")
	local cmd = "sudo bash " .. vim.fn.fnameescape(current_file)
	last_run_cmd = cmd
	last_run_mode = "split"
	execute_cmd(cmd, "split")
end

-- Minecraft Modding Runner (<leader>rm) -> Finds gradlew and runs runClient headlessly
local function run_minecraft()
	local root = find_project_root({ "gradlew", "build.gradle", "build.gradle.kts" })
	if not root then
		vim.notify("Could not find Minecraft project root (gradlew / build.gradle)", vim.log.levels.WARN)
		return
	end

	local cmd = "cd " .. vim.fn.fnameescape(root) .. " && ./gradlew runClient"
	last_run_cmd = cmd
	last_run_mode = "headless"
	vim.notify("Runner target set to Minecraft: " .. cmd, vim.log.levels.INFO)
	execute_cmd(cmd, "headless")
end

-- Keymaps:
keymap("n", "<leader>rf", run_split, { silent = true, desc = "Run this file (split mode, un-zoomed)" })
keymap("n", "<leader>ri", run_interactive, { silent = true, desc = "Run this file (interactive, fullscreen runner)" })
keymap("n", "<leader>rh", run_headless, { silent = true, desc = "Run this file (headless, editor stays zoomed)" })
keymap("n", "<leader>rl", run_last, { silent = true, desc = "Run last target (with remembered mode)" })
keymap("n", "<leader>rs", run_file_sudo, { silent = true, desc = "Run shell script with sudo" })
keymap("n", "<leader>rm", run_minecraft, { silent = true, desc = "Run Minecraft client (gradlew runClient)" })

-- Export find_project_root function, so it can be used across the whole neovim config
return {
	find_project_root = find_project_root,
}
