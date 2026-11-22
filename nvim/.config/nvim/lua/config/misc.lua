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

-- Session cache for the last executed command
local last_run_cmd = nil

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

-- Helper to execute in Tmux (or fallback split)
local function execute_cmd(cmd)
	vim.cmd("silent wa") -- Save all buffers before running

	if vim.env.TMUX then
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
			local activate = root .. "/.venv/bin/activate"
			if not vim.uv.fs_stat(activate) then
				activate = root .. "/venv/bin/activate"
			end

			if vim.uv.fs_stat(activate) then
				return "cd "
					.. vim.fn.fnameescape(root)
					.. " && source "
					.. vim.fn.fnameescape(activate)
					.. " && python3 "
					.. vim.fn.fnameescape(current_file)
			end
		end
	end

	return cmd_prefix .. " " .. vim.fn.fnameescape(current_file)
end

-- Run This File (<leader>rt) -> Forces target to current buffer & runs it
local function run_this_file()
	local cmd = build_current_file_cmd()
	if cmd then
		last_run_cmd = cmd
		vim.notify("Runner target set to: " .. cmd, vim.log.levels.INFO)
		execute_cmd(cmd)
	end
end

-- Run Last (<leader>rf) -> PyCharm style: runs last target, or current if first time
local function run_file()
	if not last_run_cmd then
		last_run_cmd = build_current_file_cmd()
	end

	if last_run_cmd then
		execute_cmd(last_run_cmd)
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
	execute_cmd(cmd)
end

-- Minecraft Modding Runner (<leader>rm) -> Finds gradlew and runs runClient
local function run_minecraft()
	-- try to find gradlew in parent dirs
	local root = find_project_root({ "gradlew", "build.gradle", "build.gradle.kts" })
	if not root then
		vim.notify("Could not find Minecraft project root (gradlew / build.gradle)", vim.log.levels.WARN)
		return
	end

	local cmd = "cd " .. vim.fn.fnameescape(root) .. " && ./gradlew runClient"
	last_run_cmd = cmd
	vim.notify("Runner target set to Minecraft: " .. cmd, vim.log.levels.INFO)
	execute_cmd(cmd)
end

-- Keymaps:
keymap("n", "<leader>rt", run_this_file, { silent = true, desc = "Set as runner target and run this file" })
keymap("n", "<leader>rf", run_file, { silent = true, desc = "Run active target (or current file)" })
keymap("n", "<leader>rs", run_file_sudo, { silent = true, desc = "Run shell script with sudo" })
keymap("n", "<leader>rm", run_minecraft, { silent = true, desc = "Run Minecraft client (gradlew runClient)" })
